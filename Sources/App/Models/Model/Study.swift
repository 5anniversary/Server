import Vapor
import FluentMySQL

struct Study: BaseSQLModel {
    var id: Int?
    var userID: String?
    var name: String?
    var image: String?
    var attendanceFine: Int?
    var tardyFine: Int?
    var assignmentFine: Int?
    var location: String?
    var content: String?
    var chiefUserID : StudyUser?
    var category: String?
    var users: StudyUser?
    var chapter: Chapter?
}

extension Study {
    typealias Database = MySQLDatabase

    mutating func update(with container: StudyInfoContainer) -> Study {
        
        if let new = container.name {
            self.name = new
        }
        if let new = container.image {
            self.image = new
        }
        if let new = container.attendanceFine {
            self.attendanceFine = new
        }
        if let new = container.tardyFine {
            self.tardyFine = new
        }
        if let new = container.assignmentFine {
            self.assignmentFine = new
        }
        if let new = container.location {
            self.location = new
        }
        if let new = container.content {
            self.content = new
        }
        if let new = container.chiefUserID {
            self.chiefUserID = new
        }
        if let new = container.category {
            self.category = new
        }
        if let new = container.users {
            self.users = new
        }
        if let new  = container.chapter {
            self.chapter = new
        }
        
        return self
    }


}

