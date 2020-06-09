import Vapor
import FluentMySQL

struct StudyUser: BaseSQLModel {
    var id: Int?
    var studyID: Int?
    var name: String
    var userID: String
    var image: String
    var attendance: Int?
    var tardy: Int?
    var assignment: Int?

}

extension StudyUser {
    typealias Database = MySQLDatabase
    
    mutating func tardyPlus(with container: CheckInfoContainer) -> StudyUser  {
        self.tardy! += 1
        return self
    }
    
    mutating func attendancePlus(with container: CheckInfoContainer) -> StudyUser  {
        self.attendance! += 1
        return self
    }
    
    mutating func assignmentPlus(with container: CheckInfoContainer) -> StudyUser  {
        self.assignment! += 1
        return self
    }
    
    mutating func tardyMinus(with container: CheckInfoContainer) -> StudyUser  {
        self.tardy! -= 1
        return self
    }
    
    mutating func attendanceMinus(with container: CheckInfoContainer) -> StudyUser  {
        self.attendance! -= 1
        return self
    }
    
    mutating func assignmentMinus(with container: CheckInfoContainer) -> StudyUser  {
        self.assignment! -= 1
        return self
    }
}
