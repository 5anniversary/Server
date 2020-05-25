import Vapor
import FluentMySQL

struct Studying: BaseSQLModel {
    var id: Int?
    var name: String?
    var studyID: Int?
    var userID: String?
    var category: String?
    var isEnd: Int?
    
    typealias Database = MySQLDatabase
}
