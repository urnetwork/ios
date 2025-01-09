//
//  EmptyWalletsViewModel.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2025/01/08.
//

import Foundation
import CryptoKit
import URnetworkSdk
import UIKit

extension EmptyWalletsView {
    
    private struct SolflareResponse: Codable {
        let public_key: String
        let session: String
    }
    
    private struct DisconnectPayload: Encodable {
        let session: String
    }
    
    class ViewModel: ObservableObject {
        
        @Published private(set) var connectedPublicKey: String?
        
        private var dappKeyPair: (privateKey: Curve25519.KeyAgreement.PrivateKey, publicKey: Curve25519.KeyAgreement.PublicKey)?
        private var sharedSecret: SymmetricKey?
        private var session: String?
        let appURL = "https://ur.io"
        
        /**
         * Solflare
         */
        let solflareHostname = "solflare.com"
        let solflareConnectRedirectLink = "urnetwork://solflare-connect"
        let solflareDisconnectRedirectLink = "urnetwork://solflare-disconnect"
        
        /**
         * Phantom
         */
        let phantomHostname = "phantom.app"
        let phantomConnectRedirectLink = "urnetwork://phantom-connect"
        let phantomDisconnectRedirectLink = "urnetwork://phantom-disconnect"
            
        func createKeyPair() {
            let privateKey = Curve25519.KeyAgreement.PrivateKey()
            dappKeyPair = (privateKey, privateKey.publicKey)
        }
        
        func connectSolflareWallet() {
            let queryString = self.buildConnectQueryString(redirectLink: solflareConnectRedirectLink)
            
            if let url = URL(string: "https://\(self.solflareHostname)/ul/v1/connect?\(queryString)") {
                UIApplication.shared.open(url)
            }
        }
        
        func connectPhantomWallet() {
            let queryString = self.buildConnectQueryString(redirectLink: phantomConnectRedirectLink)
            
            if let url = URL(string: "https://\(self.phantomHostname)/ul/v1/connect?\(queryString)") {
                UIApplication.shared.open(url)
            }
        }
        
        private func buildConnectQueryString(redirectLink: String) -> Result<String, WalletDeepLinkError> {
            guard let keyPair = dappKeyPair else { return .failure(WalletDeepLinkError.missingDappKeyPair) }
            
            let params = [
                "dapp_encryption_public_key": SdkEncodeBase58(keyPair.publicKey.rawRepresentation),
                "cluster": "mainnet-beta",
                "app_url": appURL,
                "redirect_link": redirectLink
            ]
            
            let queryString = params.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
            return .success(queryString)
        }
        
        func handleDeepLink(_ url: URL) {

            guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                  let queryItems = components.queryItems,
                  components.host == "solflare-connect" || components.host == "phantom-connect" else {
                print("no match for components.host")
                return
            }
            
            let host = components.host
            
            let connectedWalletProvider = (host == "solflare-connect") ? ConnectedWalletProvider.solflare : ConnectedWalletProvider.phantom
            
            let publicKeyParamKey = connectedWalletProvider == ConnectedWalletProvider.solflare ? "solflare_encryption_public_key" : "phantom_encryption_public_key"
            
            let params: [String: String] = Dictionary(uniqueKeysWithValues: queryItems.compactMap { item in
                guard let value = item.value else { return nil }
                return (item.name, value)
            })
            
            guard let walletEncryptionPublicKey = params[publicKeyParamKey],
                  let nonce = params["nonce"],
                  let data = params["data"],
                  let keyPair = dappKeyPair else { return }
                  
            if let sharedSecret = generateSharedSecret(
                privateKey: keyPair.privateKey,
                walletEncryptionPublicKey: walletEncryptionPublicKey
            ) {
                let sharedSecretBase58 = SdkEncodeBase58(sharedSecret)
                
                if let decryptedData = SdkDecryptData(data, nonce, sharedSecretBase58, nil),
                   let json = try? JSONDecoder().decode(SolflareResponse.self, from: decryptedData) {
                    self.connectedPublicKey = json.public_key
                    self.session = json.session
                } else {
                    print("Decryption failed")
                }
            }
        }
        
        private func generateSharedSecret(privateKey: Curve25519.KeyAgreement.PrivateKey, walletEncryptionPublicKey: String) -> Data? {
            
            guard let walletPublicKeyData = SdkDecodeBase58(walletEncryptionPublicKey, nil) else {
                print("Failed to decode wallet encryption public key")
                return nil
            }
            
            // Use SdkGenerateSharedSecret instead of CryptoKit
            return SdkGenerateSharedSecret(
                privateKey.rawRepresentation,
                walletPublicKeyData,
                nil
            )
        }
        
        /**
         * Disconnect is currently not used or handled in handleDeepLink
         */
        private func disconnect(connectedWalletProvider: ConnectedWalletProvider) {
            
            let redirectLink = connectedWalletProvider == .phantom ? self.phantomDisconnectRedirectLink : self.solflareDisconnectRedirectLink
            
            let queryString = buildDisconnectQueryString(redirectLink: redirectLink)
            
            let hostName = connectedWalletProvider == .phantom ? phantomHostname : solflareHostname
            
            if let url = URL(string: "https://\(hostName)/ul/v1/connect?\(queryString)") {
                UIApplication.shared.open(url)
            }
            
        }
        
        private func buildDisconnectQueryString(redirectLink: String) -> Result<String, WalletDeepLinkError> {
            guard let keyPair = self.dappKeyPair, let session = self.session else { return .failure(WalletDeepLinkError.missingParams) }
            let nonce = self.generateNonce()
            
            let payload = DisconnectPayload(session: session)
            guard let jsonData = try? JSONEncoder().encode(payload),
                  let jsonString = String(data: jsonData, encoding: .utf8) else {
                return .failure(WalletDeepLinkError.failedCreatingPayload)
            }
            
            let params = [
                "dapp_encryption_public_key": SdkEncodeBase58(keyPair.publicKey.rawRepresentation),
                "nonce": nonce,
                "redirect_link": redirectLink,
                "payload": jsonString
            ]
            
            let queryString = params.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
            return .success(queryString)
        }
        
        /**
         * Used for created a disconnect nonce
         */
        private func generateNonce() -> String {
            let randomBytes = Array<UInt8>.init(repeating: 0, count: 32)
            SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, UnsafeMutableRawPointer(mutating: randomBytes))
            return SdkEncodeBase58(Data(randomBytes))
        }
        
    }
    
}

enum WalletDeepLinkError: Error {
    case missingDappKeyPair
    case failedCreatingPayload
    case missingParams
    case invalidParameters
}

enum ConnectedWalletProvider {
    case solflare
    case phantom
}
