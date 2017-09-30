//
//  FakePasscodeLockDelegate.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/28/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import Foundation

class FakePasscodeLockDelegate: PasscodeLockDelegate {
    
    func passcodeLockDidSucceed(_ lock: PasscodeLock) {}
    func passcodeLockDidFail(_ lock: PasscodeLock) {}
    func passcodeLockDidChangeState(_ lock: PasscodeLock) {}
    func passcodeLock(_ lock: PasscodeLock, addedSignAt index: Int) {}
    func passcodeLock(_ lock: PasscodeLock, removedSignAt index: Int) {}
}
