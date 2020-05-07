import Vapor
import FluentMySQL

struct EmailResult: BaseSQLModel {
    
    var id: Int?
    static var entity: String { return self.name + "s" }

    var state: Bool?
    var email: String?
    var sendTime: String?
    
}

extension EmailResult: Parameter {}
extension EmailResult {
    typealias Database = MySQLDatabase
}
