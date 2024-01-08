//
//  ConsentView.swift
//  DemoApp
//
//  Created by Thuong Nguyen on 26/12/2023.
//  Copyright © 2023 LAVA. All rights reserved.
//

import SwiftUI
import Combine

struct AppConsentToggle: Identifiable {
    var id: AppConsent
    var enabled: Bool
}

struct ConsentView: View {
    
    let dismiss: (() -> Void)?
    @State var appConsentToggles: [AppConsentToggle] = { 
        var enabledSet = AppSession.current.appConsent ?? []
        
        return AppConsent.allCases.map { appConsent in
            AppConsentToggle(id: appConsent, enabled: enabledSet.contains(appConsent))
        }
    }()
    
    @State var hasError: Bool = false
    @State var error: Error? = nil
    
    var isCheckedAll: Bool {
        return appConsentToggles.filter { $0.enabled }.count == AppConsent.allCases.count
    }
    
    func getAppConsentToggles() -> [AppConsentToggle] {
        var enabledSet = AppSession.current.appConsent ?? []
        
        return AppConsent.allCases.map { appConsent in
            AppConsentToggle(id: appConsent, enabled: enabledSet.contains(appConsent))
        }
    }
    
    func updateConsent(appConsent: AppConsent, isSelected: Bool) {
        var appConsentList = AppSession.current.appConsent ?? Set()
        if (isSelected) {
            appConsentList.insert(appConsent)
        } else {
            appConsentList.remove(appConsent)
        }
        
        ConsentUtils.updateLavaConsent(consentFlags: appConsentList) { err in
            if err != nil {
                hasError = true
                error = err
                appConsentToggles = getAppConsentToggles()
                return
            }
            AppSession.current.appConsent = appConsentList
        }
    }
    
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Button {
                    dismiss?()
                } label: {
                    Image(systemName: "arrow.backward")
                }
                .foregroundColor(.black)
                .frame(width: 60, height: 60)
                
                Text(
                    "Consent Preferences"
                )
                .font(.system(size: 18, weight: .bold))
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 60))
                .frame(maxWidth: .infinity)
            }
            
            Form {
                ForEach($appConsentToggles) { $item in
                    Toggle(item.id.rawValue, isOn: $item.enabled)
                        .onChange(of: item.enabled) { isOn in
                            updateConsent(appConsent: item.id, isSelected: isOn)
                        }
                }
                
                Section {
                    Button {
                        appConsentToggles = appConsentToggles.map { item in
                            AppConsentToggle(id: item.id, enabled: !isCheckedAll)
                        }
                    } label: {
                        Text(isCheckedAll ? "Uncheck All" : "Check All")
                            .foregroundColor(.red)
                    }
                }
            }
            
            Spacer()
        }
        .alert(isPresented: $hasError, content: {
            Alert(
                title: Text("Consent Error"),
                message: Text(error?.localizedDescription ?? "Unknown consent error"),
                dismissButton: .default(Text("Close"))
            )
        })
        
        
    }
}

struct ConsentView_Previews: PreviewProvider {
    static var previews: some View {
        ConsentView(dismiss: nil)
    }
}
