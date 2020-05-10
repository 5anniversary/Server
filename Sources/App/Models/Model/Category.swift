import Vapor
import FluentMySQL

struct Category: BaseSQLModel {
    var id: Int?
    var name: String
    
    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}

extension Category {
    typealias Database = MySQLDatabase
}
