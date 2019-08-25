//
//  ErrorPresentable.swift
//  Networking
//
//  Created by Sateesh Yegireddi on 25/08/19.
//  Copyright © 2019 Company. All rights reserved.
//

import Foundation
import UIKit

protocol ErrorPresentable {
    func presentAlert(with field: Field?)
}

extension ErrorPresentable where Self: UIViewController {
    func presentAlert(with field: Field?) {
        DispatchQueue.main.async {
            var errorMessage: String? = ""
            switch field {
            case .response(let message): errorMessage = message
            default: errorMessage = field?.error.domain
            }
            let alert = UIAlertController(title: "",
                                          message: errorMessage,
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
}
