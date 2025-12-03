//
//  NewSurveyDetailsViewController.swift
//  QuestionsApp
//
//  Created by William Cather on 8/8/25.
//

import UIKit

class NewSurveyDetailsViewController: UIViewController {
    // MARK: - Properties
    private let stackView = UIStackView()
    private let projectLabel = UILabel()
    private let campusLabel = UILabel()
    private let siteLabel = UILabel()
    private let surveyDateLabel = UILabel()
    private let teamLeadLabel = UILabel()
    private let teamLabel = UILabel()
    private let editButton = UIButton(type: .system)
    private let startSurveyButton = UIButton(type: .system)
    private var surveyProject: SurveyProject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        populateFields()
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        navigationItem.title = "Survey Details"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Back",
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )
        navigationItem.leftBarButtonItem?.tintColor = .systemYellow
        navigationItem.leftBarButtonItem?.accessibilityLabel = "Back to Survey Details Entry"
        
        // Configure StackView
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        // Configure Labels
        configureLabel(projectLabel, accessibilityLabel: "Project")
        configureLabel(campusLabel, accessibilityLabel: "Campus")
        configureLabel(siteLabel, accessibilityLabel: "Site")
        configureLabel(surveyDateLabel, accessibilityLabel: "Survey Date")
        configureLabel(teamLeadLabel, accessibilityLabel: "Team Lead")
        configureLabel(teamLabel, accessibilityLabel: "Team")
        
        // Configure Buttons
        configureButton(editButton, title: "Edit Values", action: #selector(editTapped))
        editButton.accessibilityLabel = "Edit Values"
        editButton.accessibilityHint = "Returns to edit survey details"
        
        configureButton(startSurveyButton, title: "Start Survey", action: #selector(startSurveyTapped))
        startSurveyButton.accessibilityLabel = "Start Survey"
        startSurveyButton.accessibilityHint = "Proceeds to select survey forms"
        
        // Add views to StackView
        stackView.addArrangedSubview(createLabeledFieldView(labelText: "Project", view: projectLabel))
        stackView.addArrangedSubview(createLabeledFieldView(labelText: "Campus", view: campusLabel))
        stackView.addArrangedSubview(createLabeledFieldView(labelText: "Site", view: siteLabel))
        stackView.addArrangedSubview(createLabeledFieldView(labelText: "Survey Date", view: surveyDateLabel))
        stackView.addArrangedSubview(createLabeledFieldView(labelText: "Team Lead", view: teamLeadLabel))
        stackView.addArrangedSubview(createLabeledFieldView(labelText: "Team", view: teamLabel))
        stackView.addArrangedSubview(editButton)
        stackView.addArrangedSubview(startSurveyButton)
        
        // Constraints
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            projectLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            campusLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            siteLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            surveyDateLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            teamLeadLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            teamLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            editButton.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            editButton.heightAnchor.constraint(equalToConstant: 44),
            startSurveyButton.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            startSurveyButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func configureLabel(_ label: UILabel, accessibilityLabel: String) {
        label.font = .systemFont(ofSize: 16)
        label.textColor = .white
        label.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = true
        label.accessibilityLabel = accessibilityLabel
        label.translatesAutoresizingMaskIntoConstraints = false
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
    
    private func createLabeledFieldView(labelText: String, view: UIView) -> UIView {
        let container = UIView()
        let label = UILabel()
        label.text = labelText
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = .systemYellow
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)
        container.addSubview(view)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            view.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 8),
            view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        return container
    }
    
    private func populateFields() {
        guard let data = UserDefaults.standard.data(forKey: "selectedSurveyProject"),
              let surveyProject = try? JSONDecoder().decode(SurveyProject.self, from: data) else {
            print("Error: No survey project data found")
            let alert = UIAlertController(title: "Error", message: "No survey details available.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        self.surveyProject = surveyProject
        projectLabel.text = surveyProject.project
        campusLabel.text = surveyProject.campus
        siteLabel.text = surveyProject.site
        teamLeadLabel.text = surveyProject.teamLead
        teamLabel.text = surveyProject.team
        
        if let surveyDate = surveyProject.surveyDate {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            surveyDateLabel.text = formatter.string(from: surveyDate)
        } else {
            surveyDateLabel.text = "Not set"
        }
        
        print("Populated survey details: project=\(surveyProject.project), campus=\(surveyProject.campus), site=\(surveyProject.site), surveyDate=\(surveyProject.surveyDate?.description ?? "nil"), teamLead=\(surveyProject.teamLead ?? ""), team=\(surveyProject.team ?? "")")
    }
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
        print("Back to SurveyViewController")
    }
    
    @objc private func editTapped() {
        let surveySetupVC = SurveySetupViewController()
        surveySetupVC.isEditing = true
        navigationController?.pushViewController(surveySetupVC, animated: true)
        print("Edit button tapped, navigating to SurveySetupViewController")
    }
    
    @objc private func startSurveyTapped() {
        guard let data = UserDefaults.standard.data(forKey: "selectedSurveyProject"),
              let surveyProject = try? JSONDecoder().decode(SurveyProject.self, from: data) else {
            print("Error: No survey project data available")
            let alert = UIAlertController(title: "Error", message: "No survey details available.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        NetworkManager.shared.fetchForms(projectNumber: surveyProject.project) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let forms):
                    print("Fetched forms for project \(surveyProject.project): \(forms.map { $0.name })")
                    let surveyFormsVC = SurveyFormsViewController()
                    surveyFormsVC.surveyProject = surveyProject
                    surveyFormsVC.forms = forms
                    self?.navigationController?.pushViewController(surveyFormsVC, animated: true)
                    print("Start Survey button tapped, navigating to SurveyFormsViewController")
                case .failure(let error):
                    print("Error fetching forms: \(error)")
                    let alert = UIAlertController(title: "Error", message: "Failed to load forms: \(error.localizedDescription)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(alert, animated: true)
                }
            }
        }
    }
}
