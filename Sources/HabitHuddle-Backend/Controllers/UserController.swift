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
        let data = try req.content.decode(UserData.self)
        guard let email = data.email, let password = data.password else {
            throw Abort(.badRequest, reason: "No email or data included")
        }
        
        // Ensure email doesn't already exist
        if try await User.query(on: req.db).filter(\.$email == email).first() != nil {
            throw Abort(.conflict, reason: "Email already registered.")
        }
        
        // Hash the password
        let hash = try await req.password.async.hash(password)
        
        let user = User(email: email, passwordHash: hash)
        try await user.save(on: req.db)
        
        return user.toPublic()
    }
    
    func login(req: Request) async throws -> UserToken {
        let user = try req.auth.require(User.self)
        let token = try user.generateToken()
        try await token.save(on: req.db)
        return token
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

    func getMyFriends(_ req: Request) async throws -> [User.Public] {
        // 1. Get the authenticated user from the token
        let user = try req.auth.require(User.self)

        // 2. Eager-load their friends (since friends is a siblings relation)
        try await user.$friends.load(on: req.db)

        // 3. Convert to public representation
        return user.friends.map { $0.toPublic() }
    }
    
    func updateUser(_ req: Request) async throws -> User.Public {
        let user = try req.auth.require(User.self)
        let updateData = try req.content.decode(UserData.self)
        

        if let email = updateData.email {
            // Ensure email doesn't already exist
            if try await User.query(on: req.db).filter(\.$email == email).first() != nil {
                throw Abort(.conflict, reason: "Email already in use")
            }
            user.email = email
        }
        if let password = updateData.password {
            user.passwordHash = try Bcrypt.hash(password)
        }

        try await user.save(on: req.db)
        return user.toPublic()
    }
}

struct UserData: Content {
    var email: String?
    var password: String?
}
