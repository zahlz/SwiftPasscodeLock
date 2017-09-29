//
//  ConfirmPasscodeState.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/28/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import Foundation

struct ConfirmPasscodeState: PasscodeLockState {
    
    let title: String
    let description: String
    let isCancellableAction = true
    var isTouchIDAllowed = false
    
    private var passcodeToConfirm: String
    
    init(passcode: String) {
        passcodeToConfirm = passcode
        title = localizedStringFor(key: "PasscodeLockConfirmTitle", comment: "Confirm passcode title")
        description = localizedStringFor(key: "PasscodeLockConfirmDescription", comment: "Confirm passcode description")
    }
    
    func accept(passcode: String, from lock: PasscodeLock) -> PasscodeLockState? {
        if passcode == passcodeToConfirm {
            lock.repository.save(passcode: passcode)
            lock.delegate?.passcodeLockDidSucceed(lock)
            return nil
        } else {
            let mismatchTitle = localizedStringFor(key: "PasscodeLockMismatchTitle", comment: "Passcode mismatch title")
            let mismatchDescription = localizedStringFor(key: "PasscodeLockMismatchDescription", comment: "Passcode mismatch description")
            
            lock.delegate?.passcodeLockDidFail(lock)
            return SetPasscodeState(title: mismatchTitle, description: mismatchDescription)
        }
    }
}
