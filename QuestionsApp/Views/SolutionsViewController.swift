//
//  SolutionsViewController.swift
//  QuestionsApp
//
//  Created by William Cather on 12/1/25.
//

import UIKit

protocol SolutionsSelectionDelegate: AnyObject {
    func didSelectSolution(_ solution: Solution)
}

class SolutionsViewController: UIViewController {
    
    private let tableView = UITableView()
    private var solutions: [Solution] = []
    
    private let projectNumber: String
    private let standard: String
    private let qtype: String
    
    weak var delegate: SolutionsSelectionDelegate?
    
    init(projectNumber: String, standard: String, qtype: String) {
        self.projectNumber = projectNumber
        self.standard = standard
        self.qtype = qtype
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchSolutions()
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        title = "Select a Solution"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(cancelTapped)
        )
        navigationItem.leftBarButtonItem?.tintColor = .systemYellow
        
        tableView.backgroundColor = .black
        tableView.separatorColor = UIColor.systemYellow.withAlphaComponent(0.3)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120  // Slightly taller for long descriptions
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SolutionCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func fetchSolutions() {
        NetworkManager.shared.fetchSolutions(
            project: projectNumber,
            standard: standard,
            type: qtype
        ) { [weak self] result in
            // ALWAYS dismiss the alert — no matter what happens
            DispatchQueue.main.async {
                // Dismiss FIRST — this is the key
                //loadingAlert.dismiss(animated: true) {
                    switch result {
                    case .success(let solutions):
                        print("Successfully loaded \(solutions.count) solutions")
                        self?.solutions = solutions
                        self?.tableView.reloadData()
                        
                        if solutions.isEmpty {
                            self?.showEmptyState("No solutions found for this question.")
                        }
                        
                    case .failure(let error):
                        print("Failed to load solutions: \(error)")
                        self?.showEmptyState("Error loading solutions.\n\(error.localizedDescription)")
                    }
                //}
            }
        }
    }
    
    private func showEmptyState(_ message: String) {
        let label = UILabel()
        label.text = message
        label.textColor = .lightGray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18)
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 40),
            label.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -40)
        ])
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
}

// MARK: - Table View
extension SolutionsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return solutions.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SolutionCell", for: indexPath)
        let solution = solutions[indexPath.row]
        
        // Main title: Solution text
        let title = UILabel()
        title.text = solution.Solution
        title.font = .systemFont(ofSize: 20, weight: .medium)
        title.textColor = .white
        title.numberOfLines = 0
        title.lineBreakMode = .byWordWrapping
        
        // SubTitle (only if it exists and isn't empty)
        var subtitleLabel: UILabel?
        if let subTitle = solution.SubTitle?.trimmingCharacters(in: .whitespacesAndNewlines),
           !subTitle.isEmpty {
            subtitleLabel = UILabel()
            subtitleLabel?.text = "SubTitle: \(subTitle)"
            subtitleLabel?.font = .systemFont(ofSize: 15)
            subtitleLabel?.textColor = UIColor.systemYellow.withAlphaComponent(0.9)
            subtitleLabel?.numberOfLines = 0
        }
        
        // Cost + Unit Type on bottom
        //let costText = solution.unitCostValue == 0 ? "No Cost" : String(format: "$%.2f", solution.unitCost)
        let footerLabel = UILabel()
        //footerLabel.text = "\(solution.UnitType)  • \(costText)"
        footerLabel.text = solution.UnitType
        footerLabel.font = .systemFont(ofSize: 14)
        footerLabel.textColor = .systemYellow
        footerLabel.textAlignment = .left
        
        // Stack them vertically
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 6
        stackView.alignment = .fill
        
        stackView.addArrangedSubview(title)
        if let subtitleLabel = subtitleLabel {
            stackView.addArrangedSubview(subtitleLabel)
        }
        stackView.addArrangedSubview(footerLabel)
        
        // Clear old content and add new
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        stackView.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 12),
            stackView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -12)
        ])
        
        cell.backgroundColor = .black
        cell.selectionStyle = .default
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedSolution = solutions[indexPath.row]
        delegate?.didSelectSolution(selectedSolution)
        dismiss(animated: true)
    }
}
