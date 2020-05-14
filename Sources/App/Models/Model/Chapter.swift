import Vapor
import FluentMySQL
 
struct Chapter: BaseSQLModel {
    var id: Int?
    var studyID: Int
    var number: Int
    var content: String
    var date: Date
    var place: String
    var attendance: Int
    var isAssignment: Bool

}

extension Chapter {
    typealias Database = MySQLDatabase
    
    
}
