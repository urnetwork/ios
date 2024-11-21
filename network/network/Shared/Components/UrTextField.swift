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
    var placeholder: String
    
    // field is enabled
    var isEnabled: Bool = true
    
    // text field label
    var label: String
    
    // input is correct
    var isValid: Bool = true
    
    // adds supporting text below the text field divider
    var supportingText: String?

    var onTextChange: ((String) -> Void)?

    var body: some View {
        VStack(alignment: .leading) {
            
            // label
            Text(label)
                .font(themeManager.currentTheme.secondaryBodyFont)
                .foregroundColor(isValid ? themeManager.currentTheme.textMutedColor : themeManager.currentTheme.dangerColor)
            
            // textfield row
            HStack {
                TextField(
                    "",
                    text: $text,
                    prompt: Text(placeholder)
                        .font(themeManager.currentTheme.bodyFont)
                        .foregroundColor(themeManager.currentTheme.textFaintColor)
                )
                .foregroundColor(.white)
                .disabled(!isEnabled)
                .focused($isFocused)
                .onChange(of: text) { newValue in
                    onTextChange?(newValue)
                }
                
                if !isValid {
                    Image("ur.symbols.warning")
                        .foregroundColor(themeManager.currentTheme.dangerColor)
                }
            }
        
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
                    .foregroundColor(isValid ? themeManager.currentTheme.textMutedColor : themeManager.currentTheme.dangerColor)
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
            isValid: false,
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
            isValid: true
        )
    }
    .environmentObject(themeManager)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .padding()
    .background(themeManager.currentTheme.systemBackground)
}
