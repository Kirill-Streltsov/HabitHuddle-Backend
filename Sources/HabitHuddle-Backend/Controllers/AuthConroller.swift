//
//  AuthConroller.swift
//  HabitHuddle-Backend
//
//  Created by Kirill on 17.05.25.
//

import Vapor

struct AuthController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let auth = routes.grouped("auth")

        // Public
        auth.post("register", use: register)
        auth.grouped(User.authenticator()).post("login", use: login)

        // Token-protected
        let tokenProtected = auth.grouped(UserToken.authenticator())
        tokenProtected.get("me", use: getMe)
        tokenProtected.delete("logout", use: logout)
    }

    // MARK: - Register

    func register(req: Request) async throws -> AuthResponse {
        let data = try req.content.decode(UserData.self)
        guard let username = data.username, let password = data.password, let name = data.name else {
            throw Abort(.badRequest, reason: "No username or data included")
        }
        let hash = try Bcrypt.hash(password)

        let user = User(username: username, name: name, passwordHash: hash)
        try await user.save(on: req.db)
        
        let token = try user.generateToken()
        try await token.save(on: req.db)

        return AuthResponse(token: token.value, user: user.toPublic())
    }

    // MARK: - Login

    func login(req: Request) async throws -> AuthResponse {
        let user = try req.auth.require(User.self)
        let token = try user.generateToken()
        try await token.save(on: req.db)

        return AuthResponse(token: token.value, user: user.toPublic())
    }

    // MARK: - Get Authenticated User

    func getMe(req: Request) throws -> User.Public {
        let user = try req.auth.require(User.self)
        return user.toPublic()
    }

    // MARK: - Logout

    func logout(req: Request) async throws -> HTTPStatus {
        let token = try req.auth.require(UserToken.self)
        try await token.delete(on: req.db)
        return .ok
    }
}

struct TokenResponse: Content {
    let token: String
}

struct AuthResponse: Content, Codable {
    let token: String
    let user: User.Public
}
