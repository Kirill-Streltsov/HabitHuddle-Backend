//
//  Challenge.swift
//  HabitHuddle-Backend
//
//  Created by Kirill on 17.05.25.
//

import Fluent
import Vapor

enum ChallengeType: String, Codable {
    case competitive
    case supportive
}
enum ChallengeStatus: String, Codable {
    case pending
    case accepted
    case declined
}

final class Challenge: Model, Content, @unchecked Sendable {
    static let schema = "challenges"
    
    @ID(key: .id)
    var id: UUID?

    @Parent(key: "initiator_id")
    var initiator: User

    @Parent(key: "receiver_id")
    var receiver: User

    @Parent(key: "habit_id")
    var habit: Habit

    @Field(key: "type")
    var type: ChallengeType

    @Field(key: "status")
    var status: ChallengeStatus

//    @Field(key: "start_date")
//    var startDate: Date
//
//    @Field(key: "end_date")
//    var endDate: Date

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    init() {}

    init(
        id: UUID? = nil,
        initiatorID: UUID,
        receiverID: UUID,
        habitID: UUID,
        type: ChallengeType,
        status: ChallengeStatus = .pending
    ) {
        self.id = id
        self.$initiator.id = initiatorID
        self.$receiver.id = receiverID
        self.$habit.id = habitID
        self.type = type
        self.status = status
    }
}
