import Vapor
import FluentMySQL

struct Category: BaseSQLModel {
    var id: Int?
    var name: String
    
}

extension Category {
    typealias Database = MySQLDatabase
}
