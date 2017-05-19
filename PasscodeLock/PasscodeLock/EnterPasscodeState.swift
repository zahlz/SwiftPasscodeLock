//
//  EnterPasscodeState.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/28/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import Foundation

public let PasscodeLockIncorrectPasscodeNotification = Notification.Name("passcode.lock.incorrect.passcode.notification")

struct EnterPasscodeState: PasscodeLockStateType {
    
    let title: String
    let description: String
    let isCancellableAction: Bool
    var isTouchIDAllowed = true
    
    fileprivate var incorrectPasscodeAttemptsKey = "incorrectPasscodeAttemps"
    private var incorrectPasscodeAttempts: Int {
        get {
            return UserDefaults.standard.integer(forKey: incorrectPasscodeAttemptsKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: incorrectPasscodeAttemptsKey)
        }
    }
    fileprivate var isNotificationSent = false
    
    init(allowCancellation: Bool = false) {
        
        isCancellableAction = allowCancellation
        title = localizedStringFor(key: "PasscodeLockEnterTitle", comment: "Enter passcode title")
        description = localizedStringFor(key: "PasscodeLockEnterDescription", comment: "Enter passcode description")
    }
    
    mutating func accept(passcode: String, from lock: PasscodeLockType) {
        if lock.repository.check(passcode: passcode) {
        
            lock.delegate?.passcodeLockDidSucceed(lock)
            
            incorrectPasscodeAttempts = 0
        
        } else {
        
            incorrectPasscodeAttempts += 1
        
            if incorrectPasscodeAttempts >= lock.configuration.maximumInccorectPasscodeAttempts {
            
                postNotification()
            }
        
            lock.delegate?.passcodeLockDidFail(lock)
        }
    }
    
    fileprivate mutating func postNotification() {
        
        guard !isNotificationSent else { return }
        
        NotificationCenter.default.post(name: PasscodeLockIncorrectPasscodeNotification, object: nil)
        
        isNotificationSent = true
    }
}
