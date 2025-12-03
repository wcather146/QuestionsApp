//
//  FourthScreenViewController.swift
//  QuestionsApp
//
//  Created by William Cather on 7/23/25.
//

import UIKit
import Photos

class FourthScreenViewController: UIViewController {
    // MARK: - Properties
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()
    
    //private let projectNumber: String   // ← NEW
    private let standard: String        // ← NEW
    private let questionType: String
    private let costFactor: Double
    
    private let locationTextField = UITextField()
    private let useCodeTextField = UITextField()
    
    // NEW FIELDS
    private let dojCodeTextField = UITextField()
    private let severityCodeTextField = UITextField()
   
    private let questionTextView = UITextView()
    private let desiredInformationTextView = UITextView()
    private let existingConditionTextView = UITextView()
    private let possibleSolutionTextView = UITextView()
    
    // NEW: Unit Type (read-only) and Units (editable)
    private let unitTypeLabel = UILabel()
    private let unitTypeValueLabel = UILabel()  // This replaces the old unitTypeLabel
    private let unitsTextField = UITextField()
    
    private let surveyorNotesTextView = UITextView()
    private let createBarrierButton = UIButton(type: .system)
    private let addPhotoButton = UIButton(type: .system)
    private let photosCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let useDesiredInfoButton = UIButton(type: .system)
    private let promptForInfoButton = UIButton(type: .system) // New button
    private let selectSolutionButton = UIButton(type: .system)
    
    // NEW: Cost fields
    private let solutionCostLabel = UILabel()
    private let overrideCostTextField = UITextField()
    
    private var useCodePickerTableView: UITableView!
    private let projectID: String // New: Store project ID
    private let questionID: String
    private let barrierQuestion: String?
    private let desiredInformation: String
    private var useCodes: [String] = []
    private var selectedUseCode: String?
    private var photos: [UIImage] = []
    private var selectedSolution: Solution?
    
    // Fixed lists for new fields
    private var selectedDOJCode: String?          // ADD THIS LINE
    private var selectedSeverityCode: String?     // ADD THIS LINE
    private var dojCodePickerTableView: UITableView!
    private var severityCodePickerTableView: UITableView!

    private var dojCodes: [String] = ["1", "2", "3", "4"]
    private var severityCodes: [String] = ["A", "B", "C", "D", "E", "F", "G", "H", "X"]
    
    init(questionID: String, barrierQuestion: String?, desiredInformation: String, projectID: String, standard: String, questionType: String, costFactor: Double) {
        self.questionID = questionID
        self.barrierQuestion = barrierQuestion
        self.desiredInformation = desiredInformation
        self.projectID = projectID
        //self.projectNumber = projectNumber
        self.standard = standard
        self.questionType = questionType
        self.costFactor = costFactor
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupPhotosCollectionView()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Back",
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )
        navigationItem.leftBarButtonItem?.tintColor = .systemYellow
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false   // ← important: still lets buttons work!
        view.addGestureRecognizer(tap)
    
