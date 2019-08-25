//
//  APIRequest.swift
//  iOSConcepts
//
//  Created by Sateesh Yegireddi on 24/08/19.
//  Copyright © 2019 Company. All rights reserved.
//

import Foundation

enum HTTPMethod {
    case GET
    case POST
    case PUT
    case DELETE
}

protocol APIRequest {
    var method: HTTPMethod { get }
    var path: EndPoint { get }
    var parameters: [EndPoint: String] { get }
    var body: [String: Any]? { get }
    var dispatchGroup: DispatchGroup? { get }
}

extension APIRequest {
    func request() -> URLRequest {
        
        //Create baseURL with the given endPoint string
        guard let baseURL = URL(string: EndPoint.baseURL.rawValue) else {
            fatalError("APIRequest.request(with \(EndPoint.baseURL.rawValue)): Unable to create URL from String")
        }
        
        //Create URLComponents by appending path to baseURL
        guard var components = URLComponents(url: baseURL.appendingPathComponent(path.rawValue),
                                             resolvingAgainstBaseURL: false)
            else {
                fatalError("APIRequest.request(with \(baseURL)): Unable to create URL components")
        }
        
        //Add URLQueryItems with given queries and values to URLComponents
        components.queryItems = parameters.map {
            URLQueryItem(name: String($0.rawValue), value: String($1))
        }
        
        //Create URL from the components
        guard let url = components.url else {
            fatalError("APIRequest.request(with \(baseURL)): Could not get url")
        }
        
        //Create URLRequest with given URL
        var request = URLRequest(url: url)
        
        //Set HTTP input method
        request.httpMethod = String(describing: method)
        
        //Create the HTTP body with given data and assign it to request
        if let body = body {
            let httpBody = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
            request.httpBody = httpBody
        }
        
        //Add HTTP Headers to request
        let _ = HeaderField.allHeaders.map {
            request.addValue($0.value.rawValue, forHTTPHeaderField: $0.key.rawValue)
        }
        
        //Return the created request
        return request
    }
}

private enum HeaderField: String {
    case accept = "Accept"
    case contentType = "Content-Type"
    case applicationJSON = "application/json"
    
    static var allHeaders: [Self: Self] {
        var headers = [Self: Self]()
        headers[.accept] = .applicationJSON
        headers[.contentType] = .applicationJSON
        return headers
    }
}
