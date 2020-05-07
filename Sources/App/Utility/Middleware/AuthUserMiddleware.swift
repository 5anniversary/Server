import Vapor

struct AuthUserMiddleware: Middleware {
    
    func respond(to request: Request, chainingTo next: Responder) throws -> EventLoopFuture<Response> {
        
        // ...
        
        return try next.respond(to: request)
    }
    
}


