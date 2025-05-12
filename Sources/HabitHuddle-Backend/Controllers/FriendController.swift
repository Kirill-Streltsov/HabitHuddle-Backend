//
//  FriendController.swift
//  HabitHuddle-Backend
//
//  Created by Kirill on 12.05.25.
//

import Vapor

struct FriendController {
    func addFriend(req: Request) async throws -> HTTPStatus {
        let data = try req.content.decode(AddFriendRequest.self)
        guard let user = try await User.find(data.userID, on: req.db),
              let friend = try await User.find(data.friendID, on: req.db) else {
            throw Abort(.notFound)
        }

        let link = UserFriend(userID: try! user.requireID(), friendID: try! friend.requireID())
        try await link.save(on: req.db)
        return .ok
    }
}

struct AddFriendRequest: Content {
    let userID: UUID
    let friendID: UUID
}
