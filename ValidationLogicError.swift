//
//  ValidationLogicError.swift
//  iOSConcepts
//
//  Created by Sateesh Yegireddi on 24/08/19.
//  Copyright © 2019 Company. All rights reserved.
//

import Foundation

enum Field {
    case email
    case password
    
    var requirements: (error: String, code: Int, regex: String) {
        switch self {
        case .email:
            return ("Please enter valid email",
                    100,
                    "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$")
        case .password:
            return ("Please enter valid password",
                    101,
                    "^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#$%^&*<>?~_]).{8,20}$")
        }
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
            //TODO: Show Alert here
            print(validation.error.domain)
            return
        }
    }
}

validate()
