//
//  ContentView.swift
//  Pigeon
//
//  Created by Fernando Martín Ortiz on 23/08/2020.
//  Copyright © 2020 Fernando Martín Ortiz. All rights reserved.
//

import SwiftUI
import Combine

struct ContentView: View {
    var body: some View {
        UsersList()
    }
}

struct User: Codable {
    let id: Int
    let name: String
}

struct Album: Codable {
    let id: Int
    let title: String
}

extension QueryKey {
    static let users: QueryKey = QueryKey(value: "users")
    static func albums(forUser user: User) -> QueryKey {
        QueryKey(value: "albums_\(user.id)")
    }
}

struct UsersList: View {
    @ObservedObject var users = Query<Void, [User]>(
        key: .users,
        behavior: .startImmediately(()),
        cache: QueryCache.inMemory,
        fetcher: {
            URLSession.shared
                .dataTaskPublisher(for: URL(string: "https://jsonplaceholder.typicode.com/users")!)
                .map(\.data)
                .decode(type: [User].self, decoder: JSONDecoder())
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
    )
    
    var body: some View {
        switch users.state {
        case let .succeed(userItems):
            return AnyView(
                NavigationView {
                    List(userItems, id: \.id) { user in
                        NavigationLink(destination: AlbumsList(user: user)) {
                            Text(user.name)
                        }
                    }
                    .navigationBarTitle("Users")
                }
            )
        default:
            return AnyView(
                NavigationView {
                    Text("Loading")
                        .navigationBarTitle("Users")
                }
            )
        }
    }
}

struct AlbumsList: View {
    @ObservedObject var albums: Query<User, [Album]>
    @ObservedObject var postAlbum: Mutation<Void, Void> = Mutation {
        return Just(())
            .tryMap({})
            .eraseToAnyPublisher()
    }
    
    private let user: User
    
    init(user: User) {
        self.user = user
        albums = Query<User, [Album]>(
            key: .albums(forUser: user),
            behavior: .startImmediately(user),
            fetcher: { user in
                URLSession.shared
                    .dataTaskPublisher(for: URL(string: "https://jsonplaceholder.typicode.com/users/\(user.id)/albums")!)
                    .map(\.data)
                    .decode(type: [Album].self, decoder: JSONDecoder())
                    .receive(on: DispatchQueue.main)
                    .eraseToAnyPublisher()
            }
        )
    }
    
    var body: some View {
        List(albums.state.value ?? [], id: \.id) { album in
            HStack {
                Text(album.title)
                Button(action: {
                    self.postAlbum.execute(with: ()) { _, invalidate in
                        invalidate(.albums(forUser: self.user), self.user)
                    }
                }) {
                    Text("Press Me")
                }
            }
        }
        .navigationBarTitle("Albums")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
