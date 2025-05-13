//
//  CreateHabit.swift
//  HabitHuddle-Backend
//
//  Created by Kirill on 13.05.25.
//

import Fluent

struct CreateHabit: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("habits")
            .id()
            .field("user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("name", .string, .required)
            .field("description", .string)
            .field("frequency", .string, .required)
            .field("reminder_time", .time, .required)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("habits").delete()
    }
}
