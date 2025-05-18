//
//  ChallengeController.swift
//  HabitHuddle-Backend
//
//  Created by Kirill on 17.05.25.
//

import Vapor

struct ChallengeController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let tokenProtected = routes.grouped(UserToken.authenticator())

        tokenProtected.post("challenges", "send", use: sendChallenge)
        tokenProtected.post("challenges", ":id", "accept", use: acceptChallenge)
        tokenProtected.post("challenges", ":id", "reject", use: rejectChallenge)
        tokenProtected.get("challenges", "me", use: getMyChallenges)
        tokenProtected.get("challenges", use: getAllChallenges)
    }

    // 1. Send a challenge
    func sendChallenge(_ req: Request) async throws -> Challenge {
        let user = try req.auth.require(User.self)
        let data = try req.content.decode(CreateChallengeRequest.self)

        let challenge = try Challenge(
            initiatorID: user.requireID(),
            receiverID: data.receiverID,
            habitID: data.habitID,
            type: data.type,
            startDate: Date(),
            endDate: Date()
        )

        try await challenge.save(on: req.db)
        return challenge
    }

    // 2. Accept a challenge
    func acceptChallenge(_ req: Request) async throws -> HTTPStatus {
        let user = try req.auth.require(User.self)
        guard let id = req.parameters.get("id", as: UUID.self),
              let challenge = try await Challenge.find(id, on: req.db),
              challenge.$receiver.id == user.id
        else {
            throw Abort(.notFound)
        }

        challenge.status = .accepted
        challenge.startDate = Date()
        challenge.endDate = Date()
        try await challenge.update(on: req.db)
        return .ok
    }

    // 3. Reject a challenge
    func rejectChallenge(_ req: Request) async throws -> HTTPStatus {
        let user = try req.auth.require(User.self)
        guard let id = req.parameters.get("id", as: UUID.self),
              let challenge = try await Challenge.find(id, on: req.db),
              challenge.$receiver.id == user.id
        else {
            throw Abort(.notFound)
        }

        challenge.status = .declined
        try await challenge.update(on: req.db)
        return .ok
    }

    // 4. View received challenges
    func getMyChallenges(_ req: Request) async throws -> [Challenge] {
        let user = try req.auth.require(User.self)
        guard let userID = user.id else {
            throw Abort(.notFound, reason: "Could not find authenticated user with id: \(String(describing: user.id))")
        }

        return try await Challenge.query(on: req.db)
            .group(.or) { or in
                or.filter(\Challenge.$receiver.$id, .equal, userID)
                or.filter(\Challenge.$initiator.$id, .equal, userID)
            }
            .with(\.$initiator)
            .with(\.$habit)
            .all()
    }

    // MARK: Delete or change logic - otherwise too wasteful

    // 5. Get all challenges
    func getAllChallenges(_ req: Request) async throws -> [Challenge] {
        return try await Challenge.query(on: req.db)
            .with(\.$initiator)
            .with(\.$receiver)
            .with(\.$habit)
            .all()
    }
}

struct CreateChallengeRequest: Content {
    let receiverID: UUID
    let habitID: UUID
    let type: ChallengeType
}
