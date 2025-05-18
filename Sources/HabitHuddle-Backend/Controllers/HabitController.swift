//
//  HabitController.swift
//  HabitHuddle-Backend
//
//  Created by Kirill on 16.05.25.
//

import Fluent
import Vapor

struct HabitController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let tokenProtected = routes.grouped(UserToken.authenticator())
        let habits = tokenProtected.grouped("habits")

        habits.post("create", use: createHabit)
        habits.get(use: getMyHabits)
        habits.put(":habitID", use: updateHabit)
        habits.delete("delete", ":habitID", use: deleteHabit)

        routes.get("habits", ":userID", use: getUserHabits)
    }

    func createHabit(req: Request) async throws -> Habit {
        let user = try req.auth.require(User.self)
        let data = try req.content.decode(HabitData.self)

        guard let userID = user.id else {
            throw Abort(.noContent)
        }

        guard let habitName = data.name else {
            throw Abort(.badRequest, reason: "No habit name included")
        }

        let habit = Habit(userID: userID, name: habitName, description: data.description, frequency: .daily, reminderTime: Date())
        try await habit.save(on: req.db)
        return habit
    }

    func getUserHabits(req: Request) async throws -> [Habit] {
        // Safely unwrap the userID
        guard let userID = req.parameters.get("userID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing userID")
        }

        // Fetch user and eager-load habits
        guard let user = try await User.query(on: req.db)
            .with(\.$habits) // Eager-loading
            .filter(\.$id == userID)
            .first()
        else {
            throw Abort(.notFound)
        }

        return user.habits
    }

    func getMyHabits(req: Request) async throws -> [Habit] {
        // 1. Get the authenticated user from the token
        let user = try req.auth.require(User.self)

        // 2. Eager-load their habits (since habits is a children relation)
        try await user.$habits.load(on: req.db)

        return user.habits
    }

    func updateHabit(_ req: Request) async throws -> Habit {
        let user = try req.auth.require(User.self)
        guard let habitID = req.parameters.get("habitID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Missing habit ID")
        }

        guard let habit = try await Habit.find(habitID, on: req.db), habit.$user.id == user.id else {
            throw Abort(.notFound, reason: "Habit not found or not owned by user")
        }

        let updateData = try req.content.decode(HabitData.self)

        if let name = updateData.name {
            habit.name = name
        }
        if let description = updateData.description {
            habit.description = description
        }
        if let frequency = updateData.frequency {
            habit.frequency = frequency
        }
        if let reminderTime = updateData.reminderTime {
            habit.reminderTime = reminderTime
        }

        try await habit.save(on: req.db)
        return habit
    }

    func deleteHabit(req: Request) async throws -> Habit {
        guard let habitID = req.parameters.get("habitID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing habitID")
        }

        guard let habit = try await Habit.find(habitID, on: req.db) else {
            throw Abort(.notFound, reason: "Could not found habit with habitID: \(habitID)")
        }
        try await habit.delete(on: req.db)
        return habit
    }
}
