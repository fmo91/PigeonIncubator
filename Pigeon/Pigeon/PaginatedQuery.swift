//
//  PaginatedQuery.swift
//  Pigeon
//
//  Created by Fernando Martín Ortiz on 23/08/2020.
//  Copyright © 2020 Fernando Martín Ortiz. All rights reserved.
//

import Foundation
import Combine

final class PaginatedQuery<Request, PageIdentifier: PaginatedQueryKey, Response: Codable>: ObservableObject, QueryCacheListener, QueryInvalidationListener {
    enum FetchingBehavior {
        case startWhenRequested
        case startImmediately(Request)
    }
    typealias State = QueryState<Response>
    typealias QueryFetcher = (Request, PageIdentifier) -> AnyPublisher<Response, Error>
    
    @Published var state = State.none
    @Published var currentPage: PageIdentifier
    private let cache: QueryCacheType
    private let fetcher: QueryFetcher
    private var lastRequest: Request?
    private var cancellables = Set<AnyCancellable>()
    
    init(
        key: PageIdentifier,
        behavior: FetchingBehavior = .startWhenRequested,
        cache: QueryCacheType = UserDefaultsQueryCache.shared,
        fetcher: @escaping QueryFetcher
    ) {
        self.currentPage = key
        self.cache = cache
        self.fetcher = fetcher
        
        start(for: behavior, key: key)
        
        listenQueryCache(for: key.asQueryKey)
            .assign(to: \.state, on: self)
            .store(in: &cancellables)
        
        listenQueryInvalidation(for: key.asQueryKey)
            .sink { (request: Request) in
                self.refetch(
                    request: request,
                    page: key
                )
            }
            .store(in: &cancellables)
    }
    
    private func start(for behavior: FetchingBehavior, key: PageIdentifier) {
        switch behavior {
        case .startWhenRequested:
            if let cachedResponse: Response = self.cache.get(for: key.asQueryKey) {
                state = .succeed(cachedResponse)
            }
            break
        case let .startImmediately(request):
            refetch(request: request, page: key)
        }
    }
    
    func fetchNextPage() {
        guard let lastRequest = self.lastRequest else {
            return
        }
        
        self.currentPage = self.currentPage.next
        refetch(request: lastRequest, page: self.currentPage)
    }
    
    func refetch(request: Request, page: PageIdentifier) {
        self.lastRequest = request
        self.currentPage = page
        self.cache.invalidate(for: currentPage.asQueryKey)
        NotificationCenter.default.post(
            name: self.currentPage.notificationName,
            object: nil
        )
        state = .loading
        fetcher(request, page)
            .sink(
                receiveCompletion: { (completion: Subscribers.Completion<Error>) in
                    switch completion {
                    case let .failure(error):
                        self.state = .failed(error)
                    case .finished:
                        break
                    }
                },
                receiveValue: { (response: Response) in
                    NotificationCenter.default.post(
                        name: self.currentPage.notificationName,
                        object: response
                    )
                    self.cache.save(response, for: self.currentPage.asQueryKey)
                    self.state = .succeed(response)
                }
            )
            .store(in: &cancellables)
    }
}
