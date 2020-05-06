import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "It works" example
    router.get { req in
        return "study together 서버 입니당."
    }
    
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }

    router.get("version") { (req) in
        return req.description
    }
    
    // Example of configuring a controller
    try router.register(collection: UserController())
    try router.register(collection: CategoryController())
    try router.register(collection: StudyController())
    try router.register(collection: AuthenRouteController())
}
