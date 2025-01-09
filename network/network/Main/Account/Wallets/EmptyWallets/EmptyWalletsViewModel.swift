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
    
    class ViewModel: ObservableObject {
        
        @Published private(set) var dappKeyPair: (privateKey: Curve25519.KeyAgreement.PrivateKey, publicKey: Curve25519.KeyAgreement.PublicKey)?
        @Published private(set) var sharedSecret: SymmetricKey?
        @Published private(set) var connectedPublicKey: String?
        
        let redirectLink = "urnetwork://solflare-connect"
        let appURL = "https://ur.io"
            
        func createKeyPair() {
            let privateKey = Curve25519.KeyAgreement.PrivateKey()
            dappKeyPair = (privateKey, privateKey.publicKey)
        }
        
        func connectSolflareWallet() {
            guard let keyPair = dappKeyPair else { return }
            
            let params = [
                "dapp_encryption_public_key": SdkEncodeBase58(keyPair.publicKey.rawRepresentation),
                "cluster": "mainnet-beta",
                "app_url": appURL,
                "redirect_link": redirectLink
            ]
            
            let queryString = params.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
            if let url = URL(string: "solflare://ul/v1/connect?\(queryString)") {
                UIApplication.shared.open(url)
            }
        }
        
        func handleDeepLink(_ url: URL) {
            guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                  let queryItems = components.queryItems,
                  components.host == "solflare-connect" else { return }
            
            let params: [String: String] = Dictionary(uniqueKeysWithValues: queryItems.compactMap { item in
                guard let value = item.value else { return nil }
                return (item.name, value)
            })
            
            guard let solflarePublicKey = params["solflare_encryption_public_key"],
                  let nonce = params["nonce"],
                  let data = params["data"],
                  let keyPair = dappKeyPair else { return }
                  
            if let sharedSecret = generateSharedSecret(
                privateKey: keyPair.privateKey,
                solflarePublicKeyBase58: solflarePublicKey
            ) {
                let sharedSecretBase58 = SdkEncodeBase58(sharedSecret)
                
                if let decryptedData = SdkDecryptData(data, nonce, sharedSecretBase58, nil),
                   let json = try? JSONDecoder().decode(SolflareResponse.self, from: decryptedData) {
                    connectedPublicKey = json.public_key
                } else {
                    print("Decryption failed")
                }
            }
        }
        
        private func generateSharedSecret(privateKey: Curve25519.KeyAgreement.PrivateKey, solflarePublicKeyBase58: String) -> Data? {
            
            guard let solflarePublicKeyData = SdkDecodeBase58(solflarePublicKeyBase58, nil) else {
                print("Failed to decode solflare public key")
                return nil
            }
            
            // Use SdkGenerateSharedSecret instead of CryptoKit
            return SdkGenerateSharedSecret(
                privateKey.rawRepresentation,
                solflarePublicKeyData,
                nil
            )
        }
        
    }
    
}
