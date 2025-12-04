//
//  SurveyFormsViewController.swift
//  QuestionsApp
//
//  Created by William Cather on 8/8/25.
//

import UIKit

// MARK: - Associated Keys
private struct AssociatedKeys {
    static var form: Int = 0
}

class SurveyFormsViewController: UIViewController {
    // MARK: - Properties
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    var surveyProject: SurveyProject?
    var forms: [Form] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        navigationItem.title = "Select Form"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Back",
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )
        navigationItem.leftBarButtonItem?.tintColor = .systemYellow
        navigationItem.leftBarButtonItem?.accessibilityLabel = "Back to Survey Details"
        
        // Configure ScrollView
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        // Configure StackView
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        
        // Add Form Buttons
        for form in forms {
            let button = UIButton(type: .system)
            configureButton(button, title: form.name, action: #selector(formTapped(_:)))
            button.accessibilityLabel = "Form \(form.name)"
            button.accessibilityHint = "Shows details for form \(form.name)"
            button.setAssociatedObject(form, forKey: &AssociatedKeys.form)
            stackView.addArrangedSubview(button)
        }
        
        // Constraints for ScrollView
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        // Constraints for StackView
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, multiplier: 0.98),
            stackView.centerXAnchor.constraint(equalTo: scrollView.frameLayoutGuide.centerXAnchor)
        ])
        
        for view in stackView.arrangedSubviews {
            if let button = view as? UIButton {
                NSLayoutConstraint.activate([
                    button.widthAnchor.constraint(equalTo: stackView.widthAnchor),
                    button.heightAnchor.constraint(equalToConstant: 44)
                ])
            }
        }
        
        if forms.isEmpty {
            let noFormsLabel = UILabel()
            noFormsLabel.text = "No forms available"
            noFormsLabel.font = .systemFont(ofSize: 16)
            noFormsLabel.textColor = .white
            noFormsLabel.textAlignment = .center
            noFormsLabel.adjustsFontForContentSizeCategory = true
            noFormsLabel.accessibilityLabel = "No forms available"
            stackView.addArrangedSubview(noFormsLabel)
            print("No forms available for display")
        }
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
        button.contentHorizontalAlignment = .center
        button.titleLabel?.textAlignment = .center
    }
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
        print("Back to NewSurveyDetailsViewController")
    }
    
    @objc private func formTapped(_ sender: UIButton) {
        guard let surveyProject = surveyProject,
              let form = sender.associatedObject(forKey: &AssociatedKeys.form) as? Form else {
            print("Error: Missing survey project or form data")
            let alert = UIAlertController(title: "Error", message: "Unable to display form details.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        let costFactorDouble = Double(surveyProject.costFactor) ?? 1.0
        
        // Call fetchQuestions to ensure questions are available
        NetworkManager.shared.fetchQuestions(project: surveyProject.project, state: surveyProject.standard, form: form.code) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success:
                    print("Successfully fetched questions for project: \(surveyProject.project), state: \(surveyProject.standard), form: \(form.code)")
                    _ = Double(surveyProject.costFactor) ?? 1.0   // fallback to 1.0 if nil/invalid
                    //let costFactorValue = Double(surveyProject.costFactor) ?? 1.0 
                    let secondVC = SecondScreenViewController(project: surveyProject.project, state: surveyProject.standard, form: form.code, costFactor: costFactorDouble)
                    secondVC.hideBarrierButton = false // Allow barrier creation
                    self.navigationController?.pushViewController(secondVC, animated: true)
                case .failure(let error):
                    print("Error fetching questions: \(error)")
                    let alert = UIAlertController(title: "Error", message: "Failed to load questions: \(error.localizedDescription)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }
}

// MARK: - UIButton Extension for Associated Objects
private extension UIButton {
    func setAssociatedObject(_ value: Any?, forKey key: UnsafeRawPointer) {
        objc_setAssociatedObject(self, key, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    func associatedObject(forKey key: UnsafeRawPointer) -> Any? {
        return objc_getAssociatedObject(self, key)
    }
}
