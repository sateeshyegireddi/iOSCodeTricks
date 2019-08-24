//
//  ValidationLogicError.swift
//  iOSConcepts
//
//  Created by Sateesh Yegireddi on 24/08/19.
//  Copyright © 2019 Company. All rights reserved.
//

import Foundation

enum Field: Hashable, Error {
    case email
    case password
    case name
    case mobile
    case otp
    
    case noData
    case JSON
    case response(String)

    var requirements: (error: String, code: Int, regex: String) {
        switch self {
        case .email:
            return ("Please enter valid email",
                    100,
                    "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}"
                        + "[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
            )
        case .password:
            return ("Please enter valid password",
                    101,
                    "^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#$%^&*<>?~_]).{8,20}$"
            )
        case .name:
            return ("Please enter valid name",
                    102,
                    "^[a-z,A-Z, ]{5,70}$"
            )
        case .mobile:
            return ("Please enter valid mobile number",
                    103,
                    "^\\d{10}$"
            )
        case .otp:
            return ("Please enter valid OTP",
                    104,
                    "[0-9]{6}"
            )
            
        case .noData:
            return ("No data has been received from server.", 400, "")
        case .JSON:
            return ("Error occured while parsing JSON response.", 400, "")
        case .response(_):
            return ("Error while receiving response from server.", 400, "")
        }
    }
    
    static func error(_ message: String) -> Self {
        let field = Field.response(message)
        return field
    }
}

extension Field {
    var error: NSError {
        return NSError(domain: requirements.error, code: requirements.code, userInfo: nil)
    }
    
    func validateString(_ string: String?) -> Field? {
        let predicate = NSPredicate(format:"SELF MATCHES %@", requirements.regex)
        let isValid = predicate.evaluate(with: string)
        return isValid ? nil : self
    }
}

let email = "sateesh@gmail.com"
let password = "Sateesh@123"

func validate() {
    let fields = [Field.email: email,
                  Field.password: password]
    
    fields.forEach { field in
        if let validation = field.key.validateString(field.value) {
            print(validation.error.domain)
            return
        }
    }
}

//validate()
