import Fluent
import Vapor

func routes(_ app: Application) throws {
    let api = app.grouped("api")

    try api.register(collection: UserController())
    try api.register(collection: FriendController())
    try api.register(collection: HabitController())
    try api.register(collection: ChallengeController())
    try api.register(collection: AuthController())
}
