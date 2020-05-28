import Vapor
import FluentMySQL

struct LikeStudy: BaseSQLModel {
    var id: Int?
    
    var studyID: Int?
    var studyName: String?
    var studyCategory: String?
    
}

extension LikeStudy {
    typealias Database = MySQLDatabase
    
}
