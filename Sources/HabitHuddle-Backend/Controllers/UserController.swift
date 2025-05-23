//
//  UserController.swift
//  HabitHuddle-Backend
//
//  Created by Kirill on 12.05.25.
//

import Fluent
import Vapor

struct UserController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let users = routes.grouped("users")
        users.get(":userID", use: getUser)
        users.get(use: getAllUsersHandler)

        let tokenProtected = routes.grouped(UserToken.authenticator())
        tokenProtected.put("users", "me", use: updateUser)

        // Friend subroutes
        users.get(":userID", "friends", use: getUsersFriends)
        tokenProtected.get("users", "friends", use: getMyFriends)
    }

    func register(req: Request) async throws -> User.Public {
        let data = try req.content.decode(UserData.self)
        guard let username = data.username, let password = data.password, let name = data.name else {
            throw Abort(.badRequest, reason: "No username or data included")
        }

        // Ensure username doesn't already exist
        if try await User.query(on: req.db).filter(\.$username == username).first() != nil {
            throw Abort(.conflict, reason: "Username already registered.")
        }

        // Hash the password
        let hash = try await req.password.async.hash(password)

        let user = User(username: username, name: name, passwordHash: hash)
        try await user.save(on: req.db)

        return user.toPublic()
    }

    func login(req: Request) async throws -> UserToken {
        let user = try req.auth.require(User.self)
        let token = try user.generateToken()
        try await token.save(on: req.db)
        return token
    }

    func getUser(req: Request) async throws -> User {
        guard let user = try await User.find(req.parameters.get("userID"), on: req.db) else {
            throw Abort(.notFound)
        }
        return user
    }

    // MARK: - Change or remove it after development

    func getAllUsersHandler(_ req: Request) async throws -> [User] {
        let users = try await User.query(on: req.db)
            .with(\.$habits)
            .with(\.$friends)
            .all()
        return users
    }

    func getUsersFriends(_ req: Request) async throws -> [User] {
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

        return user.friends
    }

    func getMyFriends(_ req: Request) async throws -> [User] {
        // 1. Get the authenticated user from the token
        let user = try req.auth.require(User.self)

        // 2. Eager-load their friends (since friends is a siblings relation)
        try await user.$friends.load(on: req.db)

        // 3. Convert to public representation
        return user.friends
    }

    func updateUser(_ req: Request) async throws -> User {
        let user = try req.auth.require(User.self)
        let updateData = try req.content.decode(UserData.self)

        if let username = updateData.username {
            // Ensure username doesn't already exist
            if try await User.query(on: req.db).filter(\.$username == username).first() != nil {
                throw Abort(.conflict, reason: "Username already in use")
            }
            user.username = username
        }
        if let password = updateData.password {
            user.passwordHash = try Bcrypt.hash(password)
        }

        try await user.save(on: req.db)
        return user
    }
}

struct UserData: Content {
    var username: String?
    var name: String?
    var password: String?
}
