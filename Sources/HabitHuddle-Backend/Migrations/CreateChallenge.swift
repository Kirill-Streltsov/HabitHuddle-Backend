//
//  CreateChallenge.swift
//  HabitHuddle-Backend
//
//  Created by Kirill on 17.05.25.
//

import Fluent

struct CreateChallenge: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("challenges")
            .id()
            .field("initiator_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("receiver_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("habit_id", .uuid, .required, .references("habits", "id", onDelete: .cascade))
            .field("type", .string, .required)
            .field("status", .string, .required)
            .field("start_date", .date, .required)
            .field("end_date", .date, .required)
            .field("created_at", .datetime)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("challenges").delete()
    }
}
