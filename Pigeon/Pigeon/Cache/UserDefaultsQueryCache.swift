//
//  UserDefaultsQueryCache.swift
//  Pigeon
//
//  Created by Fernando Martín Ortiz on 23/08/2020.
//  Copyright © 2020 Fernando Martín Ortiz. All rights reserved.
//

import Foundation

final class UserDefaultsQueryCache: QueryCacheType {
    static let shared = UserDefaultsQueryCache()
    private init() {}
    
    func save<T: Codable>(_ value: T, for key: QueryKey) {
        guard let data = try? JSONEncoder().encode(value) else {
            return
        }
        UserDefaults.standard.set(data, forKey: key.queryKeyValue)
        UserDefaults.standard.synchronize()
    }
    
    func invalidate(for key: QueryKey) {
        UserDefaults.standard.removeObject(forKey: key.queryKeyValue)
    }
    
    func get<T: Codable>(for key: QueryKey) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key.queryKeyValue) else {
            return nil
        }
        return try? JSONDecoder().decode(T.self, from: data)
    }
}
