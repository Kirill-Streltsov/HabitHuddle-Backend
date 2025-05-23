//
//  CreateUserToken.swift
//  HabitHuddle-Backend
//
//  Created by Kirill on 14.05.25.
//

import Fluent

struct CreateUserToken: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("user_tokens")
            .id()
            .field("value", .string, .required)
            .field("user_id", .uuid, .required, .references("users", "id"))
            .unique(on: "value")
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("user_tokens").delete()
    }
}
