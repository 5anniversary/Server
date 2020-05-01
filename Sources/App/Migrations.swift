import Vapor
import FluentMySQL
import Fluent

extension MigrationConfig {
    
    mutating func setupModels() {

        add(model: User.self, database: .mysql)
        add(model: AccessToken.self, database: .mysql)
        add(model: RefreshToken.self, database: .mysql)
        add(model: UserInfo.self, database: .mysql)
    }
}
