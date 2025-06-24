import Foundation

// Adapt to return FoodItem array for app usage
class FatSecretAPI {
    static let shared = FatSecretAPI()
    // Enter Your own clientID and clientSecret from FatSecret Platform
    private let clientId = ""
    private let clientSecret = ""
    private(set) var accessToken: String?
    private var tokenExpiry: Date?
    
    private init() {}
    
    private func refreshTokenIfNeeded(completion: @escaping (Result<String, Error>) -> Void) {
        if let token = accessToken, let expiry = tokenExpiry, expiry > Date() {
            completion(.success(token))
            return
        }
        getAccessToken(completion: completion)
    }
    
    private func getAccessToken(completion: @escaping (Result<String, Error>) -> Void) {
        let url = URL(string: "https://oauth.fatsecret.com/connect/token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let body = "grant_type=client_credentials&scope=basic"
        request.httpBody = body.data(using: .utf8)
        let basicAuth = "\(clientId):\(clientSecret)".data(using: .utf8)!.base64EncodedString()
        request.setValue("Basic \(basicAuth)", forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                completion(.failure(error ?? URLError(.badServerResponse)))
                return
            }
            do {
                let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
                self.accessToken = tokenResponse.access_token
                self.tokenExpiry = Date().addingTimeInterval(TimeInterval(tokenResponse.expires_in))
                completion(.success(tokenResponse.access_token))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func searchFoods(query: String, completion: @escaping (Result<[FoodItem], Error>) -> Void) {
        refreshTokenIfNeeded { result in
            switch result {
            case .success(let token):
                let urlString = "https://platform.fatsecret.com/rest/server.api?method=foods.search&search_expression=\(query)&format=json"
                guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) else {
                    completion(.failure(URLError(.badURL)))
                    return
                }
                var request = URLRequest(url: url)
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                URLSession.shared.dataTask(with: request) { data, _, error in
                    guard let data = data, error == nil else {
                        completion(.failure(error ?? URLError(.badServerResponse)))
                        return
                    }
                    
                    do {
                        let response = try JSONDecoder().decode(FoodSearchResponse.self, from: data)
                        let foodItems = response.foods.food.map { summary in
                            // Parse macros from food_description (basic parsing)
                            let desc = summary.food_description.lowercased()
                            func extract(_ label: String) -> Double {
                                if let part = desc.components(separatedBy: "\(label): ").dropFirst().first?.components(separatedBy: "g").first ??
                                    desc.components(separatedBy: "\(label): ").dropFirst().first?.components(separatedBy: "mg").first ??
                                    desc.components(separatedBy: "\(label): ").dropFirst().first?.components(separatedBy: "kcal").first
                                {
                                    return Double(part.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
                                }
                                return 0
                            }
                            let cals = extract("calories")
                            let fat = extract("fat")
                            let carbs = extract("carbs")
                            let protein = extract("protein")
                            // Sugar, sodium, calcium not included in search response, will fetch in details
                            return FoodItem(
                                id: summary.food_id,
                                name: summary.food_name,
                                servingDescription: summary.food_description,
                                protein: protein,
                                carbs: carbs,
                                fats: fat,
                                calories: cals,
                                sugar: 0,
                                sodium: 0,
                                calcium: 0
                            )
                        }
                        completion(.success(foodItems))
                    } catch {
                        completion(.failure(error))
                    }
                }.resume()
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Food Details (Full Nutrients)
    
    func getFoodDetails(
        foodId: String,
        completion: @escaping (Result<FoodItem, Error>) -> Void
    ) {
        refreshTokenIfNeeded { result in
            switch result {
            case .success(let token):
                let urlString = "https://platform.fatsecret.com/rest/server.api?method=food.get&food_id=\(foodId)&format=json"
                guard let url = URL(string: urlString) else {
                    completion(.failure(URLError(.badURL)))
                    return
                }
                var request = URLRequest(url: url)
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                URLSession.shared.dataTask(with: request) { data, _, error in
                    guard let data = data, error == nil else {
                        completion(.failure(error ?? URLError(.badServerResponse)))
                        return
                    }
                    
                    print(String(data: data, encoding: .utf8) ?? "No JSON")
                    
                    do {
                        let response = try JSONDecoder().decode(FoodDetailsResponse.self, from: data)
                        guard let serving = response.food.servings.serving.first else {
                            completion(.failure(NSError(domain: "NoServing", code: 0)))
                            return
                        }
                        // Parse all macronutrients and micronutrients
                        let foodItem = FoodItem(
                            id: response.food.food_id,
                            name: response.food.food_name,
                            servingDescription: serving.serving_description,
                            protein: Double(serving.protein) ?? 0,
                            carbs: Double(serving.carbohydrate) ?? 0,
                            fats: Double(serving.fat) ?? 0,
                            calories: Double(serving.calories) ?? 0,
                            sugar: Double(serving.sugar ?? "0") ?? 0,
                            sodium: Double(serving.sodium ?? "0") ?? 0,
                            calcium: Double(serving.calcium ?? "0") ?? 0
                        )
                        completion(.success(foodItem))
                    } catch {
                        completion(.failure(error))
                    }
                }.resume()
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

struct TokenResponse: Codable {
    let access_token: String
    let expires_in: Int
    let token_type: String
}

struct FoodSearchResponse: Codable {
    let foods: Foods
    struct Foods: Codable {
        let food: [FoodSummary]
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            if let array = try? container.decode([FoodSummary].self, forKey: .food) {
                self.food = array
            } else if let single = try? container.decode(FoodSummary.self, forKey: .food) {
                self.food = [single]
            } else {
                self.food = []
            }
        }
        enum CodingKeys: String, CodingKey {
            case food
        }
    }
}

struct FoodSummary: Codable {
    let food_id: String
    let food_name: String
    let food_type: String
    let brand_name: String?
    let food_description: String
    let food_url: String?
}


// Models for decoding the detailed response
struct FoodDetailsResponse: Codable {
    let food: FoodDetails
}

struct FoodDetails: Codable {
    let food_id: String
    let food_name: String
    let servings: FoodServings
}

struct FoodServings: Codable {
    let serving: [FoodServing]

    // Custom decoder to handle both array and single object
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let array = try? container.decode([FoodServing].self, forKey: .serving) {
            self.serving = array
        } else if let single = try? container.decode(FoodServing.self, forKey: .serving) {
            self.serving = [single]
        } else {
            self.serving = []
        }
    }

    enum CodingKeys: String, CodingKey {
        case serving
    }
}

struct FoodServing: Codable {
    let serving_description: String
    let calories: String
    let carbohydrate: String
    let protein: String
    let fat: String
    let sugar: String?
    let sodium: String?
    let calcium: String?
}
