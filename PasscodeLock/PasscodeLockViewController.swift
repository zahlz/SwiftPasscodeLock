//
//  PasscodeLockViewController.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/28/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import UIKit

open class PasscodeLockViewController: UIViewController, PasscodeLockDelegate {
    
    public enum LockState {
        case enter
        case set
        case change
        case remove
        
        func getState() -> PasscodeLockState {
            switch self {
            case .enter:
                return EnterPasscodeState()
            case .set:
                return SetPasscodeState()
            case .change:
                return ChangePasscodeState()
            case .remove:
                return RemovePasscodeState()
            }
        }
    }
    
    @IBOutlet open weak var titleLabel: UILabel?
    @IBOutlet open weak var descriptionLabel: UILabel?
    @IBOutlet open var placeholders: [PasscodeSignPlaceholderView] = [PasscodeSignPlaceholderView]()
    @IBOutlet open weak var cancelButton: UIButton?
    @IBOutlet open weak var deleteSignButton: UIButton?
    @IBOutlet open weak var touchIDButton: UIButton?
    @IBOutlet open weak var placeholdersX: NSLayoutConstraint?
    
    open var successCallback: ((_ lock: PasscodeLock) -> Void)?
    open var dismissCompletionCallback: (()->Void)?
    open var animateOnDismiss: Bool
    open var notificationCenter: NotificationCenter?
    
    internal let passcodeConfiguration: PasscodeLockConfiguration
    internal var passcodeLock: PasscodeLock
    internal var isPlaceholdersAnimationCompleted = true
    
    private var shouldTryToAuthenticateWithBiometrics = true
    
    // MARK: - Initializers
    
    public init(state: PasscodeLockState, configuration: PasscodeLockConfiguration, animateOnDismiss: Bool = true) {
        self.animateOnDismiss = animateOnDismiss
        
        passcodeConfiguration = configuration
        passcodeLock = DefaultPasscodeLock(state: state, configuration: configuration)
        
        let nibName = "PasscodeLockView"
        let bundle: Bundle = bundleForResource(name: nibName, ofType: "nib")
        
        super.init(nibName: nibName, bundle: bundle)
        
        passcodeLock.delegate = self
        notificationCenter = .default
    }
    
    public convenience init(state: LockState, configuration: PasscodeLockConfiguration, animateOnDismiss: Bool = true) {
        self.init(state: state.getState(), configuration: configuration, animateOnDismiss: animateOnDismiss)
    }
    
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        clearEvents()
    }
    
    // MARK: - View
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        updatePasscodeView()
        deleteSignButton?.isEnabled = false

        cancelButton?.setTitle(localizedStringFor(key: "PasscodeLockCancelButtonTitle", comment: "Cancel Button Title"), for: .normal)
        deleteSignButton?.setTitle(localizedStringFor(key: "PasscodeLockDeleteButtonTitle", comment: "Delete Button Title"), for: .normal)
        
        setupEvents()
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if shouldTryToAuthenticateWithBiometrics {
            authenticateWithTouchID()
        }
    }
    
    internal func updatePasscodeView() {
        titleLabel?.text = passcodeLock.state.title
        descriptionLabel?.text = passcodeLock.state.description
        cancelButton?.isHidden = !passcodeLock.state.isCancellableAction
        touchIDButton?.isHidden = !passcodeLock.isTouchIDAllowed
    }
    
    // MARK: - Events
    
    private func setupEvents() {
        notificationCenter?.addObserver(self, selector: #selector(appWillEnterForegroundHandler(_:)), name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
        notificationCenter?.addObserver(self, selector: #selector(appDidEnterBackgroundHandler(_:)), name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
    }
    
    private func clearEvents() {
        notificationCenter?.removeObserver(self, name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        notificationCenter?.removeObserver(self, name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
    }
    
    @objc open func appWillEnterForegroundHandler(_ notification: Notification) {
        authenticateWithTouchID()
    }
    
    @objc open func appDidEnterBackgroundHandler(_ notification: Notification) {
        shouldTryToAuthenticateWithBiometrics = false
    }
    
    // MARK: - Actions
    
    @IBAction func passcodeSignButtonTap(_ sender: PasscodeSignButton) {
        guard isPlaceholdersAnimationCompleted else { return }
        
        passcodeLock.addSign(sender.passcodeSign)
    }
    
    @IBAction func cancelButtonTap(_ sender: UIButton) {
        dismissPasscodeLock(passcodeLock)
    }
    
    @IBAction func deleteSignButtonTap(_ sender: UIButton) {
        passcodeLock.removeSign()
    }
    
    @IBAction func touchIDButtonTap(_ sender: UIButton) {
        passcodeLock.authenticateWithTouchID()
    }
    
    private func authenticateWithTouchID() {
        if passcodeConfiguration.shouldRequestTouchIDImmediately && passcodeLock.isTouchIDAllowed {
            passcodeLock.authenticateWithTouchID()
        }
    }
    
    internal func dismissPasscodeLock(_ lock: PasscodeLock, completionHandler: (() -> Void)? = nil) {
        // if presented as modal
        if presentingViewController?.presentedViewController == self {
            dismiss(animated: animateOnDismiss, completion: { [weak self] in
                self?.dismissCompletionCallback?()
                completionHandler?()
            })
            
            return
            
        // if pushed in a navigation controller
        } else {
            navigationController?.popViewController(animated: animateOnDismiss)
            dismissCompletionCallback?()
            completionHandler?()
        }
    }
    
    // MARK: - Animations
    
    internal func animateWrongPassword() {
        deleteSignButton?.isEnabled = false
        isPlaceholdersAnimationCompleted = false
        
        animatePlaceholders(placeholders, toState: .error)
        
        placeholdersX?.constant = -40
        view.layoutIfNeeded()
        
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.2,
            initialSpringVelocity: 0,
            options: [],
            animations: {
                self.placeholdersX?.constant = 0
                self.view.layoutIfNeeded()
            },
            completion: { completed in
                self.isPlaceholdersAnimationCompleted = true
                self.animatePlaceholders(self.placeholders, toState: .inactive)
        })
    }
    
    internal func animatePlaceholders(_ placeholders: [PasscodeSignPlaceholderView], toState state: PasscodeSignPlaceholderView.State) {
        placeholders.forEach { $0.animateState(state) }
        
    }
    
    private func animatePlacehodlerAtIndex(_ index: Int, toState state: PasscodeSignPlaceholderView.State) {
        guard index < placeholders.count && index >= 0 else { return }
        placeholders[index].animateState(state)
    }

    // MARK: - PasscodeLockDelegate
    
    open func passcodeLockDidSucceed(_ lock: PasscodeLock) {
        deleteSignButton?.isEnabled = true
        animatePlaceholders(placeholders, toState: .inactive)
        dismissPasscodeLock(lock, completionHandler: { [weak self] in
            self?.successCallback?(lock)
        })
    }
    
    open func passcodeLockDidFail(_ lock: PasscodeLock) {
        animateWrongPassword()
    }
    
    open func passcodeLockDidChangeState(_ lock: PasscodeLock) {
        updatePasscodeView()
        animatePlaceholders(placeholders, toState: .inactive)
        deleteSignButton?.isEnabled = false
    }
    
    open func passcodeLock(_ lock: PasscodeLock, addedSignAt index: Int) {
        animatePlacehodlerAtIndex(index, toState: .active)
        deleteSignButton?.isEnabled = true
    }
    
    open func passcodeLock(_ lock: PasscodeLock, removedSignAt index: Int) {
        animatePlacehodlerAtIndex(index, toState: .inactive)

        deleteSignButton?.isEnabled = index > 0
    }
}
