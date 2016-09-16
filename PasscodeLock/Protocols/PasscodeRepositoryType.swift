//
//  PasscodeRepositoryType.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/28/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import Foundation

public protocol PasscodeRepositoryType {
    
    var hasPasscode: Bool { get }
    
    func savePasscode(_ passcode: String)
    func checkPasscode(_ passcode: String) throws -> Bool
    func deletePasscode()
}
