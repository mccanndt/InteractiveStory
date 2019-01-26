//
//  ViewController.swift
//  InteractiveStory
//
//  Created by David McCann.
//  Copyright © David McCann. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var textFieldBottomConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Add observer for when the keyboard shows
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "startAdventure" {

            // Check the text field for a name and throw an error if it's empty.
            do {
                if let name = nameTextField.text {
                    if name == "" {
                        throw AdventureError.nameNotProvided
                    } else {
                        guard let pageController = segue.destination as? PageController else { return }

                        pageController.page = Adventure.story(withName: name)
                    }
                }
            } catch AdventureError.nameNotProvided {
                let alertController = UIAlertController(title: "Name Not Provided", message: "Provide a name to start your adventure!", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(action)

                present(alertController, animated: true, completion: nil)
            } catch let error {
                fatalError("\(error.localizedDescription)")
            }
        }
    }

    // Changes the bottom constraint of the text field to match the keyboard height so it's not hidden
    @objc func keyboardWillShow(_ notification: Notification) {
        if let info = notification.userInfo, let keyboardFrame = info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let frame = keyboardFrame.cgRectValue
            textFieldBottomConstraint.constant = frame.size.height

            // Animates the text field as the keyboard slides up
            UIView.animate(withDuration: 0.8) {
                self.view.layoutIfNeeded()
            }
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        textFieldBottomConstraint.constant = 40

        // Animates the text field as the keyboard slides down
        UIView.animate(withDuration: 0.8) {
            self.view.layoutIfNeeded()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