        NetworkManager.shared.fetchUseCodes(projectID: projectID) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let codes):
                    self?.useCodes = codes.sorted { $0.lowercased() < $1.lowercased() }
                    self?.useCodePickerTableView.reloadData()
                    self?.useCodeTextField.isEnabled = true
                    print("Fetched use codes: \(codes)")
                case .failure(let error):
                    print("Error fetching use codes: \(error)")
                    let alert = UIAlertController(title: "Error", message: "Failed to load use codes: \(error.localizedDescription)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(alert, animated: true)
                    self?.useCodeTextField.isEnabled = true
                }
            }
        }
    }
    
    private func decodeHTML(_ string: String) -> String {
            guard let data = string.data(using: .utf8) else { return string }
            let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ]
            do {
                let attributed = try NSAttributedString(data: data, options: options, documentAttributes: nil)
                return attributed.string
            } catch {
                print("HTML decoding error: \(error)")
                return string
            }
        }
    
    private func setupUI() {
        view.backgroundColor = .black
//        navigationItem.title = "Barrier Details"
//        navigationItem.leftBarButtonItem = UIBarButtonItem(
//            title: "Back",
//            style: .plain,
//            target: self,
//            action: #selector(backTapped)
//        )
//        navigationItem.leftBarButtonItem?.tintColor = .systemYellow
//        navigationItem.leftBarButtonItem?.accessibilityLabel = "Back to Question Details"
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        configureTextField(locationTextField, placeholder: "Enter location", accessibilityLabel: "Location Input")
        configureTextField(useCodeTextField, placeholder: "Choose a Use Code", accessibilityLabel: "Select Use Code Dropdown")
        configureTextField(dojCodeTextField, placeholder: "Select DOJ Code", accessibilityLabel: "Select DOJ Code Dropdown")
        configureTextField(severityCodeTextField, placeholder: "Select Severity Code", accessibilityLabel: "Select Severity Code Dropdown")
        
        configureTextView(questionTextView, text: decodeHTML(barrierQuestion ?? ""), isEditable: false, accessibilityLabel: "Question")
        configureTextView(desiredInformationTextView, text: decodeHTML(desiredInformation), isEditable: false, accessibilityLabel: "Desired Information")
        configureTextView(existingConditionTextView, text: nil, isEditable: true, accessibilityLabel: "Existing Condition Input")
        configureTextView(surveyorNotesTextView, text: nil, isEditable: true, accessibilityLabel: "Surveyor Notes Input")
        
        // NEW: Possible Solution field (read-only)
        possibleSolutionTextView.text = "No solution selected"
        possibleSolutionTextView.textColor = .lightGray
        possibleSolutionTextView.backgroundColor = UIColor(white: 0.15, alpha: 1.0)
        possibleSolutionTextView.layer.cornerRadius = 8
        possibleSolutionTextView.font = .systemFont(ofSize: 16)
        possibleSolutionTextView.isEditable = false
        possibleSolutionTextView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        possibleSolutionTextView.accessibilityLabel = "Possible Solution"
        
        // NEW: Unit Type (read-only label)
        unitTypeLabel.text = "—"
        unitTypeLabel.textColor = .lightGray
        unitTypeLabel.font = .systemFont(ofSize: 16)
        unitTypeLabel.textAlignment = .left
                
        // NEW: Units (editable, default = 1)
        unitsTextField.text = "1"
        unitsTextField.keyboardType = .numberPad
        unitsTextField.textAlignment = .right
        unitsTextField.font = .systemFont(ofSize: 16)
        unitsTextField.textColor = .white
        unitsTextField.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        unitsTextField.layer.cornerRadius = 8
        unitsTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        unitsTextField.leftViewMode = .always
        unitsTextField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        unitsTextField.rightViewMode = .always
        unitsTextField.accessibilityLabel = "Number of Units"
        
        configureAddPhotoButton()
        configureCreateBarrierButton()
        configureUseDesiredInfoButton()
        configurePromptForInfoButton()
        configureSelectSolutionButton()
        
        // Configure the read-only Possible Solution field
        configureTextView(
            possibleSolutionTextView,
            text: "No solution selected",
            isEditable: false,
            accessibilityLabel: "Possible Solution"
        )
        possibleSolutionTextView.textColor = .lightGray
        possibleSolutionTextView.backgroundColor = UIColor(white: 0.15, alpha: 1.0)
        possibleSolutionTextView.layer.cornerRadius = 8
        possibleSolutionTextView.font = .systemFont(ofSize: 16)
        possibleSolutionTextView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        
        // Add fields in correct order
        stackView.addArrangedSubview(createLabeledFieldView(labelText: "Location", view: locationTextField))
        stackView.addArrangedSubview(createLabeledFieldView(labelText: "Use Code", view: useCodeTextField))
        stackView.addArrangedSubview(createLabeledFieldView(labelText: "DOJ Code", view: dojCodeTextField))
        stackView.addArrangedSubview(createLabeledFieldView(labelText: "Severity Code", view: severityCodeTextField))
        stackView.addArrangedSubview(createLabeledFieldView(labelText: "Question", view: questionTextView))
        stackView.addArrangedSubview(createLabeledFieldView(labelText: "Desired Information", view: desiredInformationTextView))
        stackView.addArrangedSubview(createLabeledFieldView(labelText: "", view: useDesiredInfoButton))
        stackView.addArrangedSubview(createLabeledFieldView(labelText: "", view: promptForInfoButton))
        stackView.addArrangedSubview(createLabeledFieldView(labelText: "Existing Condition", view: existingConditionTextView))
        //stackView.addArrangedSubview(createLabeledFieldView(labelText: "", view: selectSolutionButton))
        
        // ——— SELECT SOLUTION BUTTON (now visible!) ———
        let solutionContainer = UIView()
        solutionContainer.addSubview(selectSolutionButton)
        selectSolutionButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            selectSolutionButton.topAnchor.constraint(equalTo: solutionContainer.topAnchor, constant: 12),
            selectSolutionButton.leadingAnchor.constraint(equalTo: solutionContainer.leadingAnchor),
            selectSolutionButton.trailingAnchor.constraint(equalTo: solutionContainer.trailingAnchor),
            selectSolutionButton.bottomAnchor.constraint(equalTo: solutionContainer.bottomAnchor, constant: -12),
            selectSolutionButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        stackView.addArrangedSubview(solutionContainer)

        // ADD THIS NEW BLOCK RIGHT HERE
        stackView.addArrangedSubview(createLabeledFieldView(labelText: "Possible Solution", view: possibleSolutionTextView))
        
        //ADD UNITS, UNIT TYPE, SOLUTION COST, SURVEYOR OVERRIDE
        
        // ——— NEW: Unit Type + Units — Horizontal with inline labels ———
        let unitsHorizontalStack = UIStackView()
        unitsHorizontalStack.axis = .horizontal
        unitsHorizontalStack.spacing = 20
        unitsHorizontalStack.alignment = .center

        // Unit Type Row
        let unitTypeRow = UIStackView()
        unitTypeRow.axis = .horizontal
        unitTypeRow.spacing = 12
        unitTypeRow.alignment = .center

        let unitTypeLabelTitle = UILabel()
        unitTypeLabelTitle.text = "Unit Type:"
        unitTypeLabelTitle.textColor = .systemYellow
        unitTypeLabelTitle.font = .boldSystemFont(ofSize: 16)
        unitTypeLabelTitle.setContentHuggingPriority(.required, for: .horizontal)

        unitTypeValueLabel.text = "—"
        unitTypeValueLabel.textColor = .white
        unitTypeValueLabel.font = .systemFont(ofSize: 16)
        unitTypeValueLabel.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        unitTypeValueLabel.layer.cornerRadius = 8
        unitTypeValueLabel.textAlignment = .center
        unitTypeValueLabel.minimumScaleFactor = 0.8
        unitTypeValueLabel.adjustsFontSizeToFitWidth = true

        let unitTypeContainer = UIView()
        unitTypeContainer.addSubview(unitTypeValueLabel)
        unitTypeValueLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            unitTypeValueLabel.topAnchor.constraint(equalTo: unitTypeContainer.topAnchor, constant: 8),
            unitTypeValueLabel.leadingAnchor.constraint(equalTo: unitTypeContainer.leadingAnchor),
            unitTypeValueLabel.trailingAnchor.constraint(equalTo: unitTypeContainer.trailingAnchor),
            unitTypeValueLabel.bottomAnchor.constraint(equalTo: unitTypeContainer.bottomAnchor, constant: -8),
            unitTypeValueLabel.heightAnchor.constraint(equalToConstant: 44)
        ])

        unitTypeRow.addArrangedSubview(unitTypeLabelTitle)
        unitTypeRow.addArrangedSubview(unitTypeContainer)

        // Units Row
        let unitsRow = UIStackView()
        unitsRow.axis = .horizontal
        unitsRow.spacing = 12
        unitsRow.alignment = .center

        let unitsLabelTitle = UILabel()
        unitsLabelTitle.text = "Units:"
        unitsLabelTitle.textColor = .systemYellow
        unitsLabelTitle.font = .boldSystemFont(ofSize: 16)
        unitsLabelTitle.setContentHuggingPriority(.required, for: .horizontal)

        unitsTextField.text = "1"
        unitsTextField.keyboardType = .numberPad
        unitsTextField.textAlignment = .center
        unitsTextField.font = .systemFont(ofSize: 16)
        unitsTextField.textColor = .white
        unitsTextField.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        unitsTextField.layer.cornerRadius = 8
        unitsTextField.accessibilityLabel = "Number of Units"
        unitsTextField.addTarget(self, action: #selector(recalculateCost), for: .editingChanged)

        let unitsContainer = UIView()
        unitsContainer.addSubview(unitsTextField)
        unitsTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            unitsTextField.topAnchor.constraint(equalTo: unitsContainer.topAnchor, constant: 8),
            unitsTextField.leadingAnchor.constraint(equalTo: unitsContainer.leadingAnchor),
            unitsTextField.trailingAnchor.constraint(equalTo: unitsContainer.trailingAnchor),
            unitsTextField.bottomAnchor.constraint(equalTo: unitsContainer.bottomAnchor, constant: -8),
            unitsTextField.widthAnchor.constraint(equalToConstant: 100),
            unitsTextField.heightAnchor.constraint(equalToConstant: 44)
        ])

        unitsRow.addArrangedSubview(unitsLabelTitle)
        unitsRow.addArrangedSubview(unitsContainer)

        // Add both rows to main horizontal stack
        unitsHorizontalStack.addArrangedSubview(unitTypeRow)
        unitsHorizontalStack.addArrangedSubview(unitsRow)

        // Wrap in a container with proper spacing
        let unitsSectionContainer = UIView()
        unitsSectionContainer.addSubview(unitsHorizontalStack)
        unitsHorizontalStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            unitsHorizontalStack.topAnchor.constraint(equalTo: unitsSectionContainer.topAnchor, constant: 12),
            unitsHorizontalStack.leadingAnchor.constraint(equalTo: unitsSectionContainer.leadingAnchor),
            unitsHorizontalStack.trailingAnchor.constraint(lessThanOrEqualTo: unitsSectionContainer.trailingAnchor),
            unitsHorizontalStack.bottomAnchor.constraint(equalTo: unitsSectionContainer.bottomAnchor, constant: -12)
        ])
        
        // Add to main stack view
        stackView.addArrangedSubview(unitsSectionContainer)
        
        // ——— NEW: Solution Cost + Override Cost — Equal width, left-justified ———
        let costRow = UIStackView()
        costRow.axis = .horizontal
        costRow.spacing = 20
        costRow.distribution = .fillEqually
        costRow.alignment = .center

        // Solution Cost (read-only)
        let solutionCostContainer = UIView()
        let solutionCostTitle = UILabel()
        solutionCostTitle.text = "Solution Cost:"
        solutionCostTitle.textColor = .systemYellow
        solutionCostTitle.font = .boldSystemFont(ofSize: 16)

        solutionCostLabel.text = "$0.00"
        solutionCostLabel.textColor = .white
        solutionCostLabel.font = .systemFont(ofSize: 16)
        solutionCostLabel.textAlignment = .left

        let solutionCostStack = UIStackView(arrangedSubviews: [solutionCostTitle, solutionCostLabel])
        solutionCostStack.axis = .horizontal
        solutionCostStack.spacing = 12
        solutionCostStack.alignment = .center

        solutionCostContainer.addSubview(solutionCostStack)
        solutionCostStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            solutionCostStack.topAnchor.constraint(equalTo: solutionCostContainer.topAnchor, constant: 8),
            solutionCostStack.leadingAnchor.constraint(equalTo: solutionCostContainer.leadingAnchor, constant: 12),
            solutionCostStack.trailingAnchor.constraint(lessThanOrEqualTo: solutionCostContainer.trailingAnchor, constant: -12),
            solutionCostStack.bottomAnchor.constraint(equalTo: solutionCostContainer.bottomAnchor, constant: -8)
        ])

        // Override Cost (editable)
        let overrideCostContainer = UIView()
        let overrideCostTitle = UILabel()
        overrideCostTitle.text = "Override Cost:"
        overrideCostTitle.textColor = .systemYellow
        overrideCostTitle.font = .boldSystemFont(ofSize: 16)

        overrideCostTextField.text = "$0.00"
        overrideCostTextField.keyboardType = .decimalPad
        overrideCostTextField.textAlignment = .left
        overrideCostTextField.font = .systemFont(ofSize: 16)
        overrideCostTextField.textColor = .white
        overrideCostTextField.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        overrideCostTextField.layer.cornerRadius = 8
        overrideCostTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        overrideCostTextField.leftViewMode = .always
        overrideCostTextField.accessibilityLabel = "Override Cost"

        let overrideCostStack = UIStackView(arrangedSubviews: [overrideCostTitle, overrideCostTextField])
        overrideCostStack.axis = .horizontal
        overrideCostStack.spacing = 12
        overrideCostStack.alignment = .center

        overrideCostContainer.addSubview(overrideCostStack)
        overrideCostStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            overrideCostStack.topAnchor.constraint(equalTo: overrideCostContainer.topAnchor, constant: 8),
            overrideCostStack.leadingAnchor.constraint(equalTo: overrideCostContainer.leadingAnchor, constant: 12),
            overrideCostStack.trailingAnchor.constraint(lessThanOrEqualTo: overrideCostContainer.trailingAnchor, constant: -12),
            overrideCostStack.bottomAnchor.constraint(equalTo: overrideCostContainer.bottomAnchor, constant: -8),
            overrideCostTextField.widthAnchor.constraint(greaterThanOrEqualToConstant: 120)
        ])

        // Add both to the row
        costRow.addArrangedSubview(solutionCostContainer)
        costRow.addArrangedSubview(overrideCostContainer)

        // Wrap and add to main stack
        let costRowWrapper = UIView()
        costRowWrapper.addSubview(costRow)
        costRow.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            costRow.topAnchor.constraint(equalTo: costRowWrapper.topAnchor, constant: 12),
            costRow.leadingAnchor.constraint(equalTo: costRowWrapper.leadingAnchor),
            costRow.trailingAnchor.constraint(equalTo: costRowWrapper.trailingAnchor),
            costRow.bottomAnchor.constraint(equalTo: costRowWrapper.bottomAnchor, constant: -12)
        ])

        stackView.addArrangedSubview(costRowWrapper)
        
        stackView.addArrangedSubview(createLabeledFieldView(labelText: "Surveyor Notes", view: surveyorNotesTextView))
        stackView.addArrangedSubview(createLabeledFieldView(labelText: "Photos", view: photosCollectionView))
        stackView.addArrangedSubview(addPhotoButton)
        stackView.addArrangedSubview(createBarrierButton)
        
        
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
            
            locationTextField.heightAnchor.constraint(equalToConstant: 44),
            useCodeTextField.heightAnchor.constraint(equalToConstant: 44),
            dojCodeTextField.heightAnchor.constraint(equalToConstant: 44),
            severityCodeTextField.heightAnchor.constraint(equalToConstant: 44),
            questionTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100),
            desiredInformationTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100),
            existingConditionTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100),
            surveyorNotesTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100),
            photosCollectionView.heightAnchor.constraint(greaterThanOrEqualToConstant: 120),
            addPhotoButton.heightAnchor.constraint(equalToConstant: 44),
            createBarrierButton.heightAnchor.constraint(equalToConstant: 44),
            useDesiredInfoButton.heightAnchor.constraint(equalToConstant: 36),
            useDesiredInfoButton.widthAnchor.constraint(equalToConstant: 200),
            promptForInfoButton.heightAnchor.constraint(equalToConstant: 36),
            promptForInfoButton.widthAnchor.constraint(equalToConstant: 200),
            selectSolutionButton.heightAnchor.constraint(equalToConstant: 50),
            possibleSolutionTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100)
        ])
        
        // Setup pickers
        useCodePickerTableView = setupPickerTableView()
        dojCodePickerTableView = setupPickerTableView()      // Fixed: use same method
        severityCodePickerTableView = setupPickerTableView()  // Fixed: use same method
        
        useCodeTextField.inputView = useCodePickerTableView
        dojCodeTextField.inputView = dojCodePickerTableView
        severityCodeTextField.inputView = severityCodePickerTableView
        
        useCodeTextField.isEnabled = false // until loaded
        
        // Assign tags to identify in delegate methods
        dojCodePickerTableView.tag = 1001
        severityCodePickerTableView.tag = 1002
        
        // Enable DOJ and Severity immediately (static data)
        dojCodeTextField.isEnabled = true
        severityCodeTextField.isEnabled = true
        
        locationTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        existingConditionTextView.delegate = self
        surveyorNotesTextView.delegate = self
        unitsTextField.delegate = self
        
    }
    
    private func configureTextField(_ textField: UITextField, placeholder: String, accessibilityLabel: String) {
        textField.placeholder = placeholder
        textField.font = .systemFont(ofSize: 16)
        textField.textColor = .white
        textField.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        textField.layer.cornerRadius = 8
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        textField.leftViewMode = .always
        
        if textField == useCodeTextField || textField == dojCodeTextField || textField == severityCodeTextField {
            textField.rightView = UIImageView(image: UIImage(systemName: "chevron.down"))
            textField.rightView?.tintColor = .systemYellow
            textField.rightViewMode = .always
            textField.tintColor = .clear
        }
        textField.adjustsFontForContentSizeCategory = true
        textField.accessibilityLabel = accessibilityLabel
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func configureTextView(_ textView: UITextView, text: String?, isEditable: Bool, accessibilityLabel: String) {
        textView.text = text ?? "Enter text here"
        textView.textColor = isEditable ? .white : .lightGray
        textView.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        textView.layer.cornerRadius = 8
        textView.font = .systemFont(ofSize: 16)
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        textView.isEditable = isEditable
        textView.isSelectable = true
        textView.adjustsFontForContentSizeCategory = true
        textView.accessibilityLabel = accessibilityLabel
        textView.delegate = self
        textView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func configureSelectSolutionButton() {
        selectSolutionButton.setTitle("Select Solution", for: .normal)
        selectSolutionButton.setTitleColor(.systemYellow, for: .normal)
        selectSolutionButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        selectSolutionButton.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        selectSolutionButton.layer.cornerRadius = 8
        selectSolutionButton.accessibilityLabel = "Select Solution"
        selectSolutionButton.accessibilityHint = "Opens a list of available solutions"
        selectSolutionButton.addTarget(self, action: #selector(selectSolutionTapped), for: .touchUpInside)
    }
        
    private func configureAddPhotoButton() {
        addPhotoButton.setTitle("Add Photo", for: .normal)
        addPhotoButton.setTitleColor(.systemYellow, for: .normal)
        addPhotoButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        addPhotoButton.titleLabel?.adjustsFontForContentSizeCategory = true
        addPhotoButton.accessibilityLabel = "Add Photo from Camera or Library"
        addPhotoButton.addTarget(self, action: #selector(addPhotoTapped), for: .touchUpInside)
        addPhotoButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func configureCreateBarrierButton() {
        createBarrierButton.setTitle("Create Barrier", for: .normal)
        createBarrierButton.setTitleColor(.systemYellow, for: .normal)
        createBarrierButton.setTitleColor(.systemYellow.withAlphaComponent(0.5), for: .disabled)
        createBarrierButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        createBarrierButton.titleLabel?.adjustsFontForContentSizeCategory = true
        createBarrierButton.accessibilityLabel = "Create Barrier"
        createBarrierButton.addTarget(self, action: #selector(createBarrierTapped), for: .touchUpInside)
        createBarrierButton.isEnabled = false
        createBarrierButton.alpha = 0.5
        createBarrierButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func configureUseDesiredInfoButton() {
        useDesiredInfoButton.setTitle("Use Desired Information", for: .normal)
        useDesiredInfoButton.setTitleColor(.systemYellow, for: .normal)
        useDesiredInfoButton.titleLabel?.font = .systemFont(ofSize: 14)
        useDesiredInfoButton.titleLabel?.adjustsFontForContentSizeCategory = true
        useDesiredInfoButton.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        useDesiredInfoButton.layer.cornerRadius = 8
        useDesiredInfoButton.accessibilityLabel = "Copy Desired Information to Existing Condition"
        useDesiredInfoButton.addTarget(self, action: #selector(useDesiredInfoTapped), for: .touchUpInside)
        useDesiredInfoButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func configurePromptForInfoButton() {
        promptForInfoButton.setTitle("Prompt for Information", for: .normal)
        promptForInfoButton.setTitleColor(.systemYellow, for: .normal)
        promptForInfoButton.titleLabel?.font = .systemFont(ofSize: 14)
        promptForInfoButton.titleLabel?.adjustsFontForContentSizeCategory = true
        promptForInfoButton.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        promptForInfoButton.layer.cornerRadius = 8
        promptForInfoButton.accessibilityLabel = "Prompt for Information"
        promptForInfoButton.accessibilityHint = "Prompts user to enter values for placeholders in Desired Information"
        promptForInfoButton.addTarget(self, action: #selector(promptForInfoTapped), for: .touchUpInside)
        promptForInfoButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupPhotosCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 100)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.scrollDirection = .horizontal
        photosCollectionView.collectionViewLayout = layout
        photosCollectionView.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        photosCollectionView.layer.cornerRadius = 8
        photosCollectionView.delegate = self
        photosCollectionView.dataSource = self
        photosCollectionView.register(PhotoCell.self, forCellWithReuseIdentifier: "PhotoCell")
        photosCollectionView.isUserInteractionEnabled = true
        photosCollectionView.dragInteractionEnabled = true
        photosCollectionView.dragDelegate = self
        photosCollectionView.dropDelegate = self
        photosCollectionView.translatesAutoresizingMaskIntoConstraints = false
        photosCollectionView.accessibilityLabel = "Photos Collection"
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
            view.topAnchor.constraint(equalTo: label.bottomAnchor, constant: labelText.isEmpty ? 0 : 8),
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
        //tableView.register(UITableViewCell.self, forCellWithReuseIdentifier: "PickerCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "PickerCell")
        tableView.backgroundColor = .black
        tableView.separatorColor = .systemYellow
        tableView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 200)
        return tableView
    }
    
    private func updateCreateBarrierButtonState() {
        let isLocationFilled = !(locationTextField.text?.isEmpty ?? true)
        let isUseCodeFilled = selectedUseCode != nil
        let isExistingConditionFilled = existingConditionTextView.text != "Enter text here" && !existingConditionTextView.text.isEmpty
        let isEnabled = isLocationFilled && isUseCodeFilled && isExistingConditionFilled
        createBarrierButton.isEnabled = isEnabled
        createBarrierButton.alpha = isEnabled ? 1.0 : 0.5
        print("Create Barrier button enabled: \(isEnabled)")
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)   // dismisses EVERY keyboard instantly
    }
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
        print("Back to ThirdScreenViewController")
    }
    
    @objc private func selectSolutionTapped() {
        print("ProjectID: \(projectID)")
        let solutionsVC = SolutionsViewController(
             projectNumber: projectID,
             standard: standard,
             qtype: questionType
        )
            solutionsVC.delegate = self
            let nav = UINavigationController(rootViewController: solutionsVC)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
    }
    
    @objc private func addPhotoTapped() {
        let alert = UIAlertController(title: "Add Photo", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default) { _ in
            self.presentImagePicker(sourceType: .camera)
        })
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default) { _ in
            self.presentImagePicker(sourceType: .photoLibrary)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
        print("Add Photo button tapped")
    }
    
    @objc private func useDesiredInfoTapped() {
        existingConditionTextView.text = decodeHTML(desiredInformation) //desiredInformationTextView.text
        existingConditionTextView.textColor = .white
        updateCreateBarrierButtonState()
        print("Copied Desired Information to Existing Condition")
    }
    
    @objc private func promptForInfoTapped() {
        let pattern = "__+"
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            print("Error: Failed to create regex for underscore pattern")
            return
        }
        
        let text = decodeHTML(desiredInformation)
        let nsText = text as NSString
        let matches = regex.matches(in: text, range: NSRange(location: 0, length: nsText.length))
        
        if matches.isEmpty {
            let alert = UIAlertController(title: "No Prompts", message: "No placeholders found in Desired Information.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            print("No underscore placeholders found in desiredInformation")
            return
        }
        
        var segments: [String] = []
        var lastEnd = 0
        for match in matches {
            let range = match.range
            if lastEnd < range.location {
                segments.append(nsText.substring(with: NSRange(location: lastEnd, length: range.location - lastEnd)))
            }
            segments.append("")
            lastEnd = range.location + range.length
        }
        if lastEnd < nsText.length {
            segments.append(nsText.substring(from: lastEnd))
        }
        
        var userInputs: [String] = []
        var currentPromptIndex = 0
        
        func showPrompt() {
            guard currentPromptIndex < matches.count else {
                var finalText = ""
                for (index, segment) in segments.enumerated() {
                    finalText += segment
                    if index < userInputs.count {
                        finalText += userInputs[index]
                    }
                }
                existingConditionTextView.text = finalText
                existingConditionTextView.textColor = .white
                updateCreateBarrierButtonState()
                print("Set existingConditionTextView to: \(finalText)")
                return
            }
            
            var promptMessage = ""
            for (index, segment) in segments.enumerated() {
                promptMessage += segment
                if index < userInputs.count {
                    promptMessage += userInputs[index]
                } else if index == currentPromptIndex {
                    break
                }
            }
            
            let alert = UIAlertController(title: "Enter Value", message: promptMessage, preferredStyle: .alert)
            alert.addTextField { textField in
                textField.placeholder = "Enter value"
                textField.accessibilityLabel = "Prompt Input \(currentPromptIndex + 1)"
            }
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                let input = alert.textFields?.first?.text ?? ""
                userInputs.append(input)
                print("Prompt \(currentPromptIndex + 1): User entered '\(input)'")
                currentPromptIndex += 1
                showPrompt()
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
                print("Prompt cancelled at index \(currentPromptIndex)")
            })
            present(alert, animated: true)
        }
        
        showPrompt()
        print("Prompt for Information button tapped, starting prompts")
    }
    
    private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
            let alert = UIAlertController(title: "Error", message: "Source type not available", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        picker.allowsEditing = false
        present(picker, animated: true)
        print("Presenting image picker with source: \(sourceType)")
    }
    
    @objc private func recalculateCost() {
        guard let solution = selectedSolution else {
            solutionCostLabel.text = "No Cost"
            overrideCostTextField.text = ""
            return
        }
        
        let unitsText = unitsTextField.text?.trimmingCharacters(in: .whitespaces) ?? "1"
        let units = Double(unitsText) ?? 1.0
        
        let totalCost = solution.unitCostValue * units * costFactor
        
        if solution.UnitType.lowercased() == "n/a" || solution.unitCostValue == 0 {
            solutionCostLabel.text = "No Cost"
            overrideCostTextField.text = ""                    // ← DON'T auto-fill override for "No Cost"
        } else {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.minimumFractionDigits = 2
            formatter.maximumFractionDigits = 2
            
            let formatted = formatter.string(from: NSNumber(value: totalCost)) ?? "$0.00"
            solutionCostLabel.text = formatted
            overrideCostTextField.text = ""                    // ← leave blank so user can override if they want
        }
    }
    
    @objc private func createBarrierTapped() {
        guard let location = locationTextField.text,
              let useCode = selectedUseCode,
              let dojCode = selectedDOJCode,
              let severityCode = selectedSeverityCode,
              let existingCondition = existingConditionTextView.text, existingCondition != "Enter text here" else {
            return
        }
        let surveyorNotes = surveyorNotesTextView.text != "Enter text here" ? surveyorNotesTextView.text : nil
        
        let photoBase64Strings = photos.compactMap { photo in
            photo.jpegData(compressionQuality: 0.8)?.base64EncodedString()
        }
        
        print("Submitting barrier with:")
        print("Question ID: \(questionID)")
        print("Location: \(location)")
        print("Use Code: \(useCode)")
        print("DOJ Code: \(dojCode)")
        print("Severity Code: \(severityCode)")
        print("Existing Condition: \(existingCondition)")
        if let notes = surveyorNotes {
            print("Surveyor Notes: \(notes)")
        }
        print("Photos count: \(photoBase64Strings.count)")
        
        let barrierData: [String: Any] = [
            "questionID": questionID,
            "location": location,
            "useCode": useCode,
            "dojCode": dojCode,
            "severityCode": severityCode,
            "existingCondition": existingCondition,
            "surveyorNotes": surveyorNotes ?? "",
            "photos": photoBase64Strings
        ]
        NetworkManager.shared.postBarrier(url: "https://abc.com/surveyors.nsf/createBarrier", data: barrierData) { result in
            DispatchQueue.main.async {
                //TEST CODE
                var barrierQuestionIDs = UserDefaults.standard.stringArray(forKey: "barrierQuestionIDs") ?? []
                if !barrierQuestionIDs.contains(self.questionID) {
                    barrierQuestionIDs.append(self.questionID)
                    UserDefaults.standard.set(barrierQuestionIDs, forKey: "barrierQuestionIDs")
                }
                if let secondVC = self.navigationController?.viewControllers.first(where: { $0 is SecondScreenViewController }) {
                    self.navigationController?.popToViewController(secondVC, animated: true)
                    print("Navigated back to SecondScreenViewController")
                } else {
                    print("Error: SecondScreenViewController not found in navigation stack")
                }
                //END TEST CODE
//                switch result {
//                case .success:
//                    print("Barrier submitted successfully")
//                    var barrierQuestionIDs = UserDefaults.standard.stringArray(forKey: "barrierQuestionIDs") ?? []
//                    if !barrierQuestionIDs.contains(self.questionID) {
//                        barrierQuestionIDs.append(self.questionID)
//                        UserDefaults.standard.set(barrierQuestionIDs, forKey: "barrierQuestionIDs")
//                    }
//                    if let secondVC = self.navigationController?.viewControllers.first(where: { $0 is SecondScreenViewController }) {
//                        self.navigationController?.popToViewController(secondVC, animated: true)
//                        print("Navigated back to SecondScreenViewController")
//                    } else {
//                        print("Error: SecondScreenViewController not found in navigation stack")
//                    }
//                case .failure(let error):
//                    print("Error submitting barrier: \(error)")
//                    let alert = UIAlertController(title: "Error", message: "Failed to create barrier: \(error.localizedDescription)", preferredStyle: .alert)
//                    alert.addAction(UIAlertAction(title: "OK", style: .default))
//                    self.present(alert, animated: true)
//                }
            }
        }
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        updateCreateBarrierButtonState()
    }
    
    
}



extension FourthScreenViewController: UITextFieldDelegate, UITextViewDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        print("Text field \(textField.accessibilityLabel ?? "unknown") will begin editing")
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Enter text here" && textView.isEditable {
            textView.text = ""
            textView.textColor = .white
        }
        print("Text view \(textView.accessibilityLabel ?? "unknown") will begin editing")
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty && textView.isEditable {
            textView.text = "Enter text here"
            textView.textColor = .lightGray
        }
        updateCreateBarrierButtonState()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        updateCreateBarrierButtonState()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == unitsTextField {
            let allowedCharacters = CharacterSet.decimalDigits
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
            
        } else if textField == overrideCostTextField {
            // Allow backspace
            if string.isEmpty { return true }
            
            // Only allow numbers and one decimal point
            let allowed = CharacterSet(charactersIn: "0123456789.")
            guard allowed.isSuperset(of: CharacterSet(charactersIn: string)) else { return false }
            
            let currentText = textField.text ?? ""
            let proposedText = (currentText as NSString).replacingCharacters(in: range, with: string)
            
            // Prevent multiple decimal points
            if proposedText.components(separatedBy: ".").count > 2 { return false }
            return true
        }
        
    return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
            if textField == overrideCostTextField {
                let cleaned = textField.text?.replacingOccurrences(of: "[^0-9.]", with: "", options: .regularExpression)
                if let value = Double(cleaned ?? "0") {
                    textField.text = String(format: "$%.2f", value)
                } else {
                    textField.text = "$0.00"
                }
            }
        }
}

