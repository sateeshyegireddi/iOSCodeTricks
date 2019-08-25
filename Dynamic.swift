//
//  Dynamic.swift
//  Networking
//
//  Created by Sateesh Yegireddi on 25/08/19.
//  Copyright © 2019 Company. All rights reserved.
//

import Foundation

struct Dynamic<T> {
    
    typealias Listener = (T) -> Void
    
    var listener: Listener?
    
    var value: T {
        didSet {
            listener?(value)
        }
    }
    
    init(_ value: T) {
        self.value = value
    }
    
    mutating func bind(listener: Listener?) {
        self.listener = listener
    }
    
    mutating func bindAndFire(listener: Listener?) {
        self.listener = listener
        listener?(value)
    }
}
