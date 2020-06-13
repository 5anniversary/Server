import FluentMySQL

struct UserInfo : BaseSQLModel {
    var id: Int?
    
    static var entity: String { return self.name + "s" }
    
    var userID: String
    
    var age: Int?
    var sex: Int?
    var nickName: String?
    var location: String?
    var image: String?
    var content: String?
    var userCategory: [String]?
    var like: [LikeStudy]?

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
        if let new = container.image {
            self.image = new
        }
        if let new = container.category {
            self.userCategory = new
        }
        if let new = container.content {
            self.content = new
        }

        
        return self
    }
    
    mutating func addLikeStudy(with container: UserInfoContainer) -> UserInfo {
        
        if let new = container.like {
            self.like?.append(contentsOf: new)
        }
        
        return self
    }
    
    mutating func removeLikeStudy(with container: UserInfoContainer) -> UserInfo {
        
        if let new = container.likeIndex {
            self.like?.remove(at: new)
        }
        
        return self
    }

    
}
