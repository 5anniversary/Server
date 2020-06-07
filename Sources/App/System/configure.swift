import Vapor
import APIErrorMiddleware
import Authentication
import FluentMySQL

/// Called before your application initializes.
public func configure(_ config: inout Config,
                      _ env: inout Environment,
                      _ services: inout Services) throws {
    
    // Register providers first
    try services.register(FluentMySQLProvider())
    
    
    var commands = CommandConfig.default()
    commands.useFluentCommands()
    services.register(commands)
    
    services.register(DirectoryConfig.detect())
    try services.register(AuthenticationProvider())
    
    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /* * ** ** ** ** *** ** ** ** Middleware ** ** ** ** ** ** ** ** ** */
    var middlewares = MiddlewareConfig()
    
    middlewares.use(LocalHostMiddleware())
    
    middlewares.use(APIErrorMiddleware.init(environment: env, specializations: [
        ModelNotFound()
    ]))
    
    middlewares.use(ExceptionMiddleware(closure: { (req) -> (EventLoopFuture<Response>?) in
        let dict = ["status":"404", "message":"액세스 경로가 존재하지 않습니다"]
        return try dict.encode(for: req)
    }))
    middlewares.use(ErrorMiddleware.self)
    middlewares.use(FileMiddleware.self)
    
    middlewares.use(GuardianMiddleware(rate: Rate(limit: 10000,
                                                  interval: .minute),
                                       closure: { (req) -> EventLoopFuture<Response>? in
        let dict = ["status":"429","message":"요청이 너무 잦습니다"]
        return try dict.encode(for: req)
    }))
    
    services.register(middlewares)
    
    let port: Int
    if let environmentPort = Environment.get("PORT") {
        port = Int(environmentPort) ?? 9090
    } else {
        port = 9090
    }
    let nioServerConfig = NIOServerConfig.default(port: port)
    services.register(nioServerConfig)
    
    /* * ** ** ** ** *** ** ** ** SQL ** ** ** ** ** ** ** ** ** */

    var databases = DatabasesConfig()
    let hostname = Environment.get("MYSQL_HOSTNAME") ?? "localhost"
    let username = Environment.get("MYSQL_USERNAME") ?? "user1"
    let password = Environment.get("MYSQL_PASSWORD") ?? "test123"
    let databaseName = Environment.get("MYSQL_DBNAME") ?? "mydb"
    let databaseConfig = MySQLDatabaseConfig(
        hostname: hostname,
        port: 3306,
        username: username,
        password: password,
        database: databaseName)
    
    let database = MySQLDatabase(config: databaseConfig)
    databases.add(database: database, as: .mysql)
    services.register(databases)
    
    /* * ** ** ** ** *** ** ** ** 𝐌odels ** ** ** ** ** ** ** ** ** */

    var migrations = MigrationConfig()
    
    migrations.setupModels()
    
    services.register(migrations)
    
}
