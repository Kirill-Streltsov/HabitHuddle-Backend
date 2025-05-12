//
//  CreateUserFriend.swift
//  HabitHuddle-Backend
//
//  Created by Kirill on 12.05.25.
//

import Fluent

struct CreateUserFriend: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("user+friend")
            .id()
            .field("user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("friend_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .unique(on: "user_id", "friend_id")
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("user+friend").delete()
    }
}
