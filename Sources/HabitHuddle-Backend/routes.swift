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
    tokenProtected.put("users", "me", use: userController.updateUser)
    
    // MARK: - Friend Routes
    users.get(":userID", "friends", use: userController.getUsersFriends)
    tokenProtected.get("users", "friends", use: userController.getMyFriends)
    tokenProtected.delete("friends", ":friendID", use: friendController.removeFriend)
    
    let friends = tokenProtected.grouped("friends")
    friends.post("add", use: friendController.addFriend)
    
    // MARK: - Habit Routes
    let habits = tokenProtected.grouped("habits")
    habits.post("create", use: habitController.createHabit)
    habits.get(use: habitController.getMyHabits)
    habits.put(":habitID", use: habitController.updateHabit)
    habits.delete("delete", ":habitID", use: habitController.deleteHabit)
    
    api.get("habits", ":userID", use: habitController.getUserHabits)
}
