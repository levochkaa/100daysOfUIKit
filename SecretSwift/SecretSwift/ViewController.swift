// ViewController.swift

import UIKit
import LocalAuthentication

class ViewController: UIViewController {

    var rightBarBtnItem: UIBarButtonItem!

    @IBOutlet weak var secret: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Nothing to see here"
        rightBarBtnItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTapped))
        navigationItem.rightBarButtonItem = nil

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)

        notificationCenter.addObserver(self, selector: #selector(saveSecretMessage), name: UIApplication.willResignActiveNotification, object: nil)

        if KeychainWrapper.standard.string(forKey: "password") == nil {
            let ac = UIAlertController(title: "Create a password", message: nil, preferredStyle: .alert)
            ac.addTextField()
            ac.addAction(UIAlertAction(title: "Submit", style: .cancel) { _ in
                if let password = ac.textFields?.first?.text {
                    KeychainWrapper.standard.set(password, forKey: "password")
                }
            })
            present(ac, animated: true)
        }
    }

    @objc func doneTapped() {
        saveSecretMessage()
    }

    @objc func saveSecretMessage() {
        guard !secret.isHidden else { return }

        KeychainWrapper.standard.set(secret.text, forKey: "SecretMessage")
        secret.resignFirstResponder()
        secret.isHidden = true

        title = "Nothing to see here"
        navigationItem.rightBarButtonItem = nil
    }

    func unlockSecretMessage() {
        title = "Secret stuff!"
        navigationItem.rightBarButtonItem = rightBarBtnItem

        secret.isHidden = false
        secret.text = KeychainWrapper.standard.string(forKey: "SecretMessage") ?? ""
        secret.becomeFirstResponder()
    }

    @IBAction func authenticateTapped(_ sender: UIButton) {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "We want to be sure that your note is available only for you."

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                [weak self] success, authenticationError in

                DispatchQueue.main.async {
                    if success {
                        self?.unlockSecretMessage()
                    } else {
                        let ac = UIAlertController(title: "Enter password", message: nil, preferredStyle: .alert)
                        ac.addTextField()
                        ac.addAction(UIAlertAction(title: "Submit", style: .cancel) { _ in
                            if let password = ac.textFields?.first?.text,
                               let savedPassword = KeychainWrapper.standard.string(forKey: "password"),
                               password == savedPassword {
                                self?.unlockSecretMessage()
                            } else {
                                let ac = UIAlertController(title: "Wrong password!", message: nil, preferredStyle: .alert)
                                ac.addAction(UIAlertAction(title: "OK", style: .default))
                                self?.present(ac, animated: true)
                            }
                        })
                        self?.present(ac, animated: true)
                    }
                }
            }
        } else {
            let ac = UIAlertController(title: "Biometry unavailable", message: "Your device is not configured for biometric authentication.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(ac, animated: true)
        }
    }

    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardViewEndFrame = view.convert(keyboardValue.cgRectValue, from: view.window)

        secret.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        secret.scrollIndicatorInsets = secret.contentInset
        secret.scrollRangeToVisible(secret.selectedRange)
    }
}

