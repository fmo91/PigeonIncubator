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
    static let users: QueryKey = QueryKey(rawValue: "users")
    static func albums(forUser user: User) -> QueryKey {
        QueryKey(rawValue: "albums_\(user.id)")
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
    
    init(user: User) {
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
        switch albums.state {
        case let .succeed(albumItems):
            return AnyView(
                List(albumItems, id: \.id) { album in
                    Text(album.title)
                }
                .navigationBarTitle("Albums")
            )
        default:
            return AnyView(Text("Loading").navigationBarTitle("Albums"))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
