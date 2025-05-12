//
//  UserController.swift
//  HabitHuddle-Backend
//
//  Created by Kirill on 12.05.25.
//

import Vapor
import Fluent

struct UserController {
    func register(req: Request) async throws -> User.Public {
        let data = try req.content.decode(CreateUserRequest.self)
        
        // Ensure email doesn't already exist
        if try await User.query(on: req.db).filter(\.$email == data.email).first() != nil {
            throw Abort(.conflict, reason: "Email already registered.")
        }
        
        // Hash the password
        let hash = try await req.password.async.hash(data.password)
        
        let user = User(email: data.email, passwordHash: hash)
        try await user.save(on: req.db)
        
        return user.toPublic()
    }
    
    
    func getUser(req: Request) async throws -> User.Public {
        guard let user = try await User.find(req.parameters.get("userID"), on: req.db) else {
            throw Abort(.notFound)
        }
        return user.toPublic()
    }
    
    func getAllUsersHandler(_ req: Request) async throws -> [User.Public] {
        let users = try await User.query(on: req.db).all()
        return users.map { $0.toPublic() }
    }
    
    func getUsersFriends(_ req: Request) async throws -> [User.Public] {
        // Safely unwrap the userID
        guard let userID = req.parameters.get("userID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing userID")
        }

        // Fetch user and eager-load friends
        guard let user = try await User.query(on: req.db)
            .with(\.$friends) // Eager-loading
            .filter(\.$id == userID)
            .first()
        else {
            throw Abort(.notFound)
        }
                
        return user.friends.map { $0.toPublic() }
    }
}

struct CreateUserRequest: Content {
    let email: String
    let password: String
}
