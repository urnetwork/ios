//
//  NetworkStore.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/12/01.
//

import Foundation
import URnetworkSdk
import UIKit

class NetworkStore: ObservableObject {
    
    let domain = "NetworkStore"
    
    // for testing
    @Published var isAuthenticated: Bool = false
    
    @Published private(set) var networkSpace: SdkNetworkSpace? {
        didSet {
            print("network space set: get api url: \(networkSpace?.getApiUrl() ?? "none")")
            setApi(networkSpace?.getApi())
        }
    }
    
    @Published private(set) var api: SdkBringYourApi?
    
    @Published private(set) var device: SdkBringYourDevice?
    
    // TODO: check how this is used or set
    let deviceDescription = "New device"
    
    // TODO:
    // @Published private(set) var deviceDescription: String = "New device"
    
//    func setDeviceDescription(_ value: String) {
//        deviceDescription = value
//        // device?.setDeviceDescription(value)
//    }
    
    init() {
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory,
                                                   in: .userDomainMask)[0]
        
        Task {
            await self.initializeNetworkSpace(documentsPath.path())
        }
        
    }
    
    var asyncLocalState: SdkAsyncLocalState? {
        return networkSpace?.getAsyncLocalState()
    }
    
    var routeLocal: Bool {
        return device?.getRouteLocal() ?? false
    }
    
    func setRouteLocal(_ value: Bool) {
        do {
            try asyncLocalState?.getLocalState()?.setRouteLocal(value)
        } catch {
            print("error setting route local: \(error)")
        }

        device?.setRouteLocal(value)
    }
    
    func setCanShowRatingDialog(_ value: Bool) {
        do {
            try asyncLocalState?.getLocalState()?.setCanShowRatingDialog(value)
        } catch {
            print("error setting can show rating dialog: \(error)")
        }

        device?.setCanShowRatingDialog(value)
    }
    
    func setCanRefer(_ value: Bool) {
        do {
            try asyncLocalState?.getLocalState()?.setCanRefer(value)
        } catch {
            print("error setting can refer: \(error)")
        }
        
        device?.setCanRefer(value)
    }
    
    func setProvideWhileDisconnected(_ value: Bool) {
        do {
            try asyncLocalState?.getLocalState()?.setProvideWhileDisconnected(value)
        } catch {
            print("error setting provide while disconnected: \(error)")
        }
        
        device?.setProvideWhileDisconnected(value)
    }
    
    func setVpnInterfaceWhileOffline(_ value: Bool) {
        do {
            try asyncLocalState?.getLocalState()?.setVpnInterfaceWhileOffline(value)
        } catch {
            print("error setting vpn interface while offline: \(error)")
        }
        
        device?.setVpnInterfaceWhileOffline(value)
    }
    
    func setApi(_ api: SdkBringYourApi?) {
        self.api = api
    }
    
    func setDevice(_ device: SdkBringYourDevice?) {
        self.device = device
    }
    
}

private class NetworkSpaceUpdateCallback: NSObject, URnetworkSdk.SdkNetworkSpaceUpdateProtocol {
    func update(_ values: URnetworkSdk.SdkNetworkSpaceValues?) {
        guard let values = values else {
            return
        }
    }
}

private class GetJwtInitDeviceCallback: NSObject, SdkGetByClientJwtCallbackProtocol {
    
    weak var networkStore: NetworkStore?
    var deviceSpecs: String
    
    init(networkStore: NetworkStore?, deviceSpecs: String) {
        self.networkStore = networkStore
        self.deviceSpecs = deviceSpecs
    }
    
    func result(_ result: String?, ok: Bool) {
        
        guard let networkStore = networkStore else {
            print("[GetByClientJwtCallback] no network store found")
            return
        }
        
        if ok {
            
            guard let result else {
                print("[GetByClientJwtCallback] result is nil")
                networkStore.logout()
                return
            }
            
            if result == "" {
                networkStore.logout()
            } else {
                networkStore.initDevice(clientJwt: result, deviceSpec: self.deviceSpecs)
            }
            
        }
    }
}

// MARK: Network space handlers
extension NetworkStore {
    
