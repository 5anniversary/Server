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
    
    mutating func update(with container: CheckInfoContainer) -> Check {
        if let new = container.assignment{
            self.assignment?.append(contentsOf: new)
        }
        if let new = container.tardy{
            self.tardy?.append(contentsOf: new)
        }
        if let new = container.attendance{
            self.attendance?.append(contentsOf: new)
        }

        
        return self
    }
}

struct IsCheck: BaseSQLModel {
    var id: Int?
    
    var name: String
    var isCheck: Int
}
