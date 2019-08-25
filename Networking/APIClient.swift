//
//  APIClient.swift
//  iOSConcepts
//
//  Created by Sateesh Yegireddi on 24/08/19.
//  Copyright © 2019 Company. All rights reserved.
//

import Foundation

struct APIClient {
    static func send<T: Codable>(_ urlRequest: APIRequest,
                                 completion: @escaping (_ result:  Result<T, Field>) -> ()) {
        
        //Create request with given baseURL
        let request = urlRequest.request()
        
        //Add the task to dispatchGroup
        urlRequest.dispatchGroup?.enter()
        
        //Create the Session Configuration with default/ephimeral type
        let configuration = URLSessionConfiguration.default
        
        //Set its time-out interval to certain seconds
        configuration.timeoutIntervalForRequest = 30
        
        //Create the session with created configuration
        let session = URLSession(configuration: configuration)
        
        //Create dataTask with the specific request
        let task = session.dataTask(with: request) { (data, _, error) in
            
            //Remove the task from dispatchGroup
            urlRequest.dispatchGroup?.leave()
            
            //Return if there is any error from server
            if let error = error {
                completion(Result.failure(Field.error(error.localizedDescription)))
                return
            }
            
            //Return if there is no data received from server
            guard let data = data else {
                completion(Result.failure(Field.noData))
                return
            }
            
            //Parse data and return associate model or JSON parse failure error.
            do {
                let model = try JSONDecoder().decode(T.self, from: data)
                completion(Result.success(model))
            } catch {
                completion(Result.failure(Field.JSON))
            }
        }
        
        //Resume the task if its not started or suspended.
        task.resume()
    }
}
