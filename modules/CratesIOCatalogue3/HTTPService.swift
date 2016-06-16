//
//  HTTPService.swift
//  CratesIOCatalogue3
//
//  Created by Hoon H. on 2016/06/05.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation
import BoltsSwift
import EonilJSON

enum HTTPError: ErrorType {
    case UnknownError
}

struct HTTPService {
    private init() {
    }
    static func getJSON(u: NSURL) -> Task<JSON.Value> {
        let completion = TaskCompletionSource<JSON.Value>()
        let task = NSURLSession.sharedSession().dataTaskWithURL(u) { (data: NSData?, response: NSURLResponse?, error: NSError?) in
            guard error == nil else {
                assert(completion.task.completed == false)
                completion.trySetError(error ?? HTTPError.UnknownError)
                return
            }
            guard let data = data else {
                assert(completion.task.completed == false)
                completion.trySetError(HTTPError.UnknownError)
                return
            }
            do {
                let j = try JSON.deserialize(data)
                assert(completion.task.completed == false)
                completion.trySetResult(j)
                return
            }
            catch let error {
                assert(completion.task.completed == false)
                completion.trySetError(error)
                return
            }
        }
        task.resume()
        return completion.task
    }
}

