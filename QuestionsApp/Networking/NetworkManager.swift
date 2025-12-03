//
//  NetworkManager.swift
//  QuestionsApp
//
//  Created by William Cather on 6/25/25.
//

// MARK: File - Networking/NetworkManager.swift
import Foundation

class NetworkManager {
    static let shared = NetworkManager()
        
        private let baseURL = "https://ada1.evanterry.com"
        
        // MARK: - Dynamic Basic Auth (stored securely)
        var isAuthenticated: Bool {
            return username != nil && password != nil
        }
        
        private var username: String? {
            get { KeychainHelper.shared.get(.username) }
            set { KeychainHelper.shared.save(newValue, for: .username) }
        }
        
        private var password: String? {
            get { KeychainHelper.shared.get(.password) }
            set { KeychainHelper.shared.save(newValue, for: .password) }
        }
        
        private init() {}
        
        // MARK: - Login (saves credentials on success)
        func login(username: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
            guard let url = URL(string: "https://ada1.evanterry.com?login") else {
                completion(.failure(URLError(.badURL)))
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            
            let body = "username=\(username)&password=\(password)"
            request.httpBody = body.data(using: .utf8)
            
            URLSession.shared.dataTask(with: request) { _, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    let code = (response as? HTTPURLResponse)?.statusCode ?? -1
                    completion(.failure(NSError(domain: "Login", code: code, userInfo: [NSLocalizedDescriptionKey: "Invalid credentials"])))
                    return
                }
                
                // SUCCESS → Save credentials securely
                self.username = username
                self.password = password
                
                print("Login successful – credentials saved to Keychain")
                completion(.success(()))
            }.resume()
        }
        
        // MARK: - Logout
        func logout() {
            username = nil
            password = nil
            print("Logged out – credentials cleared")
        }
    
