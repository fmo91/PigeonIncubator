//
//  QueryCacheType.swift
//  Pigeon
//
//  Created by Fernando Martín Ortiz on 23/08/2020.
//  Copyright © 2020 Fernando Martín Ortiz. All rights reserved.
//

import Foundation

protocol QueryCacheType {
    func save<T: Codable>(_ value: T, for key: QueryKey)
    func invalidate(for key: QueryKey)
    func get<T: Codable>(for key: QueryKey) -> T?
}

struct QueryCache {
    static var inMemory: QueryCacheType { InMemoryQueryCache.shared }
    static var userDefaults: QueryCacheType { UserDefaultsQueryCache.shared }
}
