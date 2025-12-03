//
//  SurveySetupViewController.swift
//  QuestionsApp
//
//  Created by William Cather on 8/4/25.
//

import UIKit

class SurveySetupViewController: UIViewController {
    // MARK: - Properties
    private let stackView = UIStackView()
    private let projectTextField = UITextField()
    private let campusTextField = UITextField()
    private let siteTextField = UITextField()
    private let setProjectButton = UIButton(type: .system)
    private var projectPickerTableView: UITableView!
    private var campusPickerTableView: UITableView!
    private var sitePickerTableView: UITableView!
    private var projects: [Project] = []
    private var campuses: [Campus] = []
    private var sites: [Site] = []
    private var selectedProject: String?
    private var selectedCampus: String?
    private var selectedSite: Site?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchProjects()
        if isEditing {
            populateExistingValues()
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        navigationItem.title = "Select Project"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Welcome",
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )
        navigationItem.leftBarButtonItem?.tintColor = .systemYellow
        navigationItem.leftBarButtonItem?.accessibilityLabel = "Back to Welcome Screen"
        
        // Configure StackView
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        // Configure Text Fields
        configureTextField(projectTextField, placeholder: "Select Project", accessibilityLabel: "Select Project Dropdown")
        configureTextField(campusTextField, placeholder: "Select Campus", accessibilityLabel: "Select Campus Dropdown")
        configureTextField(siteTextField, placeholder: "Select Site", accessibilityLabel: "Select Site Dropdown")
        campusTextField.isEnabled = false
        siteTextField.isEnabled = false
        
        // Configure Set Project Button
        configureButton(setProjectButton, title: "Set Project", action: #selector(setProjectTapped))
        setProjectButton.accessibilityLabel = "Set Project"
        setProjectButton.accessibilityHint = "Confirms project, campus, and site selection"
        setProjectButton.isEnabled = false
        setProjectButton.alpha = 0.5
        
        // Add views to StackView
        stackView.addArrangedSubview(createLabeledFieldView(labelText: "Project", view: projectTextField))
        stackView.addArrangedSubview(createLabeledFieldView(labelText: "Campus", view: campusTextField))
        stackView.addArrangedSubview(createLabeledFieldView(labelText: "Site", view: siteTextField))
        stackView.addArrangedSubview(setProjectButton)
        
        // Constraints
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            projectTextField.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            projectTextField.heightAnchor.constraint(equalToConstant: 44),
            campusTextField.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            campusTextField.heightAnchor.constraint(equalToConstant: 44),
            siteTextField.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            siteTextField.heightAnchor.constraint(equalToConstant: 44),
            setProjectButton.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            setProjectButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // Setup pickers
        projectPickerTableView = setupPickerTableView()
        campusPickerTableView = setupPickerTableView()
        sitePickerTableView = setupPickerTableView()
        projectTextField.inputView = projectPickerTableView
        campusTextField.inputView = campusPickerTableView
        siteTextField.inputView = sitePickerTableView
        projectTextField.delegate = self
        campusTextField.delegate = self
        siteTextField.delegate = self
    }
    
