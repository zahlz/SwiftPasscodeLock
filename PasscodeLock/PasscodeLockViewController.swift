//
//  PasscodeLockViewController.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/28/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import UIKit

open class PasscodeLockViewController: UIViewController, PasscodeLockTypeDelegate {
    public enum LockState {
        case enter
        case set
        case change
        case remove

        func getState() -> PasscodeLockStateType {
            switch self {
            case .enter: return EnterPasscodeState()
            case .set: return SetPasscodeState()
            case .change: return ChangePasscodeState()
            case .remove: return RemovePasscodeState()
            }
        }
    }

    @IBOutlet open var titleLabel: UILabel?
    @IBOutlet open var descriptionLabel: UILabel?
    @IBOutlet open var placeholders: [PasscodeSignPlaceholderView] = [PasscodeSignPlaceholderView]()
    @IBOutlet open var cancelButton: UIButton?
    @IBOutlet open var deleteSignButton: UIButton?
    @IBOutlet open var touchIDButton: UIButton?
    @IBOutlet open var placeholdersX: NSLayoutConstraint?

    open var successCallback: ((_ lock: PasscodeLockType) -> Void)?
    open var dismissCompletionCallback: (() -> Void)?
    open var animateOnDismiss: Bool
    open var notificationCenter: NotificationCenter?

    internal let passcodeConfiguration: PasscodeLockConfigurationType
    internal var passcodeLock: PasscodeLockType
    internal var isPlaceholdersAnimationCompleted = true

    fileprivate var shouldTryToAuthenticateWithBiometrics = true

    // MARK: - Initializers

    public init(state: PasscodeLockStateType, configuration: PasscodeLockConfigurationType, animateOnDismiss: Bool = true) {
        self.animateOnDismiss = animateOnDismiss

        passcodeConfiguration = configuration
        passcodeLock = PasscodeLock(state: state, configuration: configuration)

        let nibName = "PasscodeLockView"
        let bundle: Bundle = bundleForResource(name: nibName, ofType: "nib")

        super.init(nibName: nibName, bundle: bundle)

        passcodeLock.delegate = self
        notificationCenter = NotificationCenter.default
    }

    public convenience init(state: LockState, configuration: PasscodeLockConfigurationType, animateOnDismiss: Bool = true) {
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

    fileprivate func setupEvents() {
        notificationCenter?.addObserver(self, selector: #selector(PasscodeLockViewController.appWillEnterForegroundHandler(_:)), name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
        notificationCenter?.addObserver(self, selector: #selector(PasscodeLockViewController.appDidEnterBackgroundHandler(_:)), name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
    }

    fileprivate func clearEvents() {
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

    fileprivate func authenticateWithTouchID() {
        if passcodeConfiguration.shouldRequestTouchIDImmediately && passcodeLock.isTouchIDAllowed {
            passcodeLock.authenticateWithTouchID()
        }
    }

    internal func dismissPasscodeLock(_ lock: PasscodeLockType, completionHandler: (() -> Void)? = nil) {
        // if presented as modal
        if presentingViewController?.presentedViewController == self {
            dismiss(animated: animateOnDismiss) { [weak self] in
                self?.dismissCompletionCallback?()
                completionHandler?()
            }
        } else {
            // if pushed in a navigation controller
            _ = navigationController?.popViewController(animated: animateOnDismiss)
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
            }
        )
    }

    internal func animatePlaceholders(_ placeholders: [PasscodeSignPlaceholderView], toState state: PasscodeSignPlaceholderView.State) {
        placeholders.forEach { $0.animateState(state) }
    }

    fileprivate func animatePlacehodlerAtIndex(_ index: Int, toState state: PasscodeSignPlaceholderView.State) {
        guard index < placeholders.count && index >= 0 else { return }

        placeholders[index].animateState(state)
    }

    // MARK: - PasscodeLockDelegate

    open func passcodeLockDidSucceed(_ lock: PasscodeLockType) {
        deleteSignButton?.isEnabled = true
        animatePlaceholders(placeholders, toState: .inactive)

        dismissPasscodeLock(lock) { [weak self] in
            self?.successCallback?(lock)
        }
    }

    open func passcodeLockDidFail(_ lock: PasscodeLockType) {
        animateWrongPassword()
    }

    open func passcodeLockDidChangeState(_ lock: PasscodeLockType) {
        updatePasscodeView()
        animatePlaceholders(placeholders, toState: .inactive)
        deleteSignButton?.isEnabled = false
    }

    open func passcodeLock(_ lock: PasscodeLockType, addedSignAt index: Int) {
        animatePlacehodlerAtIndex(index, toState: .active)
        deleteSignButton?.isEnabled = true
    }

    open func passcodeLock(_ lock: PasscodeLockType, removedSignAt index: Int) {
        animatePlacehodlerAtIndex(index, toState: .inactive)

        if index == 0 {
            deleteSignButton?.isEnabled = false
        }
    }
}
