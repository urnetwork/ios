//
//  CreateNetworkVerifyView.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/11/27.
//
// OTP text field pulled from https://www.youtube.com/watch?v=E5LdH1MFrqQ
//

import SwiftUI
import URnetworkSdk

struct CreateNetworkVerifyView: View {
    
    
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var snackbarManager: UrSnackbarManager
    @StateObject private var viewModel: ViewModel
    
    // Keyboard state
    @FocusState private var isKeyboardShowing: Bool
    
    var userAuth: String
    
    // var authJwt: String
    
    let codeCount: Int = 6
    
    init(userAuth: String, api: SdkBringYourApi) {
        _viewModel = StateObject(wrappedValue: ViewModel(api: api))
        self.userAuth = userAuth
        // self.authJwt = authJwt
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            
            ScrollView(.vertical) {
                
                VStack {
                    
                    Text("You've got mail")
                        .font(themeManager.currentTheme.titleFont)
                        .foregroundColor(themeManager.currentTheme.textColor)
                    
                    Spacer().frame(height: 32)
                    
                    Text("Tell us who you really are. Enter the code we sent you to verify your identity.")
                        .font(themeManager.currentTheme.bodyFont)
                        .foregroundColor(themeManager.currentTheme.textMutedColor)
                    
                    Spacer().frame(height: 40)
                    
                    // OTP Text field
                    
                    HStack(spacing: 0) {
                        ForEach(0..<codeCount, id: \.self) { index in
                            OTPTextBox(index)
                        }
                    }.background {
                        // hidden textfield which holds the otp value
                        TextField("", text: $viewModel.otp)
                            .onChange(of: viewModel.otp) { newValue in
                                if newValue.count > codeCount {
                                    viewModel.otp = String(newValue.prefix(codeCount))
                                }
                            }
                            .keyboardType(.numberPad)
                            .frame(width: 1, height: 1)
                            .opacity(0.001)
                            .blendMode(.screen)
                            .focused($isKeyboardShowing)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .textContentType(.oneTimeCode)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isKeyboardShowing.toggle()
                    }
                    
                    Spacer().frame(height: 40)
                    
                    HStack {
                     
                        Text("Don't see it? ", comment: "Referring to the OTP code")
                            .foregroundColor(themeManager.currentTheme.textMutedColor)
                            .font(themeManager.currentTheme.secondaryBodyFont)
                        
                        
                        Button(action: {
                            Task {
                                let result = await viewModel.resendOtp(userAuth: userAuth)
                                
                                switch result {
                                case .success:
                                    snackbarManager.showSnackbar(message: "Verification code sent to \(userAuth)")
                                    break
                                case .failure(let error):
                                    print("error resending OTP \(error.localizedDescription)")
                                    
                                    snackbarManager.showSnackbar(message: "There was an error sending the verification code.")
                                    
                                    break
                                    
                                }
                            }
                        }) {
                            Text("Resend code")
                                .foregroundColor(themeManager.currentTheme.textColor)
                                .font(themeManager.currentTheme.secondaryBodyFont)
                        }
                        
                    }
                    
                }
                .padding()
                .frame(minHeight: geometry.size.height)
                .frame(maxWidth: 400)
                .frame(maxWidth: .infinity)
            }
        }
    }
    
    @ViewBuilder
    func OTPTextBox(_ index: Int) -> some View {
        ZStack {
            if viewModel.otp.count > index {
                let startIndex = viewModel.otp.startIndex
                let charIndex = viewModel.otp.index(startIndex, offsetBy: index)
                let charToString = String(viewModel.otp[charIndex])
                Text(charToString)
                    .font(Font.custom("PPNeueBit-Bold", size: 24))
            } else {
                Text(" ")
            }
        }
        .frame(width: 38, height: 38)
        .background {
            
            // let isFocused = (isKeyboardShowing && index == viewModel.opt.count - 1)
            let isFocused = (isKeyboardShowing && index == viewModel.otp.count)
            
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .stroke(
                    isFocused ? themeManager.currentTheme.accentColor : themeManager.currentTheme.textFaintColor,
                    lineWidth: isFocused ? 1 : 0.5
                )
                .animation(.easeInOut(duration: 0.2), value: isFocused)
        }
        .frame(maxWidth: .infinity)
    }
    
}

#Preview {
    ZStack {
        CreateNetworkVerifyView(
            userAuth: "",
            api: SdkBringYourApi()
        )
    }
    .environmentObject(ThemeManager.shared)
    .background(ThemeManager.shared.currentTheme.backgroundColor)
}
