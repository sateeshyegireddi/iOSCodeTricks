//
//  DataManager.swift
//  Networking
//
//  Created by Sateesh Yegireddi on 25/08/19.
//  Copyright © 2019 Company. All rights reserved.
//

import Foundation

protocol FetchTracks {
    func fetchTracks(with request: APIRequest,
                            handler: @escaping (_ tacks: [Track]?, _ error: Field?) -> ())
}

class DataManager {}

extension DataManager: FetchTracks {
    func fetchTracks(with request: APIRequest,
                            handler: @escaping (_ tacks: [Track]?, _ error: Field?) -> ()) {
        APIClient.send(request) { (result: Result<Response, Field>) in
            switch result {
            case .success(let response):
                handler(response.tracks, nil)
            case .failure(let field):
                handler(nil, field)
            }
        }
    }
}
