import Fluent
import Vapor

func routes(_ app: Application) throws {
    let userController = UserController()
    let friendController = FriendController()
    let habitController = HabitController()
    
    let api = app.grouped("api")
    
    // MARK: - Auth Routes
    let auth = api.grouped("auth")
    auth.post("register", use: userController.register)
    auth.grouped(User.authenticator()).post("login", use: userController.login)
    
    
    let tokenProtected = api.grouped(UserToken.authenticator())
    
    tokenProtected.get("auth", "me") { req -> User in
        try req.auth.require(User.self)
    }
    
    tokenProtected.delete("auth", "logout") { req async throws -> HTTPStatus in
        let token = try req.auth.require(UserToken.self)
        try await token.delete(on: req.db)
        return .ok
    }
    
    // MARK: - User Routes
    let users = api.grouped("users")
    users.get(":userID", use: userController.getUser)
    users.get(use: userController.getAllUsersHandler)
    
    // MARK: - Friend Routes
    users.get(":userID", "friends", use: userController.getUsersFriends)
    tokenProtected.get("users", "me", "friends", use: userController.getMyFriends)
    
    let friends = tokenProtected.grouped("friends")
    friends.post("add", use: friendController.addFriend)
    
    // MARK: - Habit Routes
    let habits = tokenProtected.grouped("habits")
    habits.post("me", "create", use: habitController.createHabit)
    habits.get("me", use: habitController.getMyHabits)
    habits.delete("me", "delete", ":habitID", use: habitController.deleteHabit)
    
    api.get("habits", ":userID", use: habitController.getUserHabits)
}
