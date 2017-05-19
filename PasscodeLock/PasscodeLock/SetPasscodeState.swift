//
//  SetPasscodeState.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/28/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import Foundation

struct SetPasscodeState: PasscodeLockStateType {
    
    let title: String
    let description: String
    let isCancellableAction = true
    var isTouchIDAllowed = false
    
    init(title: String, description: String) {
        
        self.title = title
        self.description = description
    }
    
    init() {
        
        title = localizedStringFor(key: "PasscodeLockSetTitle", comment: "Set passcode title")
        description = localizedStringFor(key: "PasscodeLockSetDescription", comment: "Set passcode description")
    }
    
    func accept(passcode: String, from lock: PasscodeLockType) {
        
        lock.changeState(ConfirmPasscodeState(passcode: passcode))

    }
}
