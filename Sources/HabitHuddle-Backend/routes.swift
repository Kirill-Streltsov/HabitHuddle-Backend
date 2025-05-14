import Fluent
import Vapor

func routes(_ app: Application) throws {
    let userController = UserController()
    let friendController = FriendController()
    
        
    let api = app.grouped("api")
    
    // Getting the currently authenticated User with the token
    let tokenProtected = api.grouped(UserToken.authenticator())
    tokenProtected.get("me") { req -> User in
        try req.auth.require(User.self)
    }
    
    tokenProtected.delete("logout") { req async throws -> HTTPStatus in
        let token = try req.auth.require(UserToken.self)
        try await token.delete(on: req.db)
        return .ok
    }
    
    let users = api.grouped("users")
    users.post("register", use: userController.register)
    
    let usersPasswordProtected = api.grouped(User.authenticator()) // Getting the token after logging in
    usersPasswordProtected.post("login", use: userController.login)
    
    
    users.get(":userID", use: userController.getUser)
    users.get(use: userController.getAllUsersHandler)
    
    // Getting friends from userID
    users.get(":userID", "friends", use: userController.getUsersFriends)
    
    // Getting friends with token
    tokenProtected.get("users", "me", "friends", use: userController.getMyFriends)
    
    let friends = api.grouped("friends")
    friends.post("add", use: friendController.addFriend)
}
