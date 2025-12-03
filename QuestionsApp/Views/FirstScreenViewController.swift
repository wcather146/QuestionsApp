import UIKit

class FirstScreenViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()
    private let titleLabel = UILabel()
    private let projectTextField = UITextField()
    private let stateTextField = UITextField()
    private let formTextField = UITextField()
    private let searchButton = UIButton(type: .system)
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private var projectPickerTableView: UITableView!
    private var statePickerTableView: UITableView!
    private var formPickerTableView: UITableView!
    
    private var projects: [Project] = []
    private var states: [State] = []
    private var forms: [Form] = []
    
    
    private var selectedProject: Project?
    private var selectedState: State?  //(name: String, code: String)?
    private var selectedForm: Form?  //(name: String, code: String)?
    
    var hideBarrierButton: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchData()
    }
    
    private func setupUI() {
        view.backgroundColor = .black // Branding: black background
        //navigationItem.hidesBackButton = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Configure stack view
        stackView.axis = .vertical
        stackView.spacing = 24 // Increased spacing for clarity
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        // Title label
        titleLabel.text = "Evan Terry Questions \n\nSelect Parameters"
        titleLabel.font = .boldSystemFont(ofSize: 24) // Supports Dynamic Type
        titleLabel.textColor = .systemYellow // Branding: yellow text
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.adjustsFontForContentSizeCategory = true // Accessibility: Dynamic Type
        titleLabel.accessibilityLabel = "Select Parameters Title"
        stackView.addArrangedSubview(titleLabel)
        
        // Configure text fields
        configureTextField(projectTextField, placeholder: "Choose a Project", accessibilityLabel: "Select Project Dropdown")
        configureTextField(stateTextField, placeholder: "Choose a State", accessibilityLabel: "Select State Dropdown")
        configureTextField(formTextField, placeholder: "Choose a Form", accessibilityLabel: "Select Form Dropdown")
        
        // Add labels and text fields to stack view
        stackView.addArrangedSubview(createLabeledFieldView(labelText: "Project", textField: projectTextField))
        stackView.addArrangedSubview(createLabeledFieldView(labelText: "State", textField: stateTextField))
        stackView.addArrangedSubview(createLabeledFieldView(labelText: "Form", textField: formTextField))
        
        // Search button
        searchButton.setTitle("Search", for: .normal)
        searchButton.titleLabel?.font = .boldSystemFont(ofSize: 18) // Dynamic Type
        searchButton.setTitleColor(.black, for: .normal)
        searchButton.backgroundColor = .systemYellow // Branding: yellow button
        searchButton.layer.cornerRadius = 8
        searchButton.isEnabled = false // Disabled until all fields are selected
        searchButton.alpha = 0.5 // Visual cue for disabled state
        searchButton.accessibilityLabel = "Search Button"
        searchButton.addTarget(self, action: #selector(searchTapped), for: .touchUpInside)
        stackView.addArrangedSubview(searchButton)
        
        // Loading indicator
        loadingIndicator.color = .systemYellow
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(loadingIndicator)
        
        // Constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 32),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32),
            searchButton.heightAnchor.constraint(equalToConstant: 44),
            loadingIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        // Setup table views for dropdowns
        projectPickerTableView = setupPickerTableView()
        statePickerTableView = setupPickerTableView()
        formPickerTableView = setupPickerTableView()
        projectTextField.inputView = projectPickerTableView
        stateTextField.inputView = statePickerTableView
        formTextField.inputView = formPickerTableView
        
        // Populate static data for State and Form dropdowns
        //print("States count: \(states.count), Forms count: \(forms.count)")
        //statePickerTableView.reloadData()
        //formPickerTableView.reloadData()
        //formPickerTableView.reloadData()
    }
    
    private func configureTextField(_ textField: UITextField, placeholder: String, accessibilityLabel: String) {
        textField.placeholder = placeholder
        textField.font = .systemFont(ofSize: 16) // Dynamic Type
        textField.textColor = .white
        textField.backgroundColor = UIColor(white: 0.2, alpha: 1.0) // Dark gray for contrast
        textField.layer.cornerRadius = 8
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0)) // Padding
        textField.leftViewMode = .always
        textField.rightView = UIImageView(image: UIImage(systemName: "chevron.down")) // Dropdown arrow
        textField.rightView?.tintColor = .systemYellow
        textField.rightViewMode = .always
        textField.adjustsFontForContentSizeCategory = true // Accessibility: Dynamic Type
        textField.accessibilityLabel = accessibilityLabel
        textField.delegate = self
        textField.tintColor = .clear // Prevent typing cursor
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }
    
    private func createLabeledFieldView(labelText: String, textField: UITextField) -> UIView {
        let container = UIView()
        let label = UILabel()
        label.text = labelText
        label.font = .boldSystemFont(ofSize: 18) // Dynamic Type
        label.textColor = .systemYellow // Branding: yellow text
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)
        container.addSubview(textField)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            textField.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 8),
            textField.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            textField.bottomAnchor.constraint(equalTo: container.bottomAnchor)
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
        tableView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 200) // Explicit size
        return tableView
    }
    
    private func fetchData() {
        loadingIndicator.startAnimating()
        //Fetch Projects
        NetworkManager.shared.fetchProjects { [weak self] result in
            DispatchQueue.main.async {
                self?.loadingIndicator.stopAnimating()
                switch result {
                case .success(let projects):
                    self?.projects = projects
                    print("Projects loaded: \(projects.count)")
                    self?.projectPickerTableView.reloadData()
                case .failure(let error):
                    print("Project fetch error: \(error.localizedDescription)")
                    let alert = UIAlertController(title: "Error", message: "Failed to load projects. Please try again later.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(alert, animated: true)
                }
            }
        }
        
        //Fetch States
        NetworkManager.shared.fetchStates { [weak self] result in
            DispatchQueue.main.async {
                self?.loadingIndicator.stopAnimating()
                switch result {
                case .success(let states):
                    self?.states = states
                    print("States loaded: \(states.count)")
                    self?.statePickerTableView.reloadData()
                case .failure(let error):
                    print ("States fetch error: \(error.localizedDescription)")
                    let alert = UIAlertController(title: "Error", message: "Failed to load states. Please try again later.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(alert, animated: true)
                    
                }
            }
        }
        
    }
    
    private func updateSearchButtonState() {
        let isEnabled = selectedProject != nil && selectedState != nil && selectedForm != nil
        searchButton.isEnabled = isEnabled
        searchButton.alpha = isEnabled ? 1.0 : 0.5
        print("Search button enabled: \(isEnabled), Project: \(selectedProject?.projectName ?? "none"), State: \(selectedState?.state ?? "none"), Form: \(selectedForm?.name ?? "none")")
    }
    
    @objc private func searchTapped() {
        guard let projectNumber = selectedProject?.projectNumber, let state = selectedState?.standard, let form = selectedForm?.code else {
            let alert = UIAlertController(title: "Missing Selection", message: "Please select a Project, State, and Form.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
       // let projectName = selectedProject?.projectName ?? "No Project Selected"
        //print("Navigating with Project: \(projectNumber), State: \(state), Form: \(form)")
        print("Navigating with Project: \(projectNumber), State: \(state), Form: \(form)")
        let secondVC = SecondScreenViewController(project: projectNumber, state: state, form: form, costFactor: 1.0)
        secondVC.hideBarrierButton = self.hideBarrierButton
        navigationController?.pushViewController(secondVC, animated: true)
    }
}

extension FirstScreenViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == projectTextField && projects.isEmpty ||
            textField == stateTextField && states.isEmpty ||
            textField == formTextField && forms.isEmpty{
            let alert = UIAlertController(title: "Data Not Loaded", message: "Please wait for project data to load.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return false
        }
        print("Text field \(textField.accessibilityLabel ?? "unknown") will begin editing")
        return true
    }
}

extension FirstScreenViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == projectPickerTableView {
            return projects.count
        } else if tableView == statePickerTableView {
            return states.count
        } else if tableView == formPickerTableView {
            return forms.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PickerCell", for: indexPath)
        cell.textLabel?.textColor = .white
        cell.textLabel?.font = .systemFont(ofSize: 16)
        cell.textLabel?.textAlignment = .center // Center the text
        cell.backgroundColor = .black
        if tableView == projectPickerTableView {
            cell.textLabel?.text = projects[indexPath.row].projectName
            cell.accessibilityLabel = "Project \(projects[indexPath.row].projectName)"
        } else if tableView == statePickerTableView {
            let state = states[indexPath.row]
            cell.textLabel?.text = state.state
            cell.accessibilityLabel = "State \(state.state)"
        } else if tableView == formPickerTableView {
            let form = forms[indexPath.row]
            cell.textLabel?.text = form.name
            cell.accessibilityLabel = "Form \(form.name)"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == projectPickerTableView {
            let project = projects[indexPath.row]
            selectedProject = project
            
            projectTextField.text = project.projectName
            projectTextField.resignFirstResponder()
            //print("Selected project: \(selectedProject ?? "none")")
            forms.removeAll()
            selectedForm = nil
            formTextField.text = nil
            formPickerTableView.reloadData()
            updateSearchButtonState()
            //Fetch forms for selected project
            guard let projectNumber = selectedProject?.projectNumber else { return }
            loadingIndicator.startAnimating()
            NetworkManager.shared.fetchForms(projectNumber: projectNumber) { [weak self] result in
                DispatchQueue.main.async {
                    self?.loadingIndicator.stopAnimating()
                    switch result {
                    case .success(let forms):
                        self?.forms = forms
                        self?.formPickerTableView.reloadData()
                    case .failure(let error):
                        print("Error fetching forms: \(error.localizedDescription)")
                        let alert = UIAlertController(title: "Error", message: "Error fetching forms. Please try again later.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self?.present(alert, animated: true)
                    }
                }

            }

        } else if tableView == statePickerTableView {
            let state = states[indexPath.row]
            selectedState = state
            stateTextField.text = state.state
            stateTextField.resignFirstResponder()
            print("Selected state: \(state.state) (\(state.standard))")
        } else if tableView == formPickerTableView {
            let form = forms[indexPath.row]
            selectedForm = form
            formTextField.text = form.name
            formTextField.resignFirstResponder()
            print("Selected form: \(form.name) (\(form.code))")
        }
        updateSearchButtonState()
    }
}
