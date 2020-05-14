import Vapor
import FluentMySQL

struct Study: BaseSQLModel {
    var id: Int?
    var name: String
    var categroy: String
    var content: String
    var image: String
    var location: String
    var userLimit: Int?
    var isFine: Bool
    var isEnd: Bool
    var chapter: [Chapter]?
    var chiefUser: [StudyUser]?
    var studyUser: [StudyUser]?
    var wantUser: [StudyUser]?
    var fine: Fine?
}

extension Study {
    typealias Database = MySQLDatabase

    mutating func update(with container: StudyInfoContainer) -> Study {
        
        
        return self
    }


}


