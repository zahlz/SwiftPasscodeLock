//
//  PasscodeLockConfiguration.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/29/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import Foundation
import PasscodeLock

struct DemoPasscodeLockConfiguration: PasscodeLockConfiguration {
    
    let repository: PasscodeRepository
    let passcodeLength = 4
    var isTouchIDAllowed = true
    let shouldRequestTouchIDImmediately = true
    let maximumInccorectPasscodeAttempts = -1
    
    init(repository: PasscodeRepository) {
        
        self.repository = repository
    }
    
    init() {
        
        self.repository = UserDefaultsPasscodeRepository()
    }
}
