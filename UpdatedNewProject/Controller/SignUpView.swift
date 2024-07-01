//
//  SignUpView.swift
//  UpdatedNewProject
//
//  Created by Nivedha Moorthy on 01/07/24.
//

import UIKit
import RealmSwift


class SignUpView: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmpassword: UITextField!
    @IBOutlet weak var alreadytext: UILabel!
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var signinBtn: UIButton!
    @IBOutlet weak var signupviewstack: UIStackView!
    @IBOutlet weak var logoimageview: UIImageView!
    var passwordAction = false
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupUI()
        self.navigationItem.setHidesBackButton(true, animated: true)
        setupKeyboardDismissal()
    }
    func setupUI() {
        alreadytext.text = "Already have an account?  "
        alreadytext.textColor = .white
        registerBtn.layer.cornerRadius = 5
        signupviewstack.layer.cornerRadius = 10
        logoimageview.layer.cornerRadius = 10
        self.username.keyboardType = .default
        signinBtn.addTarget(self, action: #selector(pressButton(button:)), for: .touchUpInside)
        self.email.rightViewMode = .always
        
        self.password.rightView = UIButton.systemButton(with: .init(systemName: "eye.slash") ?? .actions, target: self, action: #selector(passwordTextfeildTapped(sender: )))
        self.password.rightView?.tintColor = .black
    }
    
    func setupKeyboardDismissal() {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func passwordTextfeildTapped(sender: UIButton){
        if(passwordAction == true){
            password.isSecureTextEntry = true
            password.rightView = UIButton.systemButton(with: .init(systemName: "eye.slash") ?? .actions, target: self, action: #selector(passwordTextfeildTapped(sender: )))
            password.rightView?.tintColor = .brown
            password.rightViewMode = .always
            
        }else{
            password.isSecureTextEntry = false
            password.rightView = UIButton.systemButton(with: .init(systemName: "eye") ?? .actions, target: self, action: #selector(passwordTextfeildTapped(sender: )))
            password.rightView?.tintColor = .brown
            password.rightViewMode = .always
        }
        passwordAction = !passwordAction
    }
    
    @IBAction func registerAction(_ sender: Any) {
        
        guard let username = username.text,
              let email = email.text,
              let password = password.text,let confirmPassword = confirmpassword.text else {
            print("Invalid input")
            return
        }
        
        if username.isEmpty {
            self.codeRed(title: "Alert", message: "Enter Username")
            return
        }
        
        if !isValidEmail(email) {
            self.codeRed(title: "Alert", message: "Enter valid Email")
            return
        }
        
        
        if password.count < 6 {
            self.codeRed(title: "Alert", message: "Password should be at least 6 characters long")
            return
        }
        
        if confirmPassword != password {
            self.codeRed(title: "Alert", message: "Passwords do not match")
            return
        }
        
        let user = User()
        user.username = username
        user.email = email
        user.password = password
        user.confpassword = password
        
        
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(user)
                print(realm.add(user))
                
            }
            print("User saved!")
            showSuccessMessage(on: self, title: "Success", message: "Registration successful.")
        } catch {
            print("Error saving user: \(error)")
        }
        
    }
    
    @objc func pressButton(button: UIButton) {
        navigateTo()
    }
    func showSuccessMessage(on viewController: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.navigateTo()
        })
        viewController.present(alert, animated: true, completion: nil)
    }
    
    func navigateTo() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.username{
            self.username.becomeFirstResponder()
        }
        else if textField == self.email{
            self.email.becomeFirstResponder()
        }
        else if textField == self.password{
            self.password.becomeFirstResponder()
        }
        else if textField == self.confirmpassword{
            self.confirmpassword.resignFirstResponder()
        }
        return true
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailcheck = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{0,9}"
        
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailcheck)
        return emailPred.evaluate(with: email)
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField ==  self.username{
            if self.username.text! != ""{
                self.username.backgroundColor = .white
            }
            else{
                self.username.backgroundColor = .red
            }
        }
        if textField ==  self.email{
            if isValidEmail(self.email.text!) == true{
                self.email.backgroundColor = .white
            }
            else{
                self.email.backgroundColor = .red
            }
        }
        
        return true
    }
    func codeRed(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "ok", style: UIAlertAction.Style.default,handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
}