    // MARK: - Generic Helper (keeps your code DRY)
        private func performDataTask<T: Decodable>(with request: URLRequest, completion: @escaping (Result<T, Error>) -> Void) {
            URLSession.shared.dataTask(with: request) { data, _, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let data = data else {
                    completion(.failure(NetworkError.noData))
                    return
                }
                do {
                    let decoded = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(decoded))
                } catch {
                    completion(.failure(error))
                }
            }.resume()
        }
        
        // MARK: - Private: Create Request with Current Basic Auth
        private func createRequest(url: URL) -> URLRequest {
            var request = URLRequest(url: url)
            
            if let username = username, let password = password {
                let authString = "\(username):\(password)"
                if let authData = authString.data(using: .utf8) {
                    let base64 = authData.base64EncodedString()
                    request.setValue("Basic \(base64)", forHTTPHeaderField: "Authorization")
                }
            }
            
            return request
        }
    
    func fetchProjects(completion: @escaping (Result<[Project], Error>) -> Void) {
        let urlString = "\(baseURL)/evanterry/Surveyors.nsf/xpActiveProjects.xsp"
        print("Fetching projects: \(urlString)")
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        let request = createRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error fetching projects: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            guard let data = data else {
                print("No data received for projects")
                completion(.failure(NetworkError.noData))
                return
            }
            do {
                let projects = try JSONDecoder().decode([Project].self, from: data)
                print("Successfully fetched projects: \(projects.map { $0.projectNumber })")
                completion(.success(projects))
            } catch {
                print("Error decoding projects: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchCampuses(project: String, completion: @escaping (Result<[Campus], Error>) -> Void) {
        let urlString = "\(baseURL)/master/surveyquestionstplt.nsf/xpCampusListByProject.xsp?prj=\(project.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        print("Fetching campuses: \(urlString)")
        guard let url = URL(string: urlString) else {
            print("Invalid URL for campuses with project: \(project)")
            completion(.failure(NetworkError.invalidURL))
            return
        }
        let request = createRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error fetching campuses for project \(project): \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Invalid response status code for campuses")
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            guard let data = data else {
                print("No data received for campuses")
                completion(.failure(NetworkError.noData))
                return
            }
            do {
                let campuses = try JSONDecoder().decode([Campus].self, from: data)
                print("Successfully fetched campuses for project \(project): \(campuses.map { $0.campus })")
                completion(.success(campuses))
            } catch {
                print("Error decoding campuses: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchSites(project: String, campus: String, completion: @escaping (Result<[Site], Error>) -> Void) {
        let urlString = "\(baseURL)/master/surveyquestionstplt.nsf/xpSitesListByProjectCampus.xsp?prj=\(project.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&campus=\(campus.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        print("Fetching sites: \(urlString)")
        guard let url = URL(string: urlString) else {
            print("Invalid URL for sites with project: \(project), campus: \(campus)")
            completion(.failure(NetworkError.invalidURL))
            return
        }
        let request = createRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error fetching sites for project \(project), campus \(campus): \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Invalid response status code for sites")
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            guard let data = data else {
                print("No data received for sites")
                completion(.failure(NetworkError.noData))
                return
            }
            do {
                let sites = try JSONDecoder().decode([Site].self, from: data)
                print("Successfully fetched sites for project \(project), campus \(campus): \(sites.map { $0.site })")
                completion(.success(sites))
            } catch {
                print("Error decoding sites: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchTeamMembers(project: String, completion: @escaping (Result<[String], Error>) -> Void) {
        let urlString = "\(baseURL)/evanterry/surveyors.nsf/xpTeamMembers.xsp?ID=\(project.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        print("Fetching team members: \(urlString)")
        guard let url = URL(string: urlString) else {
            print("Invalid URL for team members with project: \(project)")
            completion(.failure(NetworkError.invalidURL))
            return
        }
        let request = createRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error fetching team members for project \(project): \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Invalid response status code for team members")
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            guard let data = data else {
                print("No data received for team members")
                completion(.failure(NetworkError.noData))
                return
            }
            do {
                let response = try JSONDecoder().decode(TeamResponse.self, from: data)
                print("Successfully fetched team members for project \(project): \(response.team)")
                completion(.success(response.team))
            } catch {
                print("Error decoding team members: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchStates(completion: @escaping (Result<[State], Error>) -> Void) {
        let urlString = "\(baseURL)/evanterry/surveyors.nsf/xpSurveyStandards.xsp"
        print("Fetching states: \(urlString)")
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        let request = createRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error fetching states: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            guard let data = data else {
                print("No data received for states")
                completion(.failure(NetworkError.noData))
                return
            }
            do {
                let states = try JSONDecoder().decode([State].self, from: data)
                print("Successfully fetched states: \(states)")
                completion(.success(states))
            } catch {
                print("Error decoding states: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchForms(projectNumber: String, completion: @escaping (Result<[Form], Error>) -> Void) {
        let urlString = "\(baseURL)/evanterry/surveyors.nsf/xpSurveyForms.xsp?ID=\(projectNumber.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        print("Fetching forms: \(urlString)")
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        let request = createRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error fetching forms: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Invalid response status code for forms")
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            guard let data = data else {
                print("No data received for forms")
                completion(.failure(NetworkError.noData))
                return
            }
            do {
                let forms = try JSONDecoder().decode([Form].self, from: data)
                print("Successfully fetched forms for project \(projectNumber): \(forms)")
                completion(.success(forms))
            } catch {
                print("Error decoding forms: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchQuestions(project: String, state: String, form: String, completion: @escaping (Result<[QuestionListItem], Error>) -> Void) {
        let urlString = "\(baseURL)/master/surveyquestionstplt.nsf/QuestionsListJSONv1.xsp?prj=\(project)&std=\(state)&form=\(form)"
        print("Fetching questions: \(urlString)")
        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        let request = createRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error fetching questions: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            guard let data = data else {
                print("No data received for questions")
                completion(.failure(NetworkError.noData))
                return
            }
            do {
                let questions = try JSONDecoder().decode([QuestionListItem].self, from: data)
                print("Successfully fetched questions for project \(project), state \(state), form \(form): \(questions)")
                completion(.success(questions))
            } catch {
                print("Error decoding questions: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchQuestionDetails(questionID: String, completion: @escaping (Result<QuestionDetail, Error>) -> Void) {
        let urlString = "\(baseURL)/master/surveyquestionstplt.nsf/QuestionDetailsByIDKeyJSONv1.xsp?ID=\(questionID)"
        print("Fetching question details: \(urlString)")
        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        let request = createRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error fetching question details: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            guard let data = data else {
                print("No data received for question details")
                completion(.failure(NetworkError.noData))
                return
            }
            do {
                let details = try JSONDecoder().decode([QuestionDetail].self, from: data).first
                if let details = details {
                    print("Successfully fetched question details for ID \(questionID)")
                    completion(.success(details))
                } else {
                    print("No question details found for ID \(questionID)")
                    completion(.failure(NetworkError.noData))
                }
            } catch {
                print("Error decoding question details: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchUseCodes(projectID: String, completion: @escaping (Result<[String], Error>) -> Void) {
        let urlString = "\(baseURL)/evanterry/surveyors.nsf/xpUseCodesProject.xsp?ID=\(projectID.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        print("Fetching use codes: \(urlString)")
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        let request = createRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error fetching use codes: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Invalid response status code for use codes")
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            guard let data = data else {
                print("No data received for use codes")
                completion(.failure(NetworkError.noData))
                return
            }
            do {
                let useCodes = try JSONDecoder().decode([UseCode].self, from: data)
                let codes = useCodes.map { $0.code }
                print("Successfully fetched use codes for project \(projectID): \(codes)")
                completion(.success(codes))
            } catch {
                print("Error decoding use codes: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchSolutions(project: String,standard: String, type: String, completion: @escaping (Result<[Solution], Error>) -> Void) {
        
        // Percent-encode all parameters to be URL-safe
        let encodedProject = project.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? project
        let encodedStandard = standard.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? standard
        let encodedType = type.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? type
        
        // Build the real API URL
        let urlString = "\(baseURL)/PSRevisions.nsf/xpSolutionsByProjectStandardType.xsp" +
        "?prj=\(encodedProject)" +
        "&std=\(encodedStandard)" +
        "&type=\(encodedType)"
        
        print("Fetching solutions: \(urlString)")
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        let request = createRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error fetching use codes: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Invalid response status code for use codes")
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            guard let data = data else {
                print("No data received for use codes")
                completion(.failure(NetworkError.noData))
                return
            }
            // Decode JSON → [Solution]
            do {
                //let decoder = JSONDecoder()
                    let solutions = try JSONDecoder().decode([Solution].self, from: data)  // ← Must be [Solution].self
                    
                    // Sort so they're always in consistent order
                    let sorted = solutions.sorted { $0.SolutionCode < $1.SolutionCode }
                    
                    DispatchQueue.main.async {
                        completion(.success(sorted))
                    }
                
            } catch {
                print("JSON Decoding failed: \(error)")
                if let decodingError = error as? DecodingError {
                    print("DecodingError details: \(decodingError)")
                }
                
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    
    func postBarrier(url: String, data: [String: Any], completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: url) else {
            print("Invalid URL for posting barrier: \(url)")
            completion(.failure(NetworkError.invalidURL))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let authString = "\(username):\(password)"
        if let authData = authString.data(using: .utf8) {
            let authValue = "Basic \(authData.base64EncodedString())"
            request.setValue(authValue, forHTTPHeaderField: "Authorization")
        }
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
            request.httpBody = jsonData
        } catch {
            print("Error encoding barrier data: \(error)")
            completion(.failure(error))
            return
        }
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error posting barrier: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                print("Invalid response status code for barrier: \(statusCode)")
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            print("Successfully posted barrier")
            completion(.success(()))
        }.resume()
    }
    
    
    struct TeamResponse: Codable {
        let team: [String]
        
        enum CodingKeys: String, CodingKey {
            case team = "Team"
        }
    }
    
    enum NetworkError: Error {
        case invalidURL
        case invalidResponse
        case noData
    }
}
