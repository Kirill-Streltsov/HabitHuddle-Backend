//
//  User.swift
//  HabitHuddle-Backend
//
//  Created by Kirill on 12.05.25.
//

import Vapor
import Fluent

final class User: Model, Content, @unchecked Sendable {
    static let schema = "users"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "email")
    var email: String
    
    @Field(key: "password_hash")
    var passwordHash: String
    
//    @Children(for: \.$user)
//    var habits: [Habit]
    
    @Siblings(through: UserFriend.self, from: \.$user, to: \.$friend)
    var friends: [User]
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    init() {}
    
    init(id: UUID? = nil, email: String, passwordHash: String) {
        self.id = id
        self.email = email
        self.passwordHash = passwordHash
    }
}

extension User {
    struct Public: Content {
        var id: UUID?
        var email: String
    }

    func toPublic() -> Public {
        Public(id: self.id, email: self.email)
    }
}
