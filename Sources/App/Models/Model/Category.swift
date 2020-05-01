import Vapor
import FluentMySQL

final class Category: Codable {
    var id: Int?
    var name: String
    
    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}

extension Category: Content {}
extension Category: Migration {}
extension Category: Parameter {}
extension Category: MySQLModel {
    typealias Database = MySQLDatabase
}
