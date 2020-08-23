//
//  Mutation.swift
//  Pigeon
//
//  Created by Fernando Martín Ortiz on 23/08/2020.
//  Copyright © 2020 Fernando Martín Ortiz. All rights reserved.
//

import Foundation
import Combine

final class Mutation<Request, Response>: ObservableObject {
    typealias State = QueryState<Response>
    typealias QueryFetcher = (Request) -> AnyPublisher<Response, Error>
    
    @Published var state = State.none
    private let fetcher: QueryFetcher
    private var cancellables = Set<AnyCancellable>()
    
    init(fetcher: @escaping QueryFetcher) {
        self.fetcher = fetcher
    }
    
    func execute(
        with request: Request,
        onSuccess: @escaping (
            Response,
            (QueryKey, Any?) -> Void
        ) -> Void = { _, _ in }
    ) {
        state = .loading
        fetcher(request)
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
                    self.state = .succeed(response)
                    let invalidator = QueryInvalidator()
                    onSuccess(response, invalidator.invalidateQuery)
                }
            )
            .store(in: &cancellables)
    }
}
