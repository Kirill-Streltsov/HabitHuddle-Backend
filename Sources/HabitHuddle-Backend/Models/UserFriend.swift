//
//  UserFriend.swift
//  HabitHuddle-Backend
//
//  Created by Kirill on 12.05.25.
//

import Fluent

final class UserFriend: Model, @unchecked Sendable {
    static let schema = "user+friend"

    @ID()
    var id: UUID?

    @Parent(key: "user_id")
    var user: User

    @Parent(key: "friend_id")
    var friend: User

    init() {}

    init(userID: UUID, friendID: UUID) {
        $user.id = userID
        $friend.id = friendID
    }
}
