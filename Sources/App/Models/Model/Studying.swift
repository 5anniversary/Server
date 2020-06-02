import Vapor
import FluentMySQL

struct Studying: BaseSQLModel {
    var id: Int?
    var name: String?
    var studyID: Int?
    var userID: String?
    var category: String?
    var isEnd: Int?
    var userLimit: Int?
    var image: String?
    var content: String?
    var location: String?
    var isFine: Bool?

    
    typealias Database = MySQLDatabase
}
