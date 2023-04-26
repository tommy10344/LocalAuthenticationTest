//
//  ButtonStyles.swift
//  LocalAuthenticationTest
//
//  Created by Hiroaki Tomiyoshi on 2023/04/12.
//

import SwiftUI

struct RoundedButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
            .frame(maxWidth: .infinity)
            .background(configuration.isPressed ? Color.accentColor.opacity(0.7) : Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(10)
    }
}