extension FourthScreenViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView.tag {
        case 1001: return dojCodes.count
        case 1002: return severityCodes.count
        default:   return useCodes.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PickerCell", for: indexPath)
        let text: String
        
        switch tableView.tag {
        case 1001:
            text = dojCodes[indexPath.row]
            cell.accessibilityLabel = "DOJ Code \(text)"
        case 1002:
            text = severityCodes[indexPath.row]
            cell.accessibilityLabel = "Severity Code \(text)"
        default:
            text = useCodes[indexPath.row]
            cell.accessibilityLabel = "Use Code \(text)"
        }
        
        cell.textLabel?.text = text
        cell.textLabel?.textColor = .white
        cell.textLabel?.font = .systemFont(ofSize: 16)
        cell.textLabel?.textAlignment = .center
        cell.backgroundColor = .black
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableView.tag {
        case 1001:
            let code = dojCodes[indexPath.row]
            selectedDOJCode = code
            dojCodeTextField.text = code
            dojCodeTextField.resignFirstResponder()
        case 1002:
            let code = severityCodes[indexPath.row]
            selectedSeverityCode = code
            severityCodeTextField.text = code
            severityCodeTextField.resignFirstResponder()
        default:
            let code = useCodes[indexPath.row]
            selectedUseCode = code
            useCodeTextField.text = code
            useCodeTextField.resignFirstResponder()
        }
        updateCreateBarrierButtonState()
    }
}

