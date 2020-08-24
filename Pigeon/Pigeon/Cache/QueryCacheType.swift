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
    private let wrappedCache: QueryCacheType
    
    init(wrappedCache: QueryCacheType) {
        self.wrappedCache = wrappedCache
    }
    
    private(set) static var `default`: QueryCacheType = inMemory.wrappedCache
    static func setDefault(_ wrapper: QueryCache) {
        QueryCache.default = wrapper.wrappedCache
    }
    
    static var inMemory: QueryCache { .init(wrappedCache: InMemoryQueryCache.shared) }
    static var userDefaults: QueryCache { .init(wrappedCache: UserDefaultsQueryCache.shared) }
}
