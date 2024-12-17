//
//  FeedbackView.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/12/10.
//

import SwiftUI
import URnetworkSdk

struct FeedbackView: View {
    
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var snackbarManager: UrSnackbarManager
    @StateObject private var viewModel: ViewModel
    
    init(api: SdkBringYourApi?) {
        _viewModel = StateObject.init(wrappedValue: ViewModel(
            api: api
        ))
    }
    
    var body: some View {
        
        VStack {
            
            HStack {
                Text("Get in touch")
                    .font(themeManager.currentTheme.titleFont)
                    .foregroundColor(themeManager.currentTheme.textColor)
                Spacer()
            }
            
            Spacer().frame(height: 64)
            
            HStack {
                Text("Send us your feedback directly or ") + Text("[join our Discord](https://discord.com/invite/RUNZXMwPRK)") + Text(" for direct support.")
                
                Spacer()
            }
            .foregroundColor(themeManager.currentTheme.textColor)
            
            Spacer().frame(height: 32)
            
            HStack {
                UrLabel(text: "Feedback")
                Spacer()
            }
            
            UrTextEditor(
                text: $viewModel.feedback,
                enabled: !viewModel.isSending
            )

            Spacer()
            
            UrButton(
                text: "Send",
                action: {
                    
                    Task {
                        let result = await viewModel.sendFeedback()
                        self.handleSendFeedbackResult(result)
                    }
                    
                }
            )
            
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(themeManager.currentTheme.backgroundColor)
    }
    
    private func handleSendFeedbackResult(_ result: Result<Void, Error>) {
        
        UIApplication.shared.endEditing(true)
        
        
        switch result {
        case .success:
            
            // TODO: message sent overlay
            
            snackbarManager.showSnackbar(message: "Sent! Thanks for your feedback.")
        case .failure:
            snackbarManager.showSnackbar(message: "There was an error sending your feedback. Please try again later.")
        }
    }
}

#Preview {
    FeedbackView(
        api: nil
    )
    .environmentObject(ThemeManager.shared)
}
