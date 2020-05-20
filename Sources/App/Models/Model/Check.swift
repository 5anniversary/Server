import Vapor
import FluentMySQL

struct Check: BaseSQLModel {
    var id: Int?
    var studyID: Int
    var chapterID: Int
    var attendance: [IsCheck]?
    var tardy: [IsCheck]?
    var assignment: [IsCheck]?

    static var createdAtKey: TimestampKey? = \Check.createdAt
    
    var createdAt: Date?
}

extension Check {
    typealias Database = MySQLDatabase
}

struct IsCheck: BaseSQLModel {
    var id: Int?
    
    var name: String
    var isCheck: Int
}
