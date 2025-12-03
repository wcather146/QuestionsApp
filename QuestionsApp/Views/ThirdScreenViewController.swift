import UIKit

class ThirdScreenViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private var questionDetail: QuestionDetail?
    private let questionID: String
    private let project: String
    private let state: String
    private let form: String
    private let questionType: String
    private let costFactor: Double
    
    
    var hideBarrierButton: Bool = false
    
    // MARK: - Init
    init(questionID: String,
         project: String,
         state: String,
         form: String,
         questionType: String,
         costFactor: Double) {
            
       self.questionID = questionID
       self.project = project
       self.state = state
       self.form = form
       self.questionType = questionType
        self.costFactor = costFactor
       super.init(nibName: nil, bundle: nil)
    }
    	
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        fetchQuestionDetails()
        
        // Always set Back button
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Back",
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )
        
        // Only show Barrier button if NOT in view-only mode
        if !hideBarrierButton {
            let barrierButton = UIBarButtonItem(
                title: "Barrier",
                style: .plain,
                target: self,
                action: #selector(barrierTapped)
            )
            barrierButton.tintColor = .systemYellow
            navigationItem.rightBarButtonItem = barrierButton
        }
        
//        if hideBarrierButton {
//            navigationItem.rightBarButtonItem?.isHidden = true
//            navigationItem.rightBarButtonItem?.isEnabled = false
//            navigationItem.rightBarButtonItem?.accessibilityElementsHidden = true
//            print("Barrier button hidden due to navigation from WelcomeScreen")
//        }
    }
    
    private func setupUI() {
//        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backTapped))
//        navigationItem.leftBarButtonItem = backButton
//        
//        let barrierButton = UIBarButtonItem(title: "Barrier", style: .plain, target: self, action: #selector(barrierTapped))
//        barrierButton.tintColor = .systemYellow // Branding: yellow
//        barrierButton.accessibilityLabel = "Open Barrier Details"
//        navigationItem.rightBarButtonItem = barrierButton
    
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        
    }
    
    private func updateUI() {
        guard let detail = questionDetail else { return }
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        let titleLabel = UILabel()
        titleLabel.text = "Question Details"
        titleLabel.font = .boldSystemFont(ofSize: 24)
        stackView.addArrangedSubview(titleLabel)
        
        let breadcrumbLabel = UILabel()
        breadcrumbLabel.text = "Project: \(project) | State: \(state) | Form: \(form)"
        breadcrumbLabel.font = .systemFont(ofSize: 14)
        stackView.addArrangedSubview(breadcrumbLabel)
        
        let questionInfoTitle = UILabel()
        questionInfoTitle.text = "Question Information"
        questionInfoTitle.textColor = .red
        questionInfoTitle.font = .boldSystemFont(ofSize: 18)
        stackView.addArrangedSubview(questionInfoTitle)
        
        // Horizontal stack for Question Number and AC Code
        let horizontalStack = UIStackView()
        horizontalStack.axis = .horizontal
        horizontalStack.spacing = 20
        horizontalStack.distribution = .fillEqually
        horizontalStack.alignment = .top
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false
        
        let questionNumberView = createFieldView(label: "Question Number", value: detail.questionNumber.decodingHTMLEntities(), labelColor: nil)
        let acCodeView = createFieldView(label: "AC Code", value: detail.acCode?.decodingHTMLEntities() ?? "N/A", labelColor: nil)
        
        horizontalStack.addArrangedSubview(questionNumberView)
        horizontalStack.addArrangedSubview(acCodeView)
        stackView.addArrangedSubview(horizontalStack)
        
        // Center the horizontal stack with flexible margins
        NSLayoutConstraint.activate([
            horizontalStack.leadingAnchor.constraint(greaterThanOrEqualTo: stackView.leadingAnchor, constant: 20).withPriority(.defaultHigh),
            horizontalStack.trailingAnchor.constraint(lessThanOrEqualTo: stackView.trailingAnchor, constant: -20).withPriority(.defaultHigh),
            horizontalStack.centerXAnchor.constraint(equalTo: stackView.centerXAnchor)
        ])
        
        let questionInfoFields: [(label: String, value: String, labelColor: UIColor?)] = [
            ("Disability Type", detail.disabilityType.decodingHTMLEntities(), nil),
            ("Barrier Question", detail.barrierQuestion.decodingHTMLEntities(), nil),
            ("Interpretation", detail.interpretation?.decodingHTMLEntities() ?? "", UIColor(red: 0, green: 100/255, blue: 0, alpha: 1)),
            ("Note to Surveyor", detail.noteToSurveyor?.decodingHTMLEntities() ?? "", .blue),
            ("Acceptable Measurement", detail.acceptableMeasurement?.decodingHTMLEntities() ?? "", nil),
            ("Desired Information", detail.desiredInformation.decodingHTMLEntities(), nil)
        ]
        
        for field in questionInfoFields {
            stackView.addArrangedSubview(createFieldView(label: field.label, value: field.value, labelColor: field.labelColor))
        }
        
        let standardDetailsTitle = UILabel()
        standardDetailsTitle.text = "Standard Details"
        standardDetailsTitle.textColor = .red
        standardDetailsTitle.font = .boldSystemFont(ofSize: 18)
        stackView.addArrangedSubview(standardDetailsTitle)
        
        let standardDetailsFields: [(label: String, value: String, labelColor: UIColor?)] = [
            ("Section Number", detail.sectionNumber?.decodingHTMLEntities() ?? "", nil),
            ("Figure Number", detail.figureNumber?.decodingHTMLEntities() ?? "", nil),
            ("Code Reference", detail.codeReference?.decodingHTMLEntities() ?? "", nil),
            ("Corada Reference", detail.coradaReference?.decodingHTMLEntities() ?? "", nil),
        ]
        
        for field in standardDetailsFields {
            stackView.addArrangedSubview(createFieldView(label: field.label, value: field.value, labelColor: field.labelColor))
        }
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func createFieldView(label: String, value: String, labelColor: UIColor?) -> UIView {
        let container = UIView()
        let labelView = UILabel()
        labelView.text = label
        labelView.font = .boldSystemFont(ofSize: 16)
        labelView.textColor = labelColor ?? .black
        labelView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(labelView)
        
        if label == "Corada Reference" {
            let linkStack = UIStackView()
            linkStack.axis = .vertical
            linkStack.spacing = 14
            linkStack.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(linkStack)
            
            // Normalize newlines and handle multiple separators
            let normalizedValue = value
                .replacingOccurrences(of: "\\n\\n", with: "\n\n")
                .replacingOccurrences(of: "\\n", with: "\n\n")
                .replacingOccurrences(of: "^", with: "\n\n")
            print("Corada Reference raw value: \(value)")
            print("Corada Reference normalized value: \(normalizedValue)")
            
            // Split on multiple separators: newlines or spaces
            let links = normalizedValue
                .components(separatedBy: CharacterSet(charactersIn: "\n\n\n "))
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            print("Corada Reference links: \(links)")
            
            for link in links {
                if let url = URL(string: link), UIApplication.shared.canOpenURL(url) {
                    let textView = UITextView()
                    textView.text = link
                    textView.font = .systemFont(ofSize: 14)
                    textView.textColor = .black
                    textView.isSelectable = true
                    textView.isEditable = false
                    textView.isScrollEnabled = false
                    textView.dataDetectorTypes = .link
                    textView.textContainer.lineBreakMode = .byWordWrapping
                    textView.textContainerInset = UIEdgeInsets(top: 2, left: 0, bottom: 2, right: 0)
                    textView.translatesAutoresizingMaskIntoConstraints = false
                    linkStack.addArrangedSubview(textView)
                } else {
                    let valueView = UILabel()
                    valueView.text = link
                    valueView.font = .systemFont(ofSize: 14)
                    valueView.textColor = .black
                    valueView.numberOfLines = 0
                    valueView.translatesAutoresizingMaskIntoConstraints = false
                    linkStack.addArrangedSubview(valueView)
                }
            }
            
            linkStack.setNeedsLayout()
            linkStack.layoutIfNeeded()
            
            NSLayoutConstraint.activate([
                labelView.topAnchor.constraint(equalTo: container.topAnchor),
                labelView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                linkStack.topAnchor.constraint(equalTo: labelView.bottomAnchor, constant: 5),
                linkStack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                linkStack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                linkStack.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            ])
        } else if label == "Code Reference" {
            let textView = UITextView()
            textView.isEditable = false
            textView.isScrollEnabled = false
            textView.textContainerInset = UIEdgeInsets(top: 2, left: 0, bottom: 2, right: 0)
            textView.textContainer.lineBreakMode = .byWordWrapping
            textView.textContainer.lineFragmentPadding = 0
            textView.backgroundColor = .white
            textView.translatesAutoresizingMaskIntoConstraints = false
            
            let targetStrings = [
                "ADA (1991) Code Reference:",
                "ADA (2010) Code Reference:",
                "State Code Reference:",
                "ANSI Code Reference:",
                "UFAS Code Reference:"
            ]
            print("Code Reference raw value: \(value)")
            
            let attributedString = NSMutableAttributedString()
            var matchedStrings: [String] = []
            
            // Find all target strings in the text
            for target in targetStrings {
                if value.contains(target) {
                    matchedStrings.append(target)
                }
            }
            
            // Sort matches by their position in the original text
            let matches = matchedStrings.sorted { (s1, s2) -> Bool in
                guard let range1 = value.range(of: s1), let range2 = value.range(of: s2) else { return false }
                return range1.lowerBound < range2.lowerBound
            }
            print("Code Reference matched strings: \(matches)")
            
            // Track if we've processed the first target string
            var isFirstTarget = true
            
            // Process text, bolding target strings and adding \n before subsequent targets
            var currentIndex = value.startIndex
            for target in matches {
                guard let range = value.range(of: target, range: currentIndex..<value.endIndex) else { continue }
                
                // Add text before the target string
                let beforeText = String(value[currentIndex..<range.lowerBound])
                if !beforeText.isEmpty {
                    attributedString.append(NSAttributedString(string: beforeText, attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.black]))
                }
                
                // Add \n before subsequent target strings (not the first)
                if !isFirstTarget {
                    attributedString.append(NSAttributedString(string: "\n\n", attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.black]))
                }
                
                // Add the bolded target string
                attributedString.append(NSAttributedString(string: target, attributes: [.font: UIFont.boldSystemFont(ofSize: 14), .foregroundColor: UIColor.black]))
                
                // Update current index and first-target flag
                currentIndex = range.upperBound
                isFirstTarget = false
            }
            
            // Add remaining text after the last match
            if currentIndex < value.endIndex {
                let remaining = String(value[currentIndex..<value.endIndex])
                attributedString.append(NSAttributedString(string: remaining, attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.black]))
            }
            
            // If no target strings found, use the original text
            if matches.isEmpty {
                attributedString.append(NSAttributedString(string: value, attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.black]))
            }
            
            // Debug: Log attributed string attributes at key positions
            for target in matches {
                if let range = attributedString.string.range(of: target) {
                    let nsRange = NSRange(range, in: attributedString.string)
                    let attributes = attributedString.attributes(at: nsRange.location, effectiveRange: nil)
                    let font = attributes[.font] as? UIFont
                    let isBold = font?.fontDescriptor.symbolicTraits.contains(.traitBold) ?? false
                    print("Code Reference attributes for '\(target)' at range \(nsRange): font = \(font?.fontName ?? "nil"), isBold = \(isBold)")
                }
            }
            
            // Debug: Log attributed string with escaped newlines
            let escapedString = attributedString.string.replacingOccurrences(of: "\n", with: "\\n")
            print("Code Reference processed text (escaped): \(escapedString)")
            print("Code Reference processed text: \(attributedString.string)")
            textView.attributedText = attributedString
            print("Code Reference textView attributed text length: \(textView.attributedText?.length ?? 0)")
            textView.setNeedsDisplay()
            textView.setNeedsLayout()
            textView.layoutIfNeeded()
            
            container.addSubview(textView)
            
            NSLayoutConstraint.activate([
                labelView.topAnchor.constraint(equalTo: container.topAnchor),
                labelView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                textView.topAnchor.constraint(equalTo: labelView.bottomAnchor, constant: 5),
                textView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                textView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                textView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            ])
        } else {
            let valueView = UILabel()
            valueView.text = value
            valueView.font = .systemFont(ofSize: 14)
            valueView.textColor = labelColor ?? .black
            valueView.numberOfLines = 0
            valueView.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(valueView)
            
            NSLayoutConstraint.activate([
                labelView.topAnchor.constraint(equalTo: container.topAnchor),
                labelView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                valueView.topAnchor.constraint(equalTo: labelView.bottomAnchor, constant: 5),
                valueView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                valueView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                valueView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            ])
        }
        
        return container
    }
    
    private func fetchQuestionDetails() {
        NetworkManager.shared.fetchQuestionDetails(questionID: questionID) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let detail):
                    self?.questionDetail = detail
                    self?.updateUI()
                case .failure(let error):
                    print("Error fetching question details: \(error)")
                }
            }
        }
    }
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func barrierTapped() {
        guard let desiredInformation = questionDetail?.desiredInformation else {
            let alert = UIAlertController(title: "Error", message: "Question details not loaded. Please try again later.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
//    // Load Project from UserDefaults
//        guard let projectJSON = UserDefaults.standard.string(forKey: "selectedProject"),
//           let projectData = projectJSON.data(using: .utf8),
//           let project = try? JSONDecoder().decode(Project.self, from: projectData) else {
//            let alert = UIAlertController(title: "Error", message: "Selected project not found.", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .default))
//            present(alert, animated: true)
//           return
//        }
//            
        // Load State from UserDefaults
//        guard let stateJSON = UserDefaults.standard.string(forKey: "selectedState"),
//                let stateData = stateJSON.data(using: .utf8),
//                let selectedState = try? JSONDecoder().decode(State.self, from: stateData) else {
//                let alert = UIAlertController(title: "Error", message: "State information not found.", preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "OK", style: .default))
//                present(alert, animated: true)
//                return
//            }
        
        //guard let questionItem = currentQuestionItem else {  // ← CHANGE THIS if needed
        //     showAlert(title: "Error", message: "Question data not available.")
        //     return
        //}
        
        
        let fourthVC = FourthScreenViewController(
            questionID: questionID,
            barrierQuestion: questionDetail?.barrierQuestion,
            desiredInformation: desiredInformation,
            projectID: project, //UserDefaults.standard.string(forKey: "selectedProject") ?? "",
            standard: state, //selectedState.standard,
            questionType: questionType,
            costFactor: costFactor
        )
        navigationController?.pushViewController(fourthVC, animated: true)
        print("Navigating to FourthScreenViewController with Desired Information: \(desiredInformation)")
        print("Navigating to FourthScreenViewController")
        print("   Question Type: \(questionType)")
        print("   Standard: \(state)")
    }
}

private extension NSLayoutConstraint {
    func withPriority(_ priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }
}
