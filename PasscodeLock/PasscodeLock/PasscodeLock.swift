//
//  PasscodeLock.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/28/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import Foundation
import LocalAuthentication

open class PasscodeLock: PasscodeLockType {
    open weak var delegate: PasscodeLockTypeDelegate?
    public let configuration: PasscodeLockConfigurationType

    open var repository: PasscodeRepositoryType {
        return configuration.repository
    }

    open var state: PasscodeLockStateType {
        return lockState
    }

    open var isTouchIDAllowed: Bool {
        return isTouchIDEnabled() && configuration.isTouchIDAllowed && lockState.isTouchIDAllowed
    }

    private var lockState: PasscodeLockStateType
    private lazy var passcode = String()

    public init(state: PasscodeLockStateType, configuration: PasscodeLockConfigurationType) {
        precondition(configuration.passcodeLength > 0, "Passcode length sould be greather than zero.")

        lockState = state
        self.configuration = configuration
    }

    open func addSign(_ sign: String) {
        passcode.append(sign)
        delegate?.passcodeLock(self, addedSignAt: passcode.count - 1)

        if passcode.count >= configuration.passcodeLength {
            lockState.accept(passcode: passcode, from: self)
            passcode.removeAll(keepingCapacity: true)
        }
    }

    open func removeSign() {
        guard passcode.count > 0 else { return }
        passcode.remove(at: passcode.index(before: passcode.endIndex))
        delegate?.passcodeLock(self, removedSignAt: passcode.utf8.count)
    }

    open func changeState(_ state: PasscodeLockStateType) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.lockState = state
            strongSelf.delegate?.passcodeLockDidChangeState(strongSelf)
        }
    }

    open func authenticateWithTouchID() {
        guard isTouchIDAllowed else { return }

        let context = LAContext()
        let reason = localizedStringFor(key: "PasscodeLockTouchIDReason", comment: "TouchID authentication reason")

        context.localizedFallbackTitle = localizedStringFor(key: "PasscodeLockTouchIDButton", comment: "TouchID authentication fallback button")

        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
            success, error in

            self.handleTouchIDResult(success)
        }
    }

    private func handleTouchIDResult(_ success: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard success, let strongSelf = self else { return }
            strongSelf.delegate?.passcodeLockDidSucceed(strongSelf)
        }
    }

    private func isTouchIDEnabled() -> Bool {
        let context = LAContext()
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
}
