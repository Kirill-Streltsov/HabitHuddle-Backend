//
//  Habit.swift
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

final class Habit: Model, Content, @unchecked Sendable {
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
    var reminderTime: Date?

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() {}

    init(id: UUID? = nil, userID: UUID, name: String, description: String?, frequency: HabitFrequency, reminderTime: Date?) {
        self.id = id
        $user.id = userID
        self.name = name
        self.description = description
        self.frequency = frequency
        self.reminderTime = reminderTime
    }
}

struct HabitData: Content {
    var name: String?
    var description: String?
    var frequency: HabitFrequency?
    var reminderTime: Date?
}
