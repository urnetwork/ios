//
//  ConnectExternalWalletSheetView.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/12/17.
//

import SwiftUI
import URnetworkSdk

struct ConnectExternalWalletSheetView: View {
    
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var accountWalletsViewModel: AccountWalletsViewModel
    @StateObject var viewModel: ViewModel
    
    var onSuccess: () -> Void
    
    init(
        onSuccess: @escaping () -> Void, api: SdkBringYourApi?
    ) {
        self.onSuccess = onSuccess
        self._viewModel = StateObject(wrappedValue: ViewModel(api: api))
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Text("Connect an external wallet")
                .font(themeManager.currentTheme.titleCondensedFont)
                .foregroundColor(themeManager.currentTheme.textColor)
            
            Spacer().frame(height: 16)
            
            UrTextField(
                text: $viewModel.walletAddress,
                label: "USDC wallet address",
                placeholder: "Enter a Solana or Matic USDC wallet address",
                supportingText: "USDC addresses on Solana and Polygon are currently supported",
                isEnabled: !accountWalletsViewModel.isCreatingWallet,
                submitLabel: .continue,
                onSubmit: {
                    Task {
                        let result = await accountWalletsViewModel.connectWallet(
                            walletAddress: viewModel.walletAddress,
                            chain: viewModel.chain
                        )
                        self.handleCreateResult(result)
                    }
                }
            )

            Spacer()
            
            UrButton(
                text: "Connect Wallet",
                action: {
                    Task {
                        let result = await accountWalletsViewModel.connectWallet(
                            walletAddress: viewModel.walletAddress,
                            chain: viewModel.chain
                        )
                        self.handleCreateResult(result)
                    }
                },
                enabled: viewModel.isValidWalletAddress && !accountWalletsViewModel.isCreatingWallet
            )
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(themeManager.currentTheme.backgroundColor)
    }
    
    private func handleCreateResult(_ result: Result<Void, Error>) {
        switch result {
            
        case .success:
            onSuccess()
            
        case .failure(let error):
            print("error creating wallet: \(error)")
        }
    }
}

//#Preview {
//    ConnectExternalWalletSheetView(
//        onSuccess: {},
//        api: nil
//    )
//        .environmentObject(ThemeManager.shared)
//}
