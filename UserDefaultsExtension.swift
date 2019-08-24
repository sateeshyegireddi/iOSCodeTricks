//
//  UserDefaultsExtension.swift
//  iOSConcepts
//
//  Created by Sateesh Yegireddi on 24/08/19.
//  Copyright © 2019 Company. All rights reserved.
//

import Foundation

extension UserDefaults {
    private enum Key: String {
        case deviceToken
    }
    
    private static var defaults: UserDefaults {
        return UserDefaults.standard
    }
    
    static func saveDeviceToken(_ value: String?) {
        defaults.set(value, forKey: Key.deviceToken.rawValue)
        defaults.synchronize()
    }
    
    static var deviceToken: String {
        defaults.value(forKey: Key.deviceToken.rawValue) as? String ?? ""
    }
}

UserDefaults.saveDeviceToken("95SFDS898-FDSJ600SD-SDS767SDF-877SDFS90")
UserDefaults.deviceToken
