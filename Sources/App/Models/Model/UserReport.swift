import Vapor
import FluentMySQL

struct UserReport: BaseSQLModel {
    var id: Int?
    
    var userID: String?
    var content: [String]?
    var reportUserID: [String]?
    var count: Int?
    
    typealias Database = MySQLDatabase
}

extension UserReport {
    
    mutating func userReport(with container: ReportInfoContainer) -> UserReport  {
        
        self.count! += 1
        
        if let new = container.reportContent {
            self.content?.append(contentsOf: new)
        }
        
        if let new = container.reportUserID {
            self.reportUserID?.append(contentsOf: new)
        }

        return self
    }

}
