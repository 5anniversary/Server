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
    
    mutating func update(with container: ChapterInfoContainer) -> Chapter {
        if let new = container.title {
            self.title = new
        }
        if let new = container.studyID {
            self.studyID = new
        }
        if let new = container.content {
            self.content = new
        }
        if let new = container.date {
            self.date = new
        }
        if let new = container.place {
            self.place = new
        }

        return self
    }

}