    func initializeNetworkSpace(_ storagePath: String) async {
        
        let deviceSpecs = await self.getDeviceSpecs()
        let networkSpaceManager = URnetworkSdk.SdkNewNetworkSpaceManager(storagePath)
        let networkSpaceUpdateCallback = NetworkSpaceUpdateCallback()
        
        let networkSpaceValues = SdkNetworkSpaceValues()
        
        // TODO: this should be moved into a config
        networkSpaceValues.envSecret = ""
        networkSpaceValues.bundled = true
        networkSpaceValues.netExposeServerIps = true
        networkSpaceValues.netExposeServerHostNames = true
        networkSpaceValues.linkHostName = "ur.io"
        networkSpaceValues.migrationHostName = "bringyour.com"
        networkSpaceValues.store = ""
        networkSpaceValues.wallet = "circle"
        networkSpaceValues.ssoGoogle = false
        
        networkSpaceUpdateCallback.update(networkSpaceValues)
        
        let hostName = "ur.network"
        let envName = "main"
        let networkSpaceKey = URnetworkSdk.SdkNewNetworkSpaceKey(hostName, envName)
        
        networkSpaceManager?.updateNetworkSpace(networkSpaceKey, callback: networkSpaceUpdateCallback)
        
        DispatchQueue.main.async {
            
            self.networkSpace = networkSpaceManager?.getNetworkSpace(networkSpaceKey)
            
            let getJwtCallback = GetJwtInitDeviceCallback(networkStore: self, deviceSpecs: deviceSpecs)
            self.asyncLocalState?.getByClientJwt(getJwtCallback)
        }
        
    }
    
}

// MARK: Device handlers
extension NetworkStore {
    
    func initDevice(
        clientJwt: String,
        deviceSpec: String
    ) {
        
        print("init device hit")
        
        device?.close()
        
        if let networkSpace = networkSpace {
            
            let localState = asyncLocalState?.getLocalState()
            
            if let localState = localState {
                
                let instanceId = localState.getInstanceId()
                let routeLocal = localState.getRouteLocal()
                let connectLocation = localState.getConnectLocation()
                let canShowRatingDialog = localState.getCanShowRatingDialog()
                let provideWhileDisconnected = localState.getProvideWhileDisconnected()
                let provideMode = provideWhileDisconnected ? SdkProvideModePublic : localState.getProvideMode()
                let vpnInterfaceWhileOffline = localState.getVpnInterfaceWhileOffline()
                let canRefer = localState.getCanRefer()
                
                print("aaa")
                
                var newDeviceError: NSError?
                
                DispatchQueue.main.async {
                    self.device = SdkNewBringYourDeviceWithDefaults(
                        networkSpace,
                        clientJwt,
                        self.deviceDescription,
                        deviceSpec,
                        self.getAppVersion(),
                        instanceId,
                        &newDeviceError
                    )
                    
                    if let error = newDeviceError {
                        print("Error occurred: \(error.localizedDescription)")
                    } else {
                        print("Device created successfully")
                    }
                    
                    guard let device = self.device else {
                        print("device is nil")
                        return
                    }
                    
                    if let providerSecretKeys = localState.getProvideSecretKeys() {
                        device.loadProvideSecretKeys(providerSecretKeys)
                    } else {
                        device.initProvideSecretKeys()
                        device.loadProvideSecretKeys(device.getProvideSecretKeys())
                    }
                    
                    device.setProvidePaused(true)
                    device.setRouteLocal(routeLocal)
                    device.setProvideMode(provideMode)
                    device.setConnectLocation(connectLocation)
                    device.setCanShowRatingDialog(canShowRatingDialog)
                    device.setProvideWhileDisconnected(provideWhileDisconnected)
                    device.setVpnInterfaceWhileOffline(vpnInterfaceWhileOffline)
                    device.setCanRefer(canRefer)
                }
                
            } else {
                print("local state is nil")
            }
            
        }
        
    }
    
    func clearDevice() {
        device?.close()
        device = nil
    }
    
    private func getAppVersion() -> String? {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            print("App version: \(version)")
            return version
        }
        
        return nil
    }
    
    // TODO: add device listeners
    private func setupDeviceListeners() {
        
        if let device = device {
            
            // device.add(<#T##listener: (any SdkRouteLocalChangeListenerProtocol)?##(any SdkRouteLocalChangeListenerProtocol)?#>)
            
        }
        
    }
    
}

private class AuthNetworkClientCallback: SdkCallback<SdkAuthNetworkClientResult, SdkAuthNetworkClientCallbackProtocol>, SdkAuthNetworkClientCallbackProtocol {
    func result(_ result: SdkAuthNetworkClientResult?, err: Error?) {
        handleResult(result, err: err)
    }
}

