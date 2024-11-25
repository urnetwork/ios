//
//  UrTextField.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/11/20.
//

import SwiftUI

struct UrTextField: View {
    
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var text: String
    
    @FocusState private var isFocused: Bool
    
    // placeholder text
    var placeholder: LocalizedStringKey
    
    // field is enabled
    var isEnabled: Bool = true
    
    // text field label
    var label: LocalizedStringKey
    
    // input is correct
    var validationState: ValidationState?
    
    // adds supporting text below the text field divider
    var supportingText: LocalizedStringKey?

    var onTextChange: ((String) -> Void)?

    // keyboard type
    var keyboardType: UIKeyboardType = .default
    
    // submit label
    var submitLabel: SubmitLabel = .return

    var onSubmit: (() -> Void)?
    
    var isSecure: Bool = false
    
    var disableCapitalization: Bool = false
    

    private var autoCapitalization: TextInputAutocapitalization {
        
        if (disableCapitalization) {
            return .never
        } else {
            switch keyboardType {
            case .emailAddress:
                return .never
            default:
                return .sentences
            }
        }
    
    }
    
    private var shouldDisableAutocorrection: Bool {
        switch keyboardType {
        case .emailAddress:
            return true
        default:
            return false
        }
    }
    
    private var foregroundSupportColor: Color {
        
        if (validationState != nil) {
            
            if validationState == .invalid {
                return themeManager.currentTheme.dangerColor
            }
            
            return themeManager.currentTheme.textMutedColor
            
        } else {
            return themeManager.currentTheme.textMutedColor
        }
        
    }

    var body: some View {
        VStack(alignment: .leading) {
            
            // label
            Text(label)
                .font(themeManager.currentTheme.secondaryBodyFont)
                .foregroundColor(foregroundSupportColor)
            
            // textfield row
            HStack {
                
                if isSecure {
                    SecureField(
                        "",
                        text: $text,
                        prompt: Text(placeholder)
                            .font(themeManager.currentTheme.bodyFont)
                            .foregroundColor(themeManager.currentTheme.textFaintColor)
                    )
                    .tint(themeManager.currentTheme.textColor)
                    .submitLabel(submitLabel)
                    .onSubmit {
                        onSubmit?()
                    }
                    .keyboardType(keyboardType)
                    .textInputAutocapitalization(autoCapitalization)
                    .disableAutocorrection(shouldDisableAutocorrection)
                    .foregroundColor(themeManager.currentTheme.textColor)
                    .disabled(!isEnabled)
                    .focused($isFocused)
                    .onChange(of: text) { newValue in
                        onTextChange?(newValue)
                    }
                } else {
                    TextField(
                        "",
                        text: $text,
                        prompt: Text(placeholder)
                            .font(themeManager.currentTheme.bodyFont)
                            .foregroundColor(themeManager.currentTheme.textFaintColor)
                    )
                    .tint(themeManager.currentTheme.textColor)
                    .submitLabel(submitLabel)
                    .onSubmit {
                        onSubmit?()
                    }
                    .keyboardType(keyboardType)
                    .textInputAutocapitalization(autoCapitalization)
                    .disableAutocorrection(shouldDisableAutocorrection)
                    .foregroundColor(themeManager.currentTheme.textColor)
                    .disabled(!isEnabled)
                    .focused($isFocused)
                    .onChange(of: text) { newValue in
                        onTextChange?(newValue)
                    }
                }
                
                if (validationState != nil) {
                    
                    if validationState == .invalid {
                        Image("ur.symbols.warning")
                            .foregroundColor(themeManager.currentTheme.dangerColor)
                    }
                    
                    if validationState == .validating {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .frame(height: 24)
                    }
                }
            }
            .frame(height: 24)
        
            // divider
            if (isEnabled) {
                Divider()
                    .background(isFocused
                                ? themeManager.currentTheme.borderStrongColor :themeManager.currentTheme.borderBaseColor)
            }
        
            // should we show supporting text if input is disabled?
            if let supportingText {
                Text(supportingText)
                    .font(themeManager.currentTheme.secondaryBodyFont)
                    .foregroundColor(foregroundSupportColor)
            }
        }
    }
}

#Preview {
    
    var themeManager = ThemeManager.shared

    
    @State var emptyValue = ""
    @State var sampleValue = "lorem@ipsum.com"
    
    VStack {
        // empty text field
        UrTextField(
            text: $emptyValue,
            placeholder: "Placeholder",
            label: "Your email"
        )
        
        Spacer()
            .frame(height: 32)
        
        // populated
        UrTextField(
            text: $sampleValue,
            placeholder: "Placeholder",
            label: "Your email"
        )
        
        Spacer()
            .frame(height: 32)
        
        // populated with supporting text
        UrTextField(
            text: $sampleValue,
            placeholder: "Placeholder",
            label: "Your email",
            supportingText: "Network names must be 6 characters or more"
        )
        
        Spacer()
            .frame(height: 32)
        
        // error exists
        UrTextField(
            text: $sampleValue,
            placeholder: "Placeholder",
            label: "Your email",
            validationState: ValidationState.invalid,
            supportingText: "Network name is too short. Try one with at least 6 characters,"
        )
        
        Spacer()
            .frame(height: 32)
        
        // disabled input
        UrTextField(
            text: $sampleValue,
            placeholder: "Placeholder",
            isEnabled: false,
            label: "Your email",
            validationState: ValidationState.valid
        )
    }
    .environmentObject(themeManager)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .padding()
    .background(themeManager.currentTheme.systemBackground)
}

