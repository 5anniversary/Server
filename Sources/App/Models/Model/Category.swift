import Vapor
import FluentMySQL

final class Category: BaseSQLModel {
    var id: Int?
    var name: String
    
    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}

extension Category: Parameter {}
extension Category {
    typealias Database = MySQLDatabase
}