private class SetJWTLocalStateCallback: NSObject, SdkCommitCallbackProtocol {
    
    let continuation: CheckedContinuation<Void, Error>
    let clientJwt: String
    let deviceSpecs: String
    let initDevice: (_ clientJwt: String, _ deviceSpecs: String) -> Void
    
    init(
        continuation: CheckedContinuation<Void, Error>,
        clientJwt: String,
        deviceSpecs: String,
        initDevice: @escaping (_ clientJwt: String, _ deviceSpecs: String) -> Void
    ) {
        self.continuation = continuation
        
        self.initDevice = initDevice
        
        self.clientJwt = clientJwt
        self.deviceSpecs = deviceSpecs
    }
    
    func complete(_ success: Bool) {
        
        if success {
            
            self.initDevice(clientJwt, deviceSpecs)
            
            continuation.resume(returning: ())
        } else {
            continuation.resume(throwing: NSError(domain: "SetJWTLocalStateCallback", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to set client JWT"]))
        }
        
    }
}


// MARK: login/logout
extension NetworkStore {
    
    private class LogoutCallback: NSObject, SdkCommitCallbackProtocol {
        
        weak var networkStore: NetworkStore?
        
        init(networkStore: NetworkStore) {
            self.networkStore = networkStore
        }
        
        func complete(_ success: Bool) {
            
            guard let networkStore = networkStore else {
                print("[LogoutCallback:complete] network store is nil")
                return
            }
            
            networkStore.api?.setByJwt(nil)
            DispatchQueue.main.async {
                networkStore.setDevice(nil)
            }
            
        }
    }
    
    func authenticateNetworkClient(_ jwt: String) async -> Result<Void, Error> {
        
        do {
            try asyncLocalState?.getLocalState()?.setByJwt(jwt)
        } catch {
            return .failure(error)
        }
        
        guard let api = api else {
            return .failure(NSError(domain: domain, code: 0, userInfo: [NSLocalizedDescriptionKey: "login: api is nil"]))
        }
        
        api.setByJwt(jwt)
        
        // NOTE: the following was in authClientAndFinish in Android
        // not sure if we need to keep these as separate functions
        
        do {
            
            let deviceSpecs = await getDeviceSpecs()
            
            let result: Void = try await withCheckedThrowingContinuation { continuation in
                
                let authArgs = SdkAuthNetworkClientArgs()
                authArgs.description = deviceDescription
                authArgs.deviceSpec = deviceSpecs
                
                let callback = AuthNetworkClientCallback { [weak self] result, error in
                    
                    guard let self = self else { return }
                    
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }
                    
                    guard let result = result else {
                        continuation.resume(throwing: NSError(domain: self.domain, code: -1, userInfo: [NSLocalizedDescriptionKey: "No result found in AuthNetworkClientCallback"]))
                        return
                    }
                    
                    if let resultError = result.error {
                        continuation.resume(throwing: NSError(domain: self.domain, code: -1, userInfo: [NSLocalizedDescriptionKey: resultError.message]))
                        
                        return
                    }

                    let clientJwt = result.byClientJwt
                    
                    let callback = SetJWTLocalStateCallback(
                        continuation: continuation,
                        clientJwt: clientJwt,
                        deviceSpecs: deviceSpecs,
                        initDevice: self.initDevice(clientJwt:deviceSpec:)
                    )
                    
                    self.asyncLocalState?.setByClientJwt(clientJwt, callback: callback)
                    
                }
                
                api.authNetworkClient(authArgs, callback: callback)
                
            }
            
            return .success(result)
            
        } catch {
            return .failure(error)
        }
        
    }
    
    func logout() {
        
        guard let asyncLocalState = asyncLocalState else {
            print("[logout] asyncLocalState is nil")
            return
        }
        
        let logoutCallback = LogoutCallback(networkStore: self)
        
        asyncLocalState.logout(logoutCallback)
    }
    
    private func getDeviceSpecs() async -> String {
        
        let systemVersion = await UIDevice.current.systemVersion
        let deviceModel = await UIDevice.current.model
        let deviceName = await UIDevice.current.name
        
        return "\(systemVersion) \(deviceModel) \(deviceName)"
    }
    
}
