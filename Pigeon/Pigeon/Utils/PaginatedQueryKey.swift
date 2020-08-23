//
//  PaginatedQueryKey.swift
//  Pigeon
//
//  Created by Fernando Martín Ortiz on 23/08/2020.
//  Copyright © 2020 Fernando Martín Ortiz. All rights reserved.
//

import Foundation

protocol PaginatedQueryKey: QueryKeyType {
    static var first: Self { get }
    var next: Self { get }
}

extension PaginatedQueryKey {
    var asQueryKey: QueryKey {
        QueryKey(value: queryKeyValue)
    }
}

struct NumericPaginatedQueryKey: PaginatedQueryKey {
    let current: Int
    
    var queryKeyValue: String {
        current.description
    }
    
    static var first: NumericPaginatedQueryKey {
        NumericPaginatedQueryKey(current: 0)
    }
    
    var next: NumericPaginatedQueryKey {
        NumericPaginatedQueryKey(current: current + 1)
    }
}
