import Vapor

struct User: Content, Equatable {
    let id: String
    let name: String
}
