//
//  PasscodeLock.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/28/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import Foundation
import LocalAuthentication

open class DefaultPasscodeLock: PasscodeLock {
    
    open weak var delegate: PasscodeLockDelegate?
    open let configuration: PasscodeLockConfiguration
    
    open var repository: PasscodeRepository {
        return configuration.repository
    }
    
    open var state: PasscodeLockState {
        return lockState
    }
    
    open var isTouchIDAllowed: Bool {
        return isTouchIDEnabled() && configuration.isTouchIDAllowed && lockState.isTouchIDAllowed
    }
    
    private var lockState: PasscodeLockState
    private lazy var passcode = String()
    
    public init(state: PasscodeLockState, configuration: PasscodeLockConfiguration) {
        precondition(configuration.passcodeLength > 0, "Passcode length sould be greather than zero.")
        
        self.lockState = state
        self.configuration = configuration
    }
    
    open func addSign(_ sign: String) {
        
        passcode.append(sign)
        delegate?.passcodeLock(self, addedSignAt: passcode.count - 1)
        
        if passcode.count >= configuration.passcodeLength {
            if let newState = lockState.accept(passcode: passcode, from: self) {
                changeState(newState)
            }
            passcode.removeAll(keepingCapacity: true)
        }
    }
    
    open func removeSign() {
        guard passcode.count > 0 else { return }
        passcode.removeLast()
        delegate?.passcodeLock(self, removedSignAt: passcode.count)
    }
    
    open func changeState(_ state: PasscodeLockState) {
        lockState = state
        delegate?.passcodeLockDidChangeState(self)
    }
    
    open func authenticateWithTouchID() {
        guard isTouchIDAllowed else { return }
        
        let context = LAContext()
        let reason = localizedStringFor(key: "PasscodeLockTouchIDReason", comment: "TouchID authentication reason")

        context.localizedFallbackTitle = localizedStringFor(key: "PasscodeLockTouchIDButton", comment: "TouchID authentication fallback button")
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason, reply: handleTouchIDResult)
    }
    
    private func handleTouchIDResult(_ success: Bool, error: Error?) {
        DispatchQueue.main.async {
            if error != nil && success {
                self.delegate?.passcodeLockDidSucceed(self)
            }
        }
    }
    
    private func isTouchIDEnabled() -> Bool {
        return LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
}
