//
//  ContentView.swift
//  LocalAuthenticationTest
//
//  Created by Hiroaki Tomiyoshi on 2023/02/02.
//

import SwiftUI
import LocalAuthentication

struct ContentView: View {
    @State private var context: LAContext = .init()
    
    @State private var policy: String = LAPolicy.deviceOwnerAuthentication.description
    @State private var biometryType: LABiometryType?
    @State private var evaluatedPolicyDomainState: Data?
    
    @State private var localizedReason: String = "localizedReason"
    
    @State private var localizedFallbackTitle: String = "localizedFallbackTitle"
    @State private var localizedFallbackTitleEnabled: Bool = false
    
    @State private var localizedCancelTitle: String = "localizedCancelTitle"
    @State private var localizedCancelTitleEnabled: Bool = false
    
    @State private var touchIDAuthenticationAllowableReuseDuration: String = "0"
    @State private var touchIDAuthenticationAllowableReuseDurationEnabled: Bool = false
    
    @State private var canEvaluatePolicyResult: Result<Void, Error>?
    @State private var evaluatePolicyResult: Result<Void, Error>?
    
    @State private var isAlertPresented = false
    @State private var alertMessage: String = ""
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading) {
                    Text("policy")
                        .font(.headline)
                    Picker("", selection: $policy) {
                        ForEach(
                            [
                                LAPolicy.deviceOwnerAuthentication.description,
                                LAPolicy.deviceOwnerAuthenticationWithBiometrics.description
                            ],
                            id: \.self
                        ) { policy in
                            Text(policy).tag(policy)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .labelsHidden()
                }
                
                VStack(alignment: .leading) {
                    Button("canEvaluatePolicy()") {
                        canEvaluatePolicy()
                    }
                    .buttonStyle(RoundedButtonStyle())
                    
                    if let result = self.canEvaluatePolicyResult {
                        switch result {
                        case .success(_):
                            Text("Success")
                            
                        case .failure(let error):
                            Text(String(describing: error))
                        }
                    } else {
                        Text("---")
                    }
                }
            }
            
            Section {
                VStack(alignment: .leading) {
                    Button("biometryType") {
                        self.biometryType = context.biometryType
                    }
                    .buttonStyle(RoundedButtonStyle())
                    
                    if let biometryType = self.biometryType {
                        switch biometryType {
                        case .touchID: Text("touchID")
                        case .faceID: Text("faceID")
                        case .none: Text("none")
                        @unknown default: fatalError()
                        }
                    } else {
                        Text("---")
                    }
                }
            }
            
            Section {
                VStack(alignment: .leading) {
                    Button("evaluatedPolicyDomainState(Base64)") {
                        self.evaluatedPolicyDomainState = context.evaluatedPolicyDomainState
                    }
                    .buttonStyle(RoundedButtonStyle())
                    
                    if let evaluatedPolicyDomainState = self.evaluatedPolicyDomainState {
                        Text(evaluatedPolicyDomainState.base64EncodedString())
                    } else {
                        Text("---")
                    }
                }
            }

            
            Section {
                VStack(alignment: .leading) {
                    Text("localizedReason *")
                        .font(.headline)
                    TextField("localizedReason", text: $localizedReason)
                        .textFieldStyle(.roundedBorder)
                }
                
                VStack(alignment: .leading) {
                    Toggle("localizedFallbackTitle", isOn: $localizedFallbackTitleEnabled)
                        .font(.headline)
                    if localizedFallbackTitleEnabled {
                        TextField("localizedFallbackTitle", text: $localizedFallbackTitle)
                            .textFieldStyle(.roundedBorder)
                    }
                }
                
                VStack(alignment: .leading) {
                    Toggle("localizedCancelTitle", isOn: $localizedCancelTitleEnabled)
                        .font(.headline)
                    if localizedCancelTitleEnabled {
                        TextField("localizedCancelTitle", text: $localizedCancelTitle)
                            .textFieldStyle(.roundedBorder)
                    }
                }
                
                VStack(alignment: .leading) {
                    Toggle("touchIDAuthenticationAllowableReuseDuration", isOn: $touchIDAuthenticationAllowableReuseDurationEnabled)
                        .font(.headline)
                    if touchIDAuthenticationAllowableReuseDurationEnabled {
                        TextField("touchIDAuthenticationAllowableReuseDuration", text: $touchIDAuthenticationAllowableReuseDuration)
                            .textFieldStyle(.roundedBorder)
                        Text("LATouchIDAuthenticationMaximumAllowableReuseDuration: \(LATouchIDAuthenticationMaximumAllowableReuseDuration)")
                    }
                }
                
                VStack(alignment: .leading) {
                    Button("evaluatePolicy()") {
                        evaluatePolicy()
                    }
                    .buttonStyle(RoundedButtonStyle())
                    
                    if let result = self.evaluatePolicyResult {
                        switch result {
                        case .success(_):
                            Text("Success")
                            
                        case .failure(let error):
                            Text(String(describing: error))
                        }
                    } else {
                        Text("---")
                    }
                }
            }
            
            Section {
                VStack(alignment: .leading) {
                    Button("Reset context") {
                        resetContext()
                    }
                    .buttonStyle(RoundedButtonStyle())
                    Text("LAContextを再生成します。")
                }
            }
            
        }
        .alert(isPresented: $isAlertPresented) {
            Alert(title: Text(alertMessage), dismissButton: .default(Text("OK")) {
                self.isAlertPresented = false
            })
        }
    }
    
    private func showAlert(message: String) {
        self.alertMessage = message
        self.isAlertPresented = true
    }
    
    private func resetContext() {
        self.context.invalidate()
        self.context = .init()
        self.biometryType = nil
        self.evaluatedPolicyDomainState = nil
        self.canEvaluatePolicyResult = nil
        self.evaluatePolicyResult = nil
    }
    
    private func validate() -> Bool {
        if localizedReason.isEmpty {
            showAlert(message: "値を入力してください(localizedReason)")
            return false
        }
        if !touchIDAuthenticationAllowableReuseDuration.isEmpty
            && TimeInterval(touchIDAuthenticationAllowableReuseDuration) == nil
        {
            showAlert(message: "数値を入力してください(touchIDAuthenticationAllowableReuseDuration)")
            return false
        }
        return true
    }
    
    private func canEvaluatePolicy() {
        guard let policy = LAPolicy(description: self.policy) else {
            print("Unexpected policy: \(self.policy)")
            return
        }
        
        var error: NSError?
        let success = context.canEvaluatePolicy(policy, error: &error)
        
        print("success: \(success), error: \(String(describing: error))")
        if success {
            self.canEvaluatePolicyResult = .success(())
        } else if let error = error {
            self.canEvaluatePolicyResult = .failure(error)
        } else {
            self.canEvaluatePolicyResult = .failure(NSError())
        }
    }
    
    private func evaluatePolicy() {
        guard validate() else {
            print("Validation Error")
            return
        }
        
        guard let policy = LAPolicy(description: self.policy) else {
            print("Unexpected policy: \(self.policy)")
            return
        }
        
        if self.localizedFallbackTitleEnabled { context.localizedFallbackTitle = self.localizedFallbackTitle }
        if self.localizedCancelTitleEnabled { context.localizedCancelTitle = self.localizedCancelTitle }
        if self.touchIDAuthenticationAllowableReuseDurationEnabled { context.touchIDAuthenticationAllowableReuseDuration = TimeInterval(self.touchIDAuthenticationAllowableReuseDuration)! }
        
        context.evaluatePolicy(policy, localizedReason: self.localizedReason) { success, error in
            print("success: \(success), error: \(String(describing: error))")
            if success {
                self.evaluatePolicyResult = .success(())
            } else if let error = error {
                self.evaluatePolicyResult = .failure(error)
            } else {
                self.evaluatePolicyResult = .failure(NSError())
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
