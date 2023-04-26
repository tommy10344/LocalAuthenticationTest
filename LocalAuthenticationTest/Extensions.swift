//
//  Extensions.swift
//  LocalAuthenticationTest
//
//  Created by Hiroaki Tomiyoshi on 2023/04/26.
//

import Foundation
import LocalAuthentication

extension LAPolicy: Identifiable {
    public typealias ID = String
    public var id: String { description }
}

extension LAPolicy: CustomStringConvertible {
    init?(description: String) {
        switch description {
        case "deviceOwnerAuthentication":
            self = .deviceOwnerAuthentication
        case "deviceOwnerAuthenticationWithBiometrics":
            self = .deviceOwnerAuthenticationWithBiometrics
        default:
            return nil
        }
    }
    
    public var description: String {
        switch self {
        case .deviceOwnerAuthentication:
            return "deviceOwnerAuthentication"
        case .deviceOwnerAuthenticationWithBiometrics:
            return "deviceOwnerAuthenticationWithBiometrics"
        @unknown default:
            return "unknown"
        }
    }
}

