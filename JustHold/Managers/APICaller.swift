import UIKit

final class APICaller {
    
    public static let shared = APICaller()
    
    private struct Constants {
        static let apiKey = "cb5rid2ad3i0dk7b9ca0"
        static let sandboxApiKey = "sandbox_cb5rid2ad3i0dk7b9cag" // api для тестов (больше возможностей)
        static let baseUrl = "https://finnhub.io/api/v1/"
    }
    
    private init() {}
    
    //MARK: - Public
    
    // get stock info
    
    // search coins
    public func search(query: String,
                       completion: @escaping (Result<SearchResponse, Error>) -> Void) {
        guard let safeQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }
        request(url: url(for: .search,
                         queryParams: ["q":safeQuery]),
                expecting: SearchResponse.self,
                completion: completion)
    }
    
    //MARK: - Private
    
    private enum Endpoint: String {
        case search // = "search" (если использовать search.rawValue)
    }
    
    private enum APIError: Error {
        case noDataReturned
        case invalidUrl
    }
    
    // responsible for creating and returning the URL
    private func url(for endpoint: Endpoint,
                     queryParams: [String: String] = [:]) -> URL? {
        var urlString = Constants.baseUrl + endpoint.rawValue
        
        var queryItems = [URLQueryItem]()
        
        // Add any parametes
        for (name, value) in queryParams {
            queryItems.append(.init(name: name, value: value))
        }
        
        // Add token
        queryItems.append(.init(name: "token", value: Constants.apiKey)) // init от URLQueryItem
        
        // Convert query items to suffix string
        let queryString = queryItems.map { "\($0.name)=\($0.value ?? "")" }.joined(separator: "&") // из каждого элемента берем name и добавляем к нему value, объединяем их все друг с дургом с разделителем &
        
        urlString += "?" + queryString
        
        print("\n\(urlString)") // как часто строку принтит, должна быть задержка 0.5с
        
        return URL(string: urlString)
    }
    
    private func request<T: Codable>(url: URL?,
                                     expecting: T.Type, // tries to decode response to given model type
                                     completion: @escaping(Result<T, Error>) -> Void) {
        guard let url = url else {
            completion(.failure(APIError.invalidUrl))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.failure(APIError.noDataReturned))
                }
                return
            }
            
            do {
                let result = try JSONDecoder().decode(expecting, from: data)
                completion(.success(result))
            }
            catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
