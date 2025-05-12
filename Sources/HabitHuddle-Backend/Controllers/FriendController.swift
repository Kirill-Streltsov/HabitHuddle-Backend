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

        // Add both directions
        let link1 = UserFriend(userID: try user.requireID(), friendID: try friend.requireID())
        let link2 = UserFriend(userID: try friend.requireID(), friendID: try user.requireID())

        try await link1.save(on: req.db)
        try await link2.save(on: req.db)

        return .ok
    }
}

struct AddFriendRequest: Content {
    let userID: UUID
    let friendID: UUID
}
