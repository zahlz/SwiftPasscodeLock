//
//  FakePasscodeLock.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/28/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import Foundation

class FakePasscodeLock: PasscodeLock {
    
    weak var delegate: PasscodeLockDelegate?
    let configuration: PasscodeLockConfiguration
    var repository: PasscodeRepository { return configuration.repository }
    var state: PasscodeLockState { return lockState }
    let isTouchIDAllowed = false
    var lockState: PasscodeLockState
    
    var changeStateCalled = false
    
    init(state: PasscodeLockState, configuration: PasscodeLockConfiguration) {
        
        self.lockState = state
        self.configuration = configuration
    }
    
    func addSign(_ sign: String) {
        
    }
    
    func removeSign() {
        
    }
    
    func changeState(_ state: PasscodeLockState) {
        
        lockState = state
        changeStateCalled = true
        delegate?.passcodeLockDidChangeState(self)
    }
    
    func authenticateWithTouchID() {
        
    }
}
