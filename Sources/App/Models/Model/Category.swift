import Vapor
import FluentMySQL

struct Category: BaseSQLModel {
    var id: Int?
    var name: String
    var startColor: String?
    var endColor: String?
    
}

extension Category {
    typealias Database = MySQLDatabase
}
