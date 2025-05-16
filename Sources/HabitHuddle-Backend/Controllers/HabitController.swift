//
//  HabitController.swift
//  HabitHuddle-Backend
//
//  Created by Kirill on 16.05.25.
//

import Vapor
import Fluent

struct HabitController {
    func createHabit(req: Request) async throws -> Habit {
        let user = try req.auth.require(User.self)
        let data = try req.content.decode(HabitDTO.self)
                
        guard let userID = user.id else {
            throw Abort(.noContent)
        }
        
        let habit = Habit(userID: userID, name: data.name, description: data.description, frequency: .daily, reminderTime: Date())
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

struct HabitDTO: Content {
    let name: String
    let description: String
}
