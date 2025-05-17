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
    
    @Children(for: \.$user)
    var habits: [Habit]
    
    @Children(for: \.$receiver)
    var receivedChallenges: [Challenge]
    
    @Children(for: \.$initiator)
    var sentChallenges: [Challenge]
    
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
        self.createdAt = Date()
        self.passwordHash = passwordHash
    }
}

extension User: ModelAuthenticatable {
    static var usernameKey: KeyPath<User, Field<String>> {
        \User.$email
    }
    
    static var passwordHashKey: KeyPath<User, Field<String>> {
        \User.$passwordHash
    }
    
    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.passwordHash)
    }
}


// Public representation of User
extension User {
    struct Public: Content {
        var id: UUID?
        var email: String
        var createdAt: Date?
    }

    func toPublic() -> Public {
        Public(id: self.id, email: self.email, createdAt: self.createdAt)
    }
}

// Generating Token for the user session
extension User {
    func generateToken() throws -> UserToken {
        try .init(
            value: [UInt8].random(count: 16).base64,
            userID: self.requireID()
        )
    }
}
