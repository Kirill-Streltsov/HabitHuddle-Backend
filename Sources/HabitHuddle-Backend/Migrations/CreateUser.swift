//
//  CreateUser.swift
//  HabitHuddle-Backend
//
//  Created by Kirill on 12.05.25.
//

import Fluent

struct CreateUser: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("users")
            .id()
            .field("email", .string, .required)
            .field("passwordHash", .string, .required)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .unique(on: "email") // ensure email is unique
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("users").delete()
    }
}
