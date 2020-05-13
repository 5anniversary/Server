import Vapor
import FluentMySQL

struct Fine: BaseSQLModel {
    var id: Int?
    var studyID: Int
    var attendance: Int
    var tardy: Int
    var assignment: Int
    
}

extension Fine {
    typealias Database = MySQLDatabase

}