    private func configureTextField(_ textField: UITextField, placeholder: String, accessibilityLabel: String) {
        textField.placeholder = placeholder
        textField.font = .systemFont(ofSize: 16)
        textField.textColor = .white
        textField.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        textField.layer.cornerRadius = 8
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        textField.leftViewMode = .always
        textField.rightView = UIImageView(image: UIImage(systemName: "chevron.down"))
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
    
    private func updateSetProjectButtonState() {
        let isEnabled = selectedProject != nil && selectedCampus != nil && selectedSite != nil
        setProjectButton.isEnabled = isEnabled
        setProjectButton.alpha = isEnabled ? 1.0 : 0.5
        print("Set Project button enabled: \(isEnabled)")
    }
    
    private func fetchProjects() {
        NetworkManager.shared.fetchProjects { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let projects):
                    self?.projects = projects.sorted { $0.projectNumber < $1.projectNumber }
                    self?.projectPickerTableView.reloadData()
                    self?.projectTextField.isEnabled = true
                    print("Fetched projects: \(projects.map { $0.projectNumber })")
                case .failure(let error):
                    print("Error fetching projects: \(error)")
                    let alert = UIAlertController(title: "Error", message: "Failed to load projects: \(error.localizedDescription)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(alert, animated: true)
                }
            }
        }
    }
    
    private func populateExistingValues() {
        guard let data = UserDefaults.standard.data(forKey: "selectedSurveyProject"),
            let surveyProject = try? JSONDecoder().decode(SurveyProject.self, from: data) else {
            print("Error: No survey project data found for editing")
            return
        }
            
            selectedProject = surveyProject.project
            projectTextField.text = surveyProject.project
            projectTextField.isEnabled = true
            
            NetworkManager.shared.fetchCampuses(project: surveyProject.project) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let campuses):
                        self?.campuses = campuses.sorted { $0.campus < $1.campus }
                        self?.campusPickerTableView.reloadData()
                        self?.campusTextField.isEnabled = true
                        self?.selectedCampus = surveyProject.campus
                        self?.campusTextField.text = surveyProject.campus
                        
                        NetworkManager.shared.fetchSites(project: surveyProject.project, campus: surveyProject.campus) { [weak self] result in
                            DispatchQueue.main.async {
                                switch result {
                                case .success(let sites):
                                    self?.sites = sites.sorted { $0.site < $1.site }
                                    self?.sitePickerTableView.reloadData()
                                    self?.siteTextField.isEnabled = true
                                    if let site = sites.first(where: { $0.site == surveyProject.site }) {
                                        self?.selectedSite = site
                                        self?.siteTextField.text = surveyProject.site
                                    }
                                    self?.updateSetProjectButtonState()
                                    print("Populated existing values: project=\(surveyProject.project), campus=\(surveyProject.campus), site=\(surveyProject.site)")
                                case .failure(let error):
                                    print("Error fetching sites for editing: \(error)")
                                    let alert = UIAlertController(title: "Error", message: "Failed to load sites: \(error.localizedDescription)", preferredStyle: .alert)
                                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                                    self?.present(alert, animated: true)
                                }
                            }
                        }
                    case .failure(let error):
                        print("Error fetching campuses for editing: \(error)")
                        let alert = UIAlertController(title: "Error", message: "Failed to load campuses: \(error.localizedDescription)", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self?.present(alert, animated: true)
                    }
                }
            }
        }
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
        print("Back to WelcomeScreenViewController")
    }
    
    @objc private func setProjectTapped() {
        //guard let project = selectedProject, let campus = selectedCampus, let site = selectedSite else { return }
        guard let selectedSite = selectedSite else { return }
        let surveyProject = SurveyProject(
//            project: project,
//            campus: campus,
//            site: site.site,
//            unid: site.unid,
//            standard: site.standard,
//            costFactor: site.costFactor,
            project: selectedProject!,
            campus: selectedCampus!,
            site: selectedSite.site,
            unid: selectedSite.unid,
            standard: selectedSite.standard,
            costFactor: selectedSite.costFactor,
            surveyDate: nil,
            teamLead: nil,
            team: nil
        )
        do {
            let data = try JSONEncoder().encode(surveyProject)
            UserDefaults.standard.set(data, forKey: "selectedSurveyProject")
            print("Stored SurveyProject: project=\(surveyProject.project), campus=\(surveyProject.campus), site=\(surveyProject.site), unid=\(surveyProject.unid), standard=\(surveyProject.standard), costFactor=\(surveyProject.costFactor), surveyDate=\(String(describing: surveyProject.surveyDate)), teamLead=\(String(describing: surveyProject.teamLead)), team=\(String(describing: surveyProject.team))")
        } catch {
            print("Error encoding SurveyProject: \(error)")
        }
        let surveyVC = SurveyViewController()
        navigationController?.pushViewController(surveyVC, animated: true)
        print("Set Project button tapped, navigating to SurveyViewController")
    }
}

