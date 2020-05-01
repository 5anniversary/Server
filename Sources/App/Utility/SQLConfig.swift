import Foundation
import Vapor
import FluentMySQL

extension MySQLDatabaseConfig {
    
    static func loadSQLConfig(_ env: Environment) -> MySQLDatabaseConfig {
        
        let port: Int
        if let environmentPort = Environment.get("PORT") {
          port = Int(environmentPort) ?? 9090
        } else {
          port = 9090
        }
        let hostname = Environment.get("MYSQL_HOSTNAME") ?? "localhost"
        let username = Environment.get("MYSQL_USERNAME") ?? "user1"
        let password = Environment.get("MYSQL_PASSWORD") ?? "test123"
        let databaseName = Environment.get("MYSQL_DBNAME") ?? "mydb"

        
        return MySQLDatabaseConfig(hostname: hostname,
                                        port: port,
                                        username: username,
                                        password: password,
                                        database: databaseName)
    }
    
}
