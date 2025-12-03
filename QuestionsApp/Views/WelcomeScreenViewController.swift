//
//  WelcomeScreenViewController.swift
//  QuestionsApp
//
//  Created by William Cather on 7/31/25.
//

import UIKit

class WelcomeScreenViewController: UIViewController {
    // MARK: - Properties
    private let stackView = UIStackView()
    private let viewQuestionsButton = UIButton(type: .system)
    private let startSurveyButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        // Triple-tap anywhere on the Welcome screen to force logout & see Login again
        let tripleTap = UITapGestureRecognizer(target: self, action: #selector(forceLogoutTapped))
        tripleTap.numberOfTapsRequired = 3
        view.addGestureRecognizer(tripleTap)
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        navigationItem.title = "Welcome"
        navigationItem.hidesBackButton = true
        
        // Configure StackView
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        // Configure View Questions Button
        configureButton(viewQuestionsButton, title: "View Questions", action: #selector(viewQuestionsTapped))
        viewQuestionsButton.accessibilityLabel = "View Questions"
        viewQuestionsButton.accessibilityHint = "Navigates to the questions list"
        
        // Configure Start Survey Button
        configureButton(startSurveyButton, title: "Start Survey", action: #selector(startSurveyTapped))
        startSurveyButton.accessibilityLabel = "Start Survey"
        startSurveyButton.accessibilityHint = "Opens the project selection screen"
        
        // Add buttons to StackView
        stackView.addArrangedSubview(viewQuestionsButton)
        stackView.addArrangedSubview(startSurveyButton)
        
        // Center StackView vertically and horizontally
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            viewQuestionsButton.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            viewQuestionsButton.heightAnchor.constraint(equalToConstant: 44),
            startSurveyButton.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            startSurveyButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func configureButton(_ button: UIButton, title: String, action: Selector) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(.systemYellow, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        button.layer.cornerRadius = 8
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.addTarget(self, action: action, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
    }
    
    @objc private func viewQuestionsTapped() {
        let firstScreenVC = FirstScreenViewController()
        firstScreenVC.hideBarrierButton = true
        navigationController?.pushViewController(firstScreenVC, animated: true)
        print("View Questions button tapped, navigating to FirstScreenViewController")
    }
    
    @objc private func startSurveyTapped() {
        let surveySetupVC = SurveySetupViewController()
        navigationController?.pushViewController(surveySetupVC, animated: true)
        print("Start Survey button tapped, navigating to SurveySetupViewController")
    }
    
    @objc private func forceLogoutTapped() {
        NetworkManager.shared.logout()
        
        guard let nav = AppDelegate.shared.rootNavigationController else { return }
        
        // UNHIDE BEFORE GOING BACK TO SPLASH
        nav.setNavigationBarHidden(false, animated: false)
        
        let splashVC = SplashViewController()
        nav.setViewControllers([splashVC], animated: false)
    }
}
