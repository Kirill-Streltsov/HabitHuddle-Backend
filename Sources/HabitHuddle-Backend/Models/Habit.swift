//
//  File.swift
//  HabitHuddle-Backend
//
//  Created by Kirill on 13.05.25.
//

import Fluent
import Vapor

enum HabitFrequency: String, Codable {
    case daily
    case weekly
    case monthly
}

final class Habit: Model, Content {
    static let schema = "habits"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "user_id")
    var user: User

    @Field(key: "name")
    var name: String

    @OptionalField(key: "description")
    var description: String?

    @Enum(key: "frequency")
    var frequency: HabitFrequency

    @Field(key: "reminder_time")
    var reminderTime: Time

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() {}

    init(id: UUID? = nil, userID: UUID, name: String, description: String?, frequency: HabitFrequency, reminderTime: Time) {
        self.id = id
        self.$user.id = userID
        self.name = name
        self.description = description
        self.frequency = frequency
        self.reminderTime = reminderTime
    }
}
