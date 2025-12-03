//
//  SurveyViewController.swift
//  QuestionsApp
//
//  Created by William Cather on 8/4/25.
//

import UIKit

class SurveyViewController: UIViewController {
    // MARK: - Properties
    private let stackView = UIStackView()
    private let surveyDateTextField = UITextField()
    private let teamLeadTextField = UITextField()
    private let teamTextField = UITextField()
    private let submitButton = UIButton(type: .system)
    private let datePicker = UIDatePicker()
    private var teamLeadPickerTableView: UITableView!
    private var teamPickerTableView: UITableView!
    private var teamMembers: [String] = []
    private var selectedTeamLead: String?
    private var selectedTeamMembers: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setDefaultSurveyDate()
        fetchTeamMembers()
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
        navigationItem.leftBarButtonItem?.accessibilityLabel = "Back to Project Selection"
        
        // Configure StackView
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        // Configure Text Fields
        configureTextField(surveyDateTextField, placeholder: "Select Survey Date", accessibilityLabel: "Select Survey Date")
        configureTextField(teamLeadTextField, placeholder: "Select Team Lead", accessibilityLabel: "Select Team Lead Dropdown")
        configureTextField(teamTextField, placeholder: "Select Team Members", accessibilityLabel: "Select Team Members Dropdown")
        teamTextField.delegate = self
        teamLeadTextField.delegate = self
        surveyDateTextField.delegate = self
        
        // Configure Date Picker
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.addTarget(self, action: #selector(datePickerChanged), for: .valueChanged)
        surveyDateTextField.inputView = datePicker
        
        // Configure Pickers
        teamLeadPickerTableView = setupPickerTableView()
        teamPickerTableView = setupPickerTableView()
        teamLeadTextField.inputView = teamLeadPickerTableView
        teamTextField.inputView = teamPickerTableView
        
        // Configure Submit Button
        configureButton(submitButton, title: "Submit Survey Details", action: #selector(submitTapped))
        submitButton.accessibilityLabel = "Submit Survey Details"
        submitButton.accessibilityHint = "Confirms survey date, team lead, and team"
        submitButton.isEnabled = false
        submitButton.alpha = 0.5
        
        // Add views to StackView
        stackView.addArrangedSubview(createLabeledFieldView(labelText: "Survey Date", view: surveyDateTextField))
        stackView.addArrangedSubview(createLabeledFieldView(labelText: "Team Lead", view: teamLeadTextField))
        stackView.addArrangedSubview(createLabeledFieldView(labelText: "Team", view: teamTextField))
        stackView.addArrangedSubview(submitButton)
        
        // Constraints
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            surveyDateTextField.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            surveyDateTextField.heightAnchor.constraint(equalToConstant: 44),
            teamLeadTextField.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            teamLeadTextField.heightAnchor.constraint(equalToConstant: 44),
            teamTextField.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            teamTextField.heightAnchor.constraint(equalToConstant: 44),
            submitButton.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            submitButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func configureTextField(_ textField: UITextField, placeholder: String, accessibilityLabel: String) {
        textField.placeholder = placeholder
        textField.font = .systemFont(ofSize: 16)
        textField.textColor = .white
        textField.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        textField.layer.cornerRadius = 8
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        textField.leftViewMode = .always
        if textField == surveyDateTextField {
            textField.rightView = UIImageView(image: UIImage(systemName: "calendar"))
        } else {
            textField.rightView = UIImageView(image: UIImage(systemName: "chevron.down"))
        }
        textField.rightView?.tintColor = .systemYellow
        textField.rightViewMode = .always
        textField.tintColor = .clear
        textField.adjustsFontForContentSizeCategory = true
        textField.accessibilityLabel = accessibilityLabel
        textField.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func configureButton(_ button: UIButton, title: String, action: Selector) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(.systemYellow, for: .normal)
        button.setTitleColor(.systemYellow.withAlphaComponent(0.5), for: .disabled)
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
    
    private func setupPickerTableView() -> UITableView {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "PickerCell")
        tableView.backgroundColor = .black
        tableView.separatorColor = .systemYellow
        tableView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 200)
        return tableView
    }
    
    private func setDefaultSurveyDate() {
            let today = Date()
            datePicker.date = today
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            surveyDateTextField.text = formatter.string(from: today)
            print("Survey Date set to: \(formatter.string(from: today))")
        }
    
    private func updateSubmitButtonState() {
        let isEnabled = selectedTeamLead != nil
        submitButton.isEnabled = isEnabled
        submitButton.alpha = isEnabled ? 1.0 : 0.5
        print("Submit button enabled: \(isEnabled)")
    }
    
    private func fetchTeamMembers() {
        guard let data = UserDefaults.standard.data(forKey: "selectedSurveyProject"),
              let surveyProject = try? JSONDecoder().decode(SurveyProject.self, from: data) else {
            print("Error: No survey project data found")
            let alert = UIAlertController(title: "Error", message: "No project selected. Please select a project first.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        NetworkManager.shared.fetchTeamMembers(project: surveyProject.project) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let members):
                    self?.teamMembers = members.sorted()
                    self?.teamLeadPickerTableView.reloadData()
                    self?.teamPickerTableView.reloadData()
                    self?.teamLeadTextField.isEnabled = true
                    self?.teamTextField.isEnabled = true
                    print("Team members loaded: \(members)")
                case .failure(let error):
                    print("Error fetching team members: \(error)")
                    let alert = UIAlertController(title: "Error", message: "Failed to load team members: \(error.localizedDescription)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(alert, animated: true)
                }
            }
        }
    }
    
    @objc private func datePickerChanged(_ sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        surveyDateTextField.text = formatter.string(from: sender.date)
        updateSubmitButtonState()
        print("Selected survey date: \(sender.date)")
    }
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
        print("Back to SurveySetupViewController")
    }
    