extension FourthScreenViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            photos.append(image)
            photosCollectionView.reloadData()
            print("Added photo, total count: \(photos.count)")
        }
        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
        print("Image picker cancelled")
    }
}

extension FourthScreenViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        cell.imageView.image = photos[indexPath.item]
        cell.accessibilityLabel = "Photo \(indexPath.item + 1)"
        return cell
    }
}

extension FourthScreenViewController: UICollectionViewDragDelegate, UICollectionViewDropDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let item = photos[indexPath.item]
        let itemProvider = NSItemProvider(object: item)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        return [dragItem]
    }
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: UIImage.self)
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        if collectionView.hasActiveDrag {
            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
        return UICollectionViewDropProposal(operation: .forbidden)
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        guard let destinationIndexPath = coordinator.destinationIndexPath else { return }
        for item in coordinator.items {
            if let sourceIndexPath = item.sourceIndexPath, let image = item.dragItem.localObject as? UIImage {
                photos.remove(at: sourceIndexPath.item)
                photos.insert(image, at: destinationIndexPath.item)
                collectionView.performBatchUpdates {
                    collectionView.deleteItems(at: [sourceIndexPath])
                    collectionView.insertItems(at: [destinationIndexPath])
                }
                coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
                print("Reordered photo from index \(sourceIndexPath.item) to \(destinationIndexPath.item)")
            }
        }
    }
}

