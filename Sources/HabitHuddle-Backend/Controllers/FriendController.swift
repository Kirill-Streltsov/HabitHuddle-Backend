//
//  FriendController.swift
//  HabitHuddle-Backend
//
//  Created by Kirill on 12.05.25.
//

import Vapor

struct FriendController: RouteCollection {
    
    func boot(routes: any RoutesBuilder) throws {
        let friends = routes.grouped(UserToken.authenticator()).grouped("friends")
        friends.post("add", use: addFriend)
        friends.delete(":friendID", use: removeFriend)
    }
    
    func addFriend(req: Request) async throws -> HTTPStatus {
        let data = try req.content.decode(AddFriendRequest.self)
        let user = try req.auth.require(User.self)
        
        guard let friend = try await User.find(data.friendID, on: req.db) else {
            throw Abort(.notFound)
        }
        
        // Add both directions
        let link1 = UserFriend(userID: try user.requireID(), friendID: try friend.requireID())
        let link2 = UserFriend(userID: try friend.requireID(), friendID: try user.requireID())
        
        try await link1.save(on: req.db)
        try await link2.save(on: req.db)
        
        return .ok
    }
    
    func removeFriend(_ req: Request) async throws -> HTTPStatus {
        let user = try req.auth.require(User.self)
        
        guard let friendID = req.parameters.get("friendID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Missing or invalid friend ID")
        }
        
        guard let friend = try await User.find(friendID, on: req.db) else {
            throw Abort(.notFound, reason: "Friend not found")
        }
        
        try await user.$friends.detach(friend, on: req.db)
        return .ok
    }
}

struct AddFriendRequest: Content {
    let friendID: UUID
}
