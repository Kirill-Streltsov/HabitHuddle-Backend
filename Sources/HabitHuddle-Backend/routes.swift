import Fluent
import Vapor

func routes(_ app: Application) throws {
    let userController = UserController()
    let friendController = FriendController()
    
        
    let api = app.grouped("api")
    
    // Logging in and getting the token
    let passwordProtected = api.grouped(User.authenticator())
    passwordProtected.post("login") { req async throws -> UserToken in
        let user = try req.auth.require(User.self)
        let token = try user.generateToken()
        try await token.save(on: req.db)
        return token
    }
    
    // Getting the currently authenticated User with the token
    let tokenProtected = api.grouped(UserToken.authenticator())
    tokenProtected.get("me") { req -> User in
        try req.auth.require(User.self)
    }
    
    let users = api.grouped("users")
    users.post("register", use: userController.register)
    users.get(":userID", use: userController.getUser)
    users.get(use: userController.getAllUsersHandler)
    users.get(":userID", "friends", use: userController.getUsersFriends)
    
    let friends = api.grouped("friends")
    friends.post("add", use: friendController.addFriend)
}