    @objc private func submitTapped() {
        guard let surveyDateText = surveyDateTextField.text,
              let teamLead = selectedTeamLead,
              let data = UserDefaults.standard.data(forKey: "selectedSurveyProject"),
              var surveyProject = try? JSONDecoder().decode(SurveyProject.self, from: data) else {
            print("Error: Missing survey project data or invalid input")
            let alert = UIAlertController(title: "Error", message: "Please complete all fields and ensure a project is selected.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        guard let surveyDate = formatter.date(from: surveyDateText) else {
            print("Error: Invalid survey date format")
            return
        }
        
        surveyProject.surveyDate = surveyDate
        surveyProject.teamLead = teamLead
        surveyProject.team = selectedTeamMembers.joined(separator: ",")
        
        do {
            let updatedData = try JSONEncoder().encode(surveyProject)
            UserDefaults.standard.set(updatedData, forKey: "selectedSurveyProject")
            print("Updated SurveyProject: project=\(surveyProject.project), campus=\(surveyProject.campus), site=\(surveyProject.site), unid=\(surveyProject.unid), standard=\(surveyProject.standard), costFactor=\(surveyProject.costFactor), surveyDate=\(surveyProject.surveyDate?.description ?? "nil"), teamLead=\(surveyProject.teamLead ?? ""), team=\(surveyProject.team ?? "")")
        } catch {
            print("Error encoding SurveyProject: \(error)")
        }
        
        let newSurveyDetailsVC = NewSurveyDetailsViewController()
        navigationController?.pushViewController(newSurveyDetailsVC, animated: true)
        print("Submit button tapped, navigating to NewSurveyDetailsViewController")
    }
}

extension SurveyViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teamMembers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PickerCell", for: indexPath)
        let member = teamMembers[indexPath.row]
        cell.textLabel?.text = member
        cell.textLabel?.textColor = .white
        cell.textLabel?.font = .systemFont(ofSize: 16)
        cell.textLabel?.textAlignment = .center
        cell.backgroundColor = .black
        cell.accessibilityLabel = "Team member \(member)"
        
        if tableView == teamPickerTableView {
            cell.accessoryType = selectedTeamMembers.contains(member) ? .checkmark : .none
        } else if tableView == teamLeadPickerTableView {
            cell.accessoryType = selectedTeamLead == member ? .checkmark : .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let member = teamMembers[indexPath.row]
        if tableView == teamLeadPickerTableView {
            selectedTeamLead = member
            teamLeadTextField.text = member
            teamLeadTextField.resignFirstResponder()
            print("Selected team lead: \(member)")
        } else if tableView == teamPickerTableView {
            if selectedTeamMembers.contains(member) {
                selectedTeamMembers.removeAll { $0 == member }
            } else {
                selectedTeamMembers.append(member)
            }
            teamTextField.text = selectedTeamMembers.joined(separator: ", ")
            teamPickerTableView.reloadData()
            print("Selected team members: \(selectedTeamMembers)")
        }
        updateSubmitButtonState()
    }
}

extension SurveyViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        print("Text field \(textField.accessibilityLabel ?? "unknown") will begin editing")
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
