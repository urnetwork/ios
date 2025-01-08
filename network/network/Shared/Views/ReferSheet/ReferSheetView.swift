//
//  ReferSheet.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2025/01/03.
//

// TODO: keeping this as a reference, but once we have another modal, this can be ditched

import SwiftUI
import URnetworkSdk
import CoreImage.CIFilterBuiltins

struct ReferSheet: View {
    
    @EnvironmentObject var themeManager: ThemeManager
    // @StateObject var viewModel: ViewModel
    let referralCode = "https://ur.io"
    
    init(api: SdkApi) {
        // _viewModel = StateObject(wrappedValue: ViewModel(api: api))
    }
    
    var body: some View {
        ZStack {
            
            Image("ReferBackground")
                .resizable()
                .scaledToFill()
                .frame(minWidth: 0)
                .edgesIgnoringSafeArea(.all)
            

            VStack {
             
                Spacer()
                
                VStack {
                    
                    HStack {
                        Image("ur.symbols.globe")
                        
                        Spacer()
                    }
                    
                    Spacer().frame(height: 12)
                    
                    HStack {
                        Text("Refer friends")
                            .foregroundColor(themeManager.currentTheme.inverseTextColor)
                            .font(themeManager.currentTheme.titleFont)
                        Spacer()
                    }
                    
                    Spacer().frame(height: 8)
                    
                    HStack {
                        Text("More connections help our community stay anonymous (and help you earn!)")
                            .font(themeManager.currentTheme.bodyFont)
                            .foregroundColor(themeManager.currentTheme.inverseTextColor)
                        
                        Spacer()
                    }
                    
                    Spacer().frame(height: 18)
                    
                    // if let referralCode = viewModel.referralCode {
                
                        Image(uiImage: generateQRCode(from: referralCode))
                            .interpolation(.none)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .cornerRadius(12)
                        
                        Spacer().frame(height: 18)
                    
                        ShareLink(item: URL(string: "https://ur.io/app?bonus=$\(referralCode)")!, subject: Text("URnetwork Referral Code"), message: Text("All the content in the world from URnetwork")) {
                            
                            
                            // Label("Share", systemImage: "square.and.arrow.up")
                            
                            
//                            Button(action: {
//                                action()
//                            }) {
//                                HStack {
//                                    Text(text)
//                                        .foregroundColor(foregroundColor)
//                                        .font(
//                                            themeManager.currentTheme.toolbarTitleFont.bold()
//                                        )
//                                    
//                                    if let trailingIcon {
//                                        Image(trailingIcon)
//                                    }
//                                }
//                                .frame(maxWidth: isFullWidth ? .infinity : nil)
//                                .frame(height: 48)
//                                .padding(.horizontal, 32)
//                            }
                            
                            HStack(alignment: .center) {
                                Text("Share")
                                    .foregroundColor(themeManager.currentTheme.textColor)
                                    .font(
                                        themeManager.currentTheme.toolbarTitleFont.bold()
                                    )
                                
                                
                                Image(systemName: "square.and.arrow.up")
                                    .foregroundColor(themeManager.currentTheme.textColor)
                                
                            }
                            // .frame(maxWidth: isFullWidth ? .infinity : nil)
                            .frame(height: 48)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 32)
                            .background(themeManager.currentTheme.accentColor)
                            .cornerRadius(100)
                            
                        }
                        
//                    } else {
//                        ProgressView()
//                            .progressViewStyle(CircularProgressViewStyle())
//                    }
            
                }
                .padding(24)
                .background(.urGreen)
                .cornerRadius(12)
                .padding()
                
            }
            
        }
    }
    
    func generateQRCode(from string: String) -> UIImage {
        
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        
        filter.message = Data(string.utf8)

        if let outputImage = filter.outputImage {
            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }

        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
}

#Preview {
    ReferSheet(
        api: SdkApi()
    )
        .environmentObject(ThemeManager.shared)
}
