//
//  QueryKey.swift
//  Pigeon
//
//  Created by Fernando Martín Ortiz on 23/08/2020.
//  Copyright © 2020 Fernando Martín Ortiz. All rights reserved.
//

import Foundation

protocol QueryKeyType {
    var queryKeyValue: String { get }
}

struct QueryKey: Hashable, QueryKeyType {
    let queryKeyValue: String
    
    init(value: String) {
        self.queryKeyValue = value
    }
    
    func appending(_ suffix: String) -> QueryKey {
        return QueryKey(value: "\(queryKeyValue)_\(suffix)")
    }
    
    func appending(_ key: QueryKeyType) -> QueryKey {
        return appending(key.queryKeyValue)
    }
}

extension QueryKeyType {
    var notificationName: Notification.Name {
        Notification.Name("\(queryKeyValue)_notification")
    }
    var invalidationNotificationName: Notification.Name {
        Notification.Name("\(queryKeyValue)_notification_invalidation")
    }
}
