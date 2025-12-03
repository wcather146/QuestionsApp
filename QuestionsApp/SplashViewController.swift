//
//  SplashViewController.swift
//  QuestionsApp
//
//  Created by William Cather on 6/25/25.
//

// MARK: File - Views/SplashViewController.swift
import UIKit

class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // ONLY ONE navigation — after your splash animation finishes
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            self?.navigateAfterSplash()
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Questions\nPowered by \nEvan Terry Associates"
        label.textColor = .yellow
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.numberOfLines = 0
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func navigateAfterSplash() {
        guard let nav = navigationController else { return }
        
        nav.setNavigationBarHidden(false, animated: true)
        
        print("Splash → isAuthenticated: \(NetworkManager.shared.isAuthenticated)")
        
        if NetworkManager.shared.isAuthenticated {
            // Already logged in → skip login
            let welcomeVC = WelcomeScreenViewController()
            nav.setViewControllers([welcomeVC], animated: true)
        } else {
            // Show login
            let loginVC = LoginViewController()
            loginVC.onLoginSuccess = {
                nav.setViewControllers([WelcomeScreenViewController()], animated: true)
            }
            nav.setViewControllers([loginVC], animated: true)
        }
    }
}
