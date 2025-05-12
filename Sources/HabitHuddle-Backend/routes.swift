import Fluent
import Vapor

func routes(_ app: Application) throws {
    let userController = UserController()
    let friendController = FriendController()
    
    let api = app.grouped("api")
    
    let users = api.grouped("users")
    users.post("register", use: userController.register)
    users.get(":userID", use: userController.getUser)
    users.get(use: userController.getAllUsersHandler)
    
    let friends = api.grouped("friends")
    friends.post("add", use: friendController.addFriend)
}
