import Vapor
import FluentMySQL

struct StudyUser: BaseSQLModel {
    var id: Int?
    var name: String
    var uid: String
    var image: String

}

extension StudyUser {
    typealias Database = MySQLDatabase
    
    mutating func update(with container: String)  {
        
    }
}
