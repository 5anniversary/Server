import Authentication
import FluentMySQL

struct User: BaseSQLModel {
    var id: Int?
    
    var userID: String?
    
    static var entity: String { return self.name + "s" }
    
    private(set) var email: String
    var password: String
 
    init(userID: String,email: String,password: String) {
        self.userID = userID
        self.email = email
        self.password = password
    }
   
    static var createdAtKey: TimestampKey? = \User.createdAt
    static var updatedAtKey: TimestampKey? = \User.updatedAt
    var createdAt: Date?
    var updatedAt: Date?
    
    typealias Database = MySQLDatabase
}

extension User: BasicAuthenticatable {
    static var usernameKey: WritableKeyPath<User, String> = \.email
    static var passwordKey: WritableKeyPath<User, String> = \.password
}
