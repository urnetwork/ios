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
    @StateObject var viewModel: ViewModel
    var onSuccess: () -> Void
    
    init(onSuccess: @escaping () -> Void, api: SdkApi?) {
        
        self.onSuccess = onSuccess
        self._viewModel = StateObject(wrappedValue: ViewModel(api: api))
        
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Text("Connect an external wallet")
                .font(themeManager.currentTheme.titleCondensedFont)
                .foregroundColor(themeManager.currentTheme.textColor)
            
            Spacer().frame(height: 16)
            
//            UrTextEditor(
//                text: $viewModel.walletAddress,
//                height: 64,
//                enabled: !viewModel.isCreatingWallet
//            )
            
            UrTextField(
                text: $viewModel.walletAddress,
                label: "USDC wallet address",
                placeholder: "Enter a Solana or Matic USDC wallet address",
                supportingText: "USDC addresses on Solana and Polygon are currently supported",
                isEnabled: !viewModel.isCreatingWallet,
                submitLabel: .continue,
                onSubmit: {
                    Task {
                        let result = await viewModel.createExternalWallet()
                        self.handleCreateResult(result)
                    }
                }
                // keyboardType: .
            )
            
//            Text("USDC addresses on Solana and Polygon are currently supported")
//                .font(themeManager.currentTheme.secondaryBodyFont)
//                .foregroundColor(themeManager.currentTheme.textMutedColor)
            
            Spacer()
            
            UrButton(
                text: "Connect Wallet",
                action: {
                    Task {
                        let result = await viewModel.createExternalWallet()
                        self.handleCreateResult(result)
                    }
                },
                enabled: viewModel.isValidWalletAddress && !viewModel.isCreatingWallet
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

#Preview {
    ConnectExternalWalletSheetView(
        onSuccess: {},
        api: nil
    )
        .environmentObject(ThemeManager.shared)
}
