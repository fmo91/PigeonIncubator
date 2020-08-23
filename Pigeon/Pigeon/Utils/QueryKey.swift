//
//  QueryKey.swift
//  Pigeon
//
//  Created by Fernando Martín Ortiz on 23/08/2020.
//  Copyright © 2020 Fernando Martín Ortiz. All rights reserved.
//

import Foundation

struct QueryKey: Hashable {
    let rawValue: String
}

extension QueryKey {
    var notificationName: Notification.Name {
        Notification.Name("\(rawValue)_notification")
    }
}