extension SurveySetupViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == projectPickerTableView {
            return projects.count
        } else if tableView == campusPickerTableView {
            return campuses.count
        } else if tableView == sitePickerTableView {
            return sites.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PickerCell", for: indexPath)
        if tableView == projectPickerTableView {
            let project = projects[indexPath.row]
            cell.textLabel?.text = project.projectNumber
            cell.accessibilityLabel = "Project \(project.projectNumber)"
        } else if tableView == campusPickerTableView {
            let campus = campuses[indexPath.row]
            cell.textLabel?.text = campus.campus
            cell.accessibilityLabel = "Campus \(campus.campus)"
        } else if tableView == sitePickerTableView {
            let site = sites[indexPath.row]
            cell.textLabel?.text = site.site
            cell.accessibilityLabel = "Site \(site.site)"
        }
        cell.textLabel?.textColor = .white
        cell.textLabel?.font = .systemFont(ofSize: 16)
        cell.textLabel?.textAlignment = .center
        cell.backgroundColor = .black
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == projectPickerTableView {
            let project = projects[indexPath.row]
            selectedProject = project.projectNumber
            projectTextField.text = selectedProject
            projectTextField.resignFirstResponder()
            selectedCampus = nil
            selectedSite = nil
            campusTextField.text = nil
            siteTextField.text = nil
            campusTextField.isEnabled = false
            siteTextField.isEnabled = false
            campuses.removeAll()
            sites.removeAll()
            campusPickerTableView.reloadData()
            sitePickerTableView.reloadData()
            NetworkManager.shared.fetchCampuses(project: selectedProject!) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let campuses):
                        self?.campuses = campuses.sorted { $0.campus < $1.campus }
                        self?.campusPickerTableView.reloadData()
                        self?.campusTextField.isEnabled = true
                        print("Fetched campuses for project \(project.projectNumber): \(campuses.map { $0.campus })")
                    case .failure(let error):
                        print("Error fetching campuses: \(error)")
                        let alert = UIAlertController(title: "Error", message: "Failed to load campuses: \(error.localizedDescription)", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self?.present(alert, animated: true)
                    }
                }
            }
            print("Selected project: \(selectedProject!)")
        } else if tableView == campusPickerTableView {
            let campus = campuses[indexPath.row]
            selectedCampus = campus.campus
            campusTextField.text = selectedCampus
            campusTextField.resignFirstResponder()
            selectedSite = nil
            siteTextField.text = nil
            siteTextField.isEnabled = false
            sites.removeAll()
            sitePickerTableView.reloadData()
            NetworkManager.shared.fetchSites(project: selectedProject!, campus: selectedCampus!) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let sites):
                        self?.sites = sites.sorted { $0.site < $1.site }
                        self?.sitePickerTableView.reloadData()
                        self?.siteTextField.isEnabled = true
                        print("Fetched sites for project \(self?.selectedProject ?? ""), campus \(campus.campus): \(sites.map { $0.site })")
                    case .failure(let error):
                        print("Error fetching sites: \(error)")
                        let alert = UIAlertController(title: "Error", message: "Failed to load sites: \(error.localizedDescription)", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self?.present(alert, animated: true)
                    }
                }
            }
            print("Selected campus: \(selectedCampus!)")
        } else if tableView == sitePickerTableView {
            let site = sites[indexPath.row]
            selectedSite = site
            siteTextField.text = site.site
            siteTextField.resignFirstResponder()
            print("Selected site: \(site.site), unid: \(site.unid), standard: \(site.standard), costFactor: \(site.costFactor)")
        }
        updateSetProjectButtonState()
    }
}

extension SurveySetupViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        print("Text field \(textField.accessibilityLabel ?? "unknown") will begin editing")
        return true
    }
}
