import Vapor
import FluentMySQL
import Pagination

struct Study: BaseSQLModel {
    var id: Int?
    var name: String?
    var category: String?
    var content: String?
    var image: String?
    var location: String?
    var userLimit: Int?
    var isFine: Bool?
    var isEnd: Bool?
    var chapter: [Chapter]?
    var chiefUser: StudyUser?
    var studyUser: [StudyUser]?
    var wantUser: [StudyUser]?
    
    static var createdAtKey: TimestampKey? = \Study.createdAt
    
    var createdAt: Date?
    var fine: Fine?
}

extension Study {
    typealias Database = MySQLDatabase

    mutating func update(with container: StudyInfoContainer) -> Study {
        if let new = container.name {
            self.name = new
        }
        if let new = container.category {
            self.category = new
        }
        if let new = container.content {
            self.content = new
        }
        if let new = container.location {
            self.location = new
        }
        if let new = container.userLimit {
            self.userLimit = new
        }
        if let new = container.isFine {
            self.isFine = new
        }
        if let new = container.isEnd {
            self.isEnd = new
        }
        if let new = container.chapter {
            self.chapter?.append(contentsOf: new)
        }
        if let new = container.chiefUser {
            self.chiefUser = new
        }
        if let new = container.studyUser {
            self.studyUser?.append(contentsOf: new)
        }
        if let new = container.wantUser {
            self.wantUser?.append(contentsOf: new)
        }
        if let new = container.fine {
            self.fine = new
        }

        return self
    }
    
    mutating func updateChief(with container: StudyInfoContainer) -> Study {
        if let new = container.chiefUser {
            self.chiefUser = new
        }

        return self
    }
    
    mutating func updateWantUser(with container: StudyInfoContainer) -> Study {
        if let new = container.wantUser {
            self.wantUser?.append(contentsOf: new)
        }

        return self
    }

    mutating func moveWantToStudy(with container: StudyInfoContainer) -> Study {
        if let new = container.deleteUserIndex {
            self.wantUser?.remove(at: new)
        }
        if let new = container.studyUser {
            self.studyUser?.append(contentsOf: new)
        }

        return self
    }

    mutating func deleteWantUser(with container: StudyInfoContainer) -> Study {
        if let new = container.deleteUserIndex {
            self.wantUser?.remove(at: new)
        }

        return self
    }

    mutating func deleteStudyUser(with container: StudyInfoContainer) -> Study {
        if let new = container.deleteUserIndex {
            self.studyUser?.remove(at: new)
        }

        return self
    }

}

extension Study: Paginatable { }
