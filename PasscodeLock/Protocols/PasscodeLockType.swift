//
//  PasscodeLockType.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/28/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import Foundation

public protocol PasscodeLock {
    
    weak var delegate: PasscodeLockDelegate? { get set }
    var configuration: PasscodeLockConfiguration { get }
    var repository: PasscodeRepository { get }
    var state: PasscodeLockState { get }
    var isTouchIDAllowed: Bool { get }
    
    func addSign(_ sign: String)
    func removeSign()
    func changeState(_ state: PasscodeLockState)
    func authenticateWithTouchID()
}

public protocol PasscodeLockDelegate: class {
    
    func passcodeLockDidSucceed(_ lock: PasscodeLock)
    func passcodeLockDidFail(_ lock: PasscodeLock)
    func passcodeLockDidChangeState(_ lock: PasscodeLock)
    func passcodeLock(_ lock: PasscodeLock, addedSignAt index: Int)
    func passcodeLock(_ lock: PasscodeLock, removedSignAt index: Int)
}
