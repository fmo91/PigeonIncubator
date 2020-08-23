//
//  QueryCacheListener.swift
//  Pigeon
//
//  Created by Fernando Martín Ortiz on 23/08/2020.
//  Copyright © 2020 Fernando Martín Ortiz. All rights reserved.
//

import Foundation
import Combine

protocol QueryCacheListener {
    associatedtype Response: Codable
}

extension QueryCacheListener {
    func listenQueryCache(for key: QueryKey) -> AnyPublisher<QueryState<Response>, Never> {
        NotificationCenter.default.publisher(for: key.notificationName)
            .map(\.object)
            .filter { $0 is Response }
            .map { .succeed($0 as! Response) }
            .eraseToAnyPublisher()
    }
}
