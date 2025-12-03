//
//  SecondScreenViewController.swift
//  QuestionsApp
//
//  Created by William Cather on 6/25/25.
//

// MARK: File - Views/SecondScreenViewController.swift
import UIKit

class SecondScreenViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private let tableView = UITableView()
        private var questions: [QuestionListItem] = []
        private var barrierQuestionIDs: [String] = []
        private let project: String
        private let state: String
        private let form: String
        private var costFactor: Double = 0.0
        
        var hideBarrierButton: Bool = false
        
        init(project: String, state: String, form: String, costFactor: Double) {
            self.project = project
            self.state = state
            self.form = form
            self.costFactor = costFactor
            super.init(nibName: nil, bundle: nil)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .white
            
            // THIS IS THE ONLY PLACE WE SET THE BACK BUTTON — SAFE FOREVER
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                title: "Back",
                style: .plain,
                target: self,
                action: #selector(backTapped)
            )
            navigationItem.leftBarButtonItem?.tintColor = .systemYellow
            
            setupUI()
            fetchQuestions()
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            barrierQuestionIDs = UserDefaults.standard.stringArray(forKey: "barrierQuestionIDs") ?? []
            tableView.reloadData()
            print("Loaded barrierQuestionIDs: \(barrierQuestionIDs)")
        }
        
        private func setupUI() {
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.spacing = 20
            stackView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(stackView)
            
            let breadcrumbLabel = UILabel()
            breadcrumbLabel.text = "Project: \(project) | State: \(state) | Form: \(form)"
            breadcrumbLabel.font = .systemFont(ofSize: 14)
            breadcrumbLabel.adjustsFontForContentSizeCategory = true
            breadcrumbLabel.accessibilityLabel = "Breadcrumb: Project \(project), State \(state), Form \(form)"
            stackView.addArrangedSubview(breadcrumbLabel)
            
            tableView.delegate = self
            tableView.dataSource = self
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "QuestionCell")
            tableView.translatesAutoresizingMaskIntoConstraints = false
            tableView.backgroundColor = .white
            stackView.addArrangedSubview(tableView)
            
            NSLayoutConstraint.activate([
                stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
                stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
                stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
                stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
            ])
        }
        
        private func fetchQuestions() {
            NetworkManager.shared.fetchQuestions(project: project, state: state, form: form) { [weak self] result in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    switch result {
                    case .success(let questions):
                        self.questions = questions.sorted { self.compareAlphanumeric($0.questionNumber, $1.questionNumber) }
                        self.tableView.reloadData()
                        print("Fetched questions count: \(self.questions.count)")
                    case .failure(let error):
                        print("Error fetching questions: \(error)")
                        let alert = UIAlertController(title: "Error", message: "Failed to load questions: \(error.localizedDescription)", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(alert, animated: true)
                    }
                }
            }
        }
        
        private func compareAlphanumeric(_ str1: String, _ str2: String) -> Bool {
            let segments1 = splitAlphanumeric(str1)
            let segments2 = splitAlphanumeric(str2)
            
            let minLength = min(segments1.count, segments2.count)
            for i in 0..<minLength {
                let seg1 = segments1[i]
                let seg2 = segments2[i]
                
                if let num1 = Int(seg1), let num2 = Int(seg2) {
                    if num1 != num2 { return num1 < num2 }
                } else {
                    if seg1 != seg2 { return seg1 < seg2 }
                }
            }
            return segments1.count < segments2.count
        }
        
        private func splitAlphanumeric(_ str: String) -> [String] {
            var segments: [String] = []
            var currentSegment = ""
            var isDigit = str.first?.isNumber ?? false
            
            for char in str {
                let charIsDigit = char.isNumber
                if charIsDigit == isDigit {
                    currentSegment.append(char)
                } else {
                    segments.append(currentSegment)
                    currentSegment = String(char)
                    isDigit = charIsDigit
                }
            }
            if !currentSegment.isEmpty {
                segments.append(currentSegment)
            }
            return segments
        }
        
        @objc private func backTapped() {
            navigationController?.popViewController(animated: true)
        }
        
        // MARK: UITableViewDelegate & DataSource
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return questions.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionCell", for: indexPath)
            let question = questions[indexPath.row]
            
            let attributedString = NSMutableAttributedString()
            attributedString.append(NSAttributedString(string: question.questionNumber.decodingHTMLEntities(), attributes: [.foregroundColor: UIColor.blue]))
            attributedString.append(NSAttributedString(string: "\t\t"))
            attributedString.append(NSAttributedString(string: question.acCode.decodingHTMLEntities(), attributes: [.foregroundColor: UIColor.red]))
            attributedString.append(NSAttributedString(string: "\n"))
            
            let questionColor: UIColor = question.acCode.contains(state) ? UIColor(red: 142/255, green: 35/255, blue: 35/255, alpha: 1) : .black
            attributedString.append(NSAttributedString(string: question.question.decodingHTMLEntities(), attributes: [.foregroundColor: questionColor]))
            
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.attributedText = attributedString
            cell.textLabel?.adjustsFontForContentSizeCategory = true
            
            if question.header == "Yes" && question.subHeader == "Yes" {
                cell.backgroundColor = .white
                cell.textLabel?.textColor = .blue
            } else if question.header == "Yes" {
                cell.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 0, alpha: 1)
                cell.textLabel?.textColor = .red
            } else if question.subHeader == "Yes" {
                cell.backgroundColor = UIColor(red: 239/255, green: 239/255, blue: 239/255, alpha: 1)
                cell.textLabel?.textColor = UIColor(red: 0, green: 128/255, blue: 0, alpha: 1)
            } else if question.header == "No" && question.subHeader == "Yes" {
                cell.backgroundColor = .white
                cell.textLabel?.textColor = UIColor(red: 0, green: 0, blue: 255/255, alpha: 1)
            } else if question.acCode.contains("B") {
                cell.backgroundColor = UIColor(red: 255/255, green: 174/255, blue: 185/255, alpha: 1)
            } else if question.qtype.first == "S" {
                cell.backgroundColor = .white
                cell.textLabel?.textColor = .gray
            } else if question.stricter == "Yes" && question.stricterType == "Primary" && question.stricterState.contains(state) {
                cell.backgroundColor = UIColor(red: 255/255, green: 174/255, blue: 185/255, alpha: 1)
            } else {
                cell.backgroundColor = .white
            }
            
            // Green checkmark for barriers
            cell.accessoryView = barrierQuestionIDs.contains(question.questionID!) ? UIImageView(image: UIImage(systemName: "checkmark.circle.fill")?.withTintColor(.systemGreen)) : nil
            cell.accessoryType = barrierQuestionIDs.contains(question.questionID!) ? .none : .disclosureIndicator
            cell.accessibilityLabel = "Question: \(question.questionNumber.decodingHTMLEntities()), \(question.question.decodingHTMLEntities())\(barrierQuestionIDs.contains(question.questionID!) ? ", has barrier" : "")"
            
            return cell
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let question = questions[indexPath.row]
            
            guard let questionID = question.questionID, !questionID.isEmpty else {
                let alert = UIAlertController(title: "Error", message: "Invalid question ID", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
                tableView.deselectRow(at: indexPath, animated: true)
                return
            }
            
            let thirdVC = ThirdScreenViewController(
                questionID: questionID,
                project: project,
                state: state,
                form: form,
                questionType: question.qtype,
                costFactor: costFactor
            )
            thirdVC.hideBarrierButton = self.hideBarrierButton
            navigationController?.pushViewController(thirdVC, animated: true)
            tableView.deselectRow(at: indexPath, animated: true)
        }
}
