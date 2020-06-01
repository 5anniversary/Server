import Vapor
import FluentMySQL
 
struct Chapter: BaseSQLModel {
    var id: Int?
    var title: String
    var studyID: Int
    var content: String
    var date: String
    var place: String
    
    static var createdAtKey: TimestampKey? = \Chapter.createdAt
    
    var createdAt: Date?

}

extension Chapter {
    typealias Database = MySQLDatabase
}
