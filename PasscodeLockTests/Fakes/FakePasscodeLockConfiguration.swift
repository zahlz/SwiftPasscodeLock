//
//  FakePasscodeLockConfiguration.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/28/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import Foundation

class FakePasscodeLockConfiguration: PasscodeLockConfiguration {
    
    let repository: PasscodeRepository
    let passcodeLength = 4
    var isTouchIDAllowed = false
    let maximumInccorectPasscodeAttempts = 3
    let shouldRequestTouchIDImmediately = false
    
    init(repository: PasscodeRepository) {
        
        self.repository = repository
    }
}
