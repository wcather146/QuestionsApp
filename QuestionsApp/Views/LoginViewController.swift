//
//  LoginViewController.swift
//  QuestionsApp
//
//  Created by William Cather on 12/2/25.
//

// LoginViewController.swift
import UIKit

class LoginViewController: UIViewController {
    
    private let usernameLabel = UILabel()
        private let passwordLabel = UILabel()
        private let usernameField = UITextField()
        private let passwordField = UITextField()
        private let loginButton = UIButton(type: .system)
        private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    var onLoginSuccess: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func createLabeledField(label: UILabel, field: UITextField) -> UIView {
        let container = UIView()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        field.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(label)
        container.addSubview(field)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            
            field.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 10),
            field.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            field.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            field.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            field.heightAnchor.constraint(equalToConstant: 56)
        ])
        
        return container
    }

    private func setupUI() {
        view.backgroundColor = .black
        title = "Login"
        
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(container)
        
        // MARK: - Username Label (BIGGER & BOLDER)
        usernameLabel.text = "Username"
        usernameLabel.font = .boldSystemFont(ofSize: 22)           // Up from 16 → 22
        usernameLabel.textColor = .systemYellow
        usernameLabel.textAlignment = .left
        
        configureTextField(usernameField, placeholder: "Enter username", isSecure: false)
        usernameField.autocapitalizationType = .none
        usernameField.autocorrectionType = .no
        usernameField.keyboardType = .emailAddress
        
        // MARK: - Password Label (BIGGER & BOLDER)
        passwordLabel.text = "Password"
        passwordLabel.font = .boldSystemFont(ofSize: 22)           // Up from 16 → 22
        passwordLabel.textColor = .systemYellow
        passwordLabel.textAlignment = .left
        
        configureTextField(passwordField, placeholder: "Enter password", isSecure: true)
        //passwordField.isSecureTextEntry = true
        
        // Login Button (even punchier)
        loginButton.setTitle("LOGIN", for: .normal)
        loginButton.titleLabel?.font = .boldSystemFont(ofSize: 24)
        loginButton.setTitleColor(.black, for: .normal)
        loginButton.backgroundColor = .systemYellow
        loginButton.layer.cornerRadius = 16
        loginButton.heightAnchor.constraint(equalToConstant: 64).isActive = true
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .systemYellow
        
        let stackView = UIStackView(arrangedSubviews: [
            createLabeledField(label: usernameLabel, field: usernameField),
            createLabeledField(label: passwordLabel, field: passwordField),
            loginButton,
            activityIndicator
        ])
        stackView.axis = .vertical
        stackView.spacing = 32        // More breathing room
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            stackView.topAnchor.constraint(equalTo: container.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
    }
    
    private func configureTextField(_ tf: UITextField, placeholder: String, isSecure: Bool) {
        tf.placeholder = placeholder
        tf.isSecureTextEntry = isSecure
        tf.backgroundColor = UIColor(white: 0.15, alpha: 1)
        tf.textColor = .white
        tf.layer.cornerRadius = 12
        tf.heightAnchor.constraint(equalToConstant: 56).isActive = true
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        tf.leftViewMode = .always
        tf.font = .systemFont(ofSize: 18)
    }
    
    @objc private func loginTapped() {
        guard let username = usernameField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let password = passwordField.text,
              !username.isEmpty, !password.isEmpty else {
            showAlert(title: "Missing Info", message: "Please enter username and password")
            
            return
        }
                
        loginButton.isEnabled = false
        activityIndicator.startAnimating()
        
        // THIS IS THE ONLY CHANGE — now passes Void, not String
        NetworkManager.shared.login(username: username, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.loginButton.isEnabled = true
                self?.activityIndicator.stopAnimating()
                
                switch result {
                case .success:
                    print("Login successful")
                    self?.goToMainApp()
                    
                case .failure(let error):
                    print("Login failed: \(error)")
                    self?.showAlert(title: "Login Failed", message: error.localizedDescription)
                }
            }
        }
    }
    
    private func goToMainApp() {
        // This triggers the Welcome screen to appear after successful login
        onLoginSuccess?()
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
