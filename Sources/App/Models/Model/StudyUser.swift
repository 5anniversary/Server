import Vapor
import FluentMySQL

struct StudyUser: BaseSQLModel {
    var id: Int?
    var name: String
    var uid: String
    var image: String
    
    init(id: Int,
         name: String,
         uid: String,
         image: String){
        self.id = id
        self.name = name
        self.uid = uid
        self.image = image
    }

}

extension StudyUser {
    typealias Database = MySQLDatabase
}