// MARK: - SolutionsSelectionDelegate
extension FourthScreenViewController: SolutionsSelectionDelegate {
    
    func didSelectSolution(_ solution: Solution) {
        // Store the selected solution so we can recalculate later
        selectedSolution = solution
        
        // 1. Possible Solution
        possibleSolutionTextView.text = solution.Solution
        possibleSolutionTextView.textColor = .white
        
        // 2. Unit Type – clean whitespace + proper color
        let cleanUnitType = solution.UnitType.trimmingCharacters(in: .whitespacesAndNewlines)
        unitTypeValueLabel.text = cleanUnitType
        unitTypeValueLabel.textColor = cleanUnitType.lowercased() == "n/a" ? .lightGray : .white
        
        // 3. Units – correct default value
        if cleanUnitType.lowercased() == "n/a" {
            unitsTextField.text = "0"
        } else {
            unitsTextField.text = "1"           // Always start at 1 for real units
        }
        
        // 4. Trigger full cost recalculation (handles everything: N/A, $0, real costs)
        recalculateCost()
        
        print("Solution selected:")
        print("   → \(solution.SolutionCode) | \(cleanUnitType) | Unit Cost: $\(solution.unitCostValue)")
        print("   → Total Cost: \(solutionCostLabel.text ?? "No Cost")")
    }
}

class PhotoCell: UICollectionViewCell {
    let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
