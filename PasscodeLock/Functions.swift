//
//  Functions.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/28/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import Foundation

func localizedStringFor(key: String, comment: String) -> String {

    let name = "PasscodeLock"
    let defaultString = NSLocalizedString(key, tableName: name, bundle: Bundle(for: PasscodeLock.self), comment: comment)

    return NSLocalizedString(key, tableName: name, bundle: Bundle.main, value: defaultString, comment: comment)
}

func bundleForResource(name: String, ofType type: String) -> Bundle {
    if Bundle.main.path(forResource: name, ofType: type) != nil {
        return .main
    }

    return Bundle(for: PasscodeLock.self)
}
