//
//  EnterPasscodeState.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/28/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import Foundation

public let PasscodeLockIncorrectPasscodeNotification = "passcode.lock.incorrect.passcode.notification"

struct EnterPasscodeState: PasscodeLockStateType {
    
    let title: String
    let description: String
    let isCancellableAction: Bool
    var isTouchIDAllowed = true
    
    fileprivate var inccorectPasscodeAttempts = 0
    fileprivate var isNotificationSent = false
    
    init(allowCancellation: Bool = false) {
        
        isCancellableAction = allowCancellation
        title = localizedStringFor("PasscodeLockEnterTitle", comment: "Enter passcode title")
        description = localizedStringFor("PasscodeLockEnterDescription", comment: "Enter passcode description")
    }
    
    mutating func accept(passcode: String, from lock: PasscodeLockType) {
        
        do {
            if try lock.repository.check(passcode: passcode) {
            
                lock.delegate?.passcodeLockDidSucceed(lock)
            
            } else {
            
                inccorectPasscodeAttempts += 1
            
                if inccorectPasscodeAttempts >= lock.configuration.maximumInccorectPasscodeAttempts {
                
                    postNotification()
                }
            
                lock.delegate?.passcodeLockDidFail(lock)
            }
        } catch {
            print(error)
            return
        }
    }
    
    fileprivate mutating func postNotification() {
        
        guard !isNotificationSent else { return }
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: PasscodeLockIncorrectPasscodeNotification), object: nil)
        
        isNotificationSent = true
    }
}
