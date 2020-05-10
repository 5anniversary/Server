import Vapor
import FluentMySQL
 
struct Chapter: BaseSQLModel {
    var id: Int?
    var studyID: Int
    var number: Int
    var content: String
    var date: Date
    var place: String
    var attendance: Int
    var isAssignment: Bool
    
    init(id: Int,
         studyID: Int,
         number: Int,
         content: String,
         date: Date,
         place: String,
         attendance: Int,
         isAssignment: Bool){
        self.id = id
        self.studyID = studyID
        self.number = number
        self.content = content
        self.date = date
        self.place = place
        self.attendance = attendance
        self.isAssignment = isAssignment
    }

}

extension Chapter {
    typealias Database = MySQLDatabase
}
