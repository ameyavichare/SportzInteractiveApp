//
//  WebService.swift
//  SportzInteractiveApp
//
//  Created by Ameya Vichare on 27/03/21.
//

import Foundation
import Combine

enum HttpMethod: String {
    
    case get = "GET"
    case post = "POST"
}

struct Resource<T: Decodable> {
    
    let url: URL
    let httpMethod: HttpMethod = .get
    let body: Data? = nil
}

extension Resource {
    
    init(_ url: URL) {
        self.url = url
    }
}

struct WebServiceConstants {
    
    static let baseUrl = "https://cricket.yahoo.net"
    static let matchDetailApi = "/sifeeds/cricket/live/json/sapk01222019186652.json" //"/sifeeds/cricket/live/json/nzin01312019187360.json"
}

final class WebService {
    
    static let shared = WebService()
    private init() { }
    
    func load<T>(_ resource: Resource<T>) -> AnyPublisher<T, Error> {
        
        var urlRequest = URLRequest(url: resource.url)
        urlRequest.httpMethod = resource.httpMethod.rawValue
        urlRequest.httpBody = resource.body
        
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .map{ $0.data }
            .decode(type: T.self, decoder: JSONDecoder())
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}
