//
//  GlobalStore.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/12/01.
//

import Foundation
import URnetworkSdk
import UIKit

@MainActor
class DeviceManager: ObservableObject {
    
    let domain = "GlobalStore"
    
    @Published private(set) var networkSpace: SdkNetworkSpace? {
        didSet {
            setApi(networkSpace?.getApi())
            updateParsedJwt()
        }
    }
    
    @Published private(set) var api: SdkApi?
    
    @Published private(set) var device: SdkDeviceRemote? {
        didSet {
            
            DispatchQueue.main.async {
                self.provideWhileDisconnected = self.device?.getProvideWhileDisconnected() ?? false
            }
            
            updateParsedJwt()
        }
    }
    
    @Published var provideWhileDisconnected: Bool = false {
        didSet {
            handleProvideWhileDisconnectedUpdate(provideWhileDisconnected)
        }
    }
    
    @Published private(set) var deviceInitialized: Bool = false
    
    private func handleProvideWhileDisconnectedUpdate(_ canProvideWhileDisconnected: Bool) {
        device?.setProvideWhileDisconnected(canProvideWhileDisconnected)
        
        if let localState = asyncLocalState?.getLocalState() {
            
            do {
                try localState.setProvideWhileDisconnected(canProvideWhileDisconnected)
            } catch(let error) {
                print("[\(domain)] Error setting provide while disconnected: \(error)")
            }
            
        } else {
            print("[\(domain)] No local state found when updating provide while disconnected")
        }
        
    }
    
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
    
    @Published private(set) var parsedJwt: SdkByJwt?
    
    private func updateParsedJwt() {
        
        guard let localState = networkSpace?.getAsyncLocalState()?.getLocalState() else {
            parsedJwt = nil
            return
        }
        
        do {
            parsedJwt = try localState.parseByJwt()
        } catch {
            print("error parsing jwt: \(error)")
            parsedJwt = nil
        }
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
    
    func setApi(_ api: SdkApi?) {
        self.api = api
    }
    
    func setDevice(_ device: SdkDeviceRemote?) {
        self.device = device
    }
    
}

private class NetworkSpaceUpdateCallback: NSObject, URnetworkSdk.SdkNetworkSpaceUpdateProtocol {
    var c: (URnetworkSdk.SdkNetworkSpaceValues) -> Void

    init(c: @escaping (URnetworkSdk.SdkNetworkSpaceValues) -> Void) {
        self.c = c
    }

    func update(_ values: URnetworkSdk.SdkNetworkSpaceValues?) {
        if let values {
            c(values)
        }
    }
}

private class GetJwtInitDeviceCallback: NSObject, SdkGetByClientJwtCallbackProtocol {
    
    weak var globalStore: DeviceManager?
    var deviceSpecs: String
    
    var onResult: (_ result: String?, _ ok: Bool) -> Void
    
    init(networkStore: DeviceManager?, deviceSpecs: String, onResult: @escaping (_ result: String?, _ ok: Bool) -> Void) {
        self.globalStore = networkStore
        self.deviceSpecs = deviceSpecs
        self.onResult = onResult
    }
    
    func result(_ result: String?, ok: Bool) {
        
        self.onResult(result, ok)

    }
}

// MARK: Network space handlers
extension DeviceManager {
    
    func initializeNetworkSpace(_ storagePath: String) async {
        
        print("initialize network space hit")
        
        let deviceSpecs = self.getDeviceSpecs()
        let networkSpaceManager = URnetworkSdk.SdkNewNetworkSpaceManager(storagePath)
        
        let hostName = "ur.network"
        let envName = "main"
        let networkSpaceKey = URnetworkSdk.SdkNewNetworkSpaceKey(hostName, envName)
        
        networkSpaceManager?.updateNetworkSpace(networkSpaceKey, callback: NetworkSpaceUpdateCallback(
            c: { networkSpaceValues in
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
            }
        ))
            
        self.networkSpace = networkSpaceManager?.getNetworkSpace(networkSpaceKey)
        
        let getJwtCallback = GetJwtInitDeviceCallback(
            networkStore: self,
            deviceSpecs: deviceSpecs,
            onResult: { result, ok in
        
                if ok {
        
                    guard let result else {
                        print("[GetByClientJwtCallback] result is nil")
                        self.logout()
        
                        return
                    }
        
                    if result == "" {
                        self.logout()
                    } else {
                        self.initDevice(clientJwt: result, deviceSpec: deviceSpecs)
                    }
        
                } else {
                    
                    DispatchQueue.main.async {
                        self.deviceInitialized = true
                    }
                    
                }
                
                
            }
        )
        self.asyncLocalState?.getByClientJwt(getJwtCallback)
        
    }
    
}

// MARK: Device handlers
extension DeviceManager {
    
