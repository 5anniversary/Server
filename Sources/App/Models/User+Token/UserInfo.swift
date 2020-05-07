import FluentMySQL

struct UserInfo : BaseSQLModel {
    var id: Int?
    
    static var entity: String { return self.name + "s" }
    
    var userID: String
    
    var age: Int?
    var sex: Int?
    var nickName: String?
    var location: String?
    var picLink: String?
    var userCategory: [String]?
    
    typealias Database = MySQLDatabase
}

extension UserInfo {
    
    mutating func update(with container: UserInfoContainer) -> UserInfo {
        
        if let new = container.age {
            self.age = new
        }
        if let new = container.sex {
            self.sex = new
        }
        if let new = container.nickName {
            self.nickName = new
        }
        if let new = container.location {
            self.location = new
        }
        if let new = container.picImage {
            self.picLink = new
        }
        if let new = container.category {
            self.userCategory = new
        }
        
        return self
    }
    
}
