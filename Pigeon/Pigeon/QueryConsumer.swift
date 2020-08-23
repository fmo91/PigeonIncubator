//
//  QueryConsumer.swift
//  Pigeon
//
//  Created by Fernando Martín Ortiz on 23/08/2020.
//  Copyright © 2020 Fernando Martín Ortiz. All rights reserved.
//

import Foundation
import Combine

final class QueryConsumer<Response: Codable>: ObservableObject, QueryCacheListener {
    typealias State = QueryState<Response>
    @Published var state = State.none
    private var cancellables = Set<AnyCancellable>()
    
    init(
        key: QueryKey,
        cache: QueryCacheType = UserDefaultsQueryCache.shared
    ) {
        if let cachedResponse: Response = cache.get(for: key) {
            state = .succeed(cachedResponse)
        }
        listenQueryCache(for: key)
            .assign(to: \.state, on: self)
            .store(in: &cancellables)
    }
}