    func initDevice(
        clientJwt: String,
        deviceSpec: String
    ) {
        
        device?.close()
        
        if let networkSpace = networkSpace {
            
            let localState = asyncLocalState?.getLocalState()
            
            if let localState = localState {
                
//                let instanceId = localState.getInstanceId()
                let routeLocal = localState.getRouteLocal()
                let connectLocation = localState.getConnectLocation()
                let canShowRatingDialog = localState.getCanShowRatingDialog()
                let provideWhileDisconnected = localState.getProvideWhileDisconnected()
                let provideMode = provideWhileDisconnected ? SdkProvideModePublic : localState.getProvideMode()
                let canRefer = localState.getCanRefer()
                // note ios does not allow VPN interface while offline, due to the existing interface conditions
                // ignore `vpnInterfaceWhileOffline`
                
                var instanceId = localState.getInstanceId()
                if instanceId == nil {
                    instanceId = SdkNewId()
                    try? localState.setInstanceId(instanceId)
                }
                
                var newDeviceError: NSError?
                
                
                let device = SdkNewDeviceRemoteWithDefaults(
                    networkSpace,
                    clientJwt,
                    instanceId,
                    &newDeviceError
                )
                
                if let error = newDeviceError {
                    print("Error occurred: \(error.localizedDescription)")
                } else {
                    print("Device created successfully")
                }
                
                guard let device = device else {
                    return
                }
                
                if let providerSecretKeys = localState.getProvideSecretKeys() {
                    device.loadProvideSecretKeys(providerSecretKeys)
                } else {
                    var providerSecretKeysSub: SdkSubProtocol?
                    providerSecretKeysSub = device.add(ProvideSecretKeysListener { provideSecretKeysList in
                        try? localState.setProvideSecretKeys(provideSecretKeysList)
                        providerSecretKeysSub?.close()
                    })
                    device.initProvideSecretKeys()
                }
                
                // note the network extension controls listening for connectivity and provide paused
                // ignore `providePaused`
                device.setRouteLocal(routeLocal)
                device.setProvideMode(provideMode)
                device.setCanShowRatingDialog(canShowRatingDialog)
                device.setProvideWhileDisconnected(provideWhileDisconnected)
                device.setCanRefer(canRefer)
                
                // only set the location if the current location is not already equivalent
                // this avoid resetting the connection
                if let remoteLocation = device.getConnectLocation() {
                    if !remoteLocation.equals(connectLocation) {
                        device.setConnectLocation(connectLocation)
                    }
                } else {
                    device.setConnectLocation(connectLocation)
                }
                
                DispatchQueue.main.async {
                    self.device = device
                }
                
            } else {
                print("local state is nil")
            }
            
        }
        
        DispatchQueue.main.async {
            self.deviceInitialized = true
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
extension DeviceManager {
    
    private class LogoutCallback: NSObject, SdkCommitCallbackProtocol {
        
        weak var deviceManager: DeviceManager?
        
        init(deviceManager: DeviceManager) {
            self.deviceManager = deviceManager
        }
        
        func complete(_ success: Bool) {
            
            guard let deviceManager = deviceManager else {
                print("[LogoutCallback:complete] network store is nil")
                return
            }
            
            Task { @MainActor in
                deviceManager.api?.setByJwt(nil)
                deviceManager.setDevice(nil)
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
            
            let deviceSpecs = getDeviceSpecs()
            
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
        
        let logoutCallback = LogoutCallback(deviceManager: self)
        
        asyncLocalState.logout(logoutCallback)
    }
    
    private func getDeviceSpecs() -> String {
        
        let systemVersion = UIDevice.current.systemVersion
        let deviceModel = UIDevice.current.model
        let deviceName = UIDevice.current.name
        
        return "\(systemVersion) \(deviceModel) \(deviceName)"
    }
    
}


private class ProvideSecretKeysListener: NSObject, SdkProvideSecretKeysListenerProtocol {
    
    private let c: (_ provideSecretKeysList: SdkProvideSecretKeyList?) -> Void

    init(c: @escaping (_ provideSecretKeysList: SdkProvideSecretKeyList?) -> Void) {
        self.c = c
    }
    
    func provideSecretKeysChanged(_ provideSecretKeysList: SdkProvideSecretKeyList?) {
        c(provideSecretKeysList)
    }
}

