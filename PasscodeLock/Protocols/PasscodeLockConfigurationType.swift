//
//  PasscodeLockConfigurationType.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/28/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import Foundation

public protocol PasscodeLockConfigurationType {
    var repository: PasscodeRepositoryType { get }
    var passcodeLength: Int { get }
    var isTouchIDAllowed: Bool { get set }
    var shouldRequestTouchIDImmediately: Bool { get }
    var maximumIncorrectPasscodeAttempts: Int { get }
    func getIncorrectPasscodeAttempts() -> Int
    func setIncorrectPasscodeAttempts(_ value: Int)
}

private let incorrectPasscodeAttemptsKey = "incorrectPasscodeAttempts"

extension PasscodeLockConfigurationType {
    public func getIncorrectPasscodeAttempts() -> Int {
        return UserDefaults.standard.integer(forKey: incorrectPasscodeAttemptsKey)
    }

    public func setIncorrectPasscodeAttempts(_ value: Int) {
        UserDefaults.standard.set(value, forKey: incorrectPasscodeAttemptsKey)
    }
}
