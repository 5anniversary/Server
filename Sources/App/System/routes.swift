import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "It works" example
    router.get { req in
        return "study together 서버입니다."
    }
    
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }

    router.get("version") { (req) in
        return req.description
    }
    
    router.get("raw") { req -> Future<[Study]> in
        guard let name = req.query[String.self, at: "name"] else {
            throw Abort(.badRequest, reason: "Missing search term in request")
        }
        return req.withPooledConnection(to: .mysql) { conn -> Future<[Study]> in
            conn.raw("Select * from Study where name like '%" + name + "%'" ).all(decoding: Study.self)
        }
    }

    router.get("study/search") { req -> Future<[Study]> in
        guard let name = req.query[String.self, at: "name"] else {
            throw Abort(.badRequest, reason: "Missing search term in request")
        }
        return req.withPooledConnection(to: .mysql) { conn -> Future<[Study]> in
            conn.raw("Select * from Study where name like '%" + name + "%'" ).all(decoding: Study.self)
        }
    }
    
    router.get("study/searching") { req -> Future<Response> in
        guard let name = req.query[String.self, at: "name"] else {
            throw Abort(.badRequest, reason: "Missing search term in request")
        }
        let result = req.withPooledConnection(to: .mysql) { conn -> Future<[Study]> in
            conn.raw("Select * from Study where name like '%" + name + "%'" ).all(decoding: Study.self)
        }
        
        return result.flatMap({ (result) in
                return try ResponseJSON<[Study]>(data: result).encode(for: req)
        })
    }

    // Example of configuring a controller
    try router.register(collection: UserController())
    try router.register(collection: EmailController())
    try router.register(collection: CategoryController())
    try router.register(collection: StudyController())
    try router.register(collection: AuthenRouteController())
    try router.register(collection: ChapterController())
}
