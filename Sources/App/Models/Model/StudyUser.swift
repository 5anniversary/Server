import Vapor
import FluentMySQL

struct StudyUser: BaseSQLModel {
    var id: Int?
    var name: String
    var userID: String
    var image: String

}

extension StudyUser {
    typealias Database = MySQLDatabase
    
    mutating func update(with container: StudyInfoContainer) -> StudyUser  {
        
        
        
        return self
    }
}
