import Vapor
import FluentMySQL

struct StudyReport: BaseSQLModel {
    var id: Int?

    var contentID: Int?
    var content: String?
    var reportContent: [String]?
    var reportUserID: [String]?
    var count: Int?
    
    typealias Database = MySQLDatabase
}

extension StudyReport {
    
    mutating func studyReport(with container: ReportInfoContainer) -> StudyReport  {
        
        self.count! += 1
  
        
        if let new = container.reportContent {
            self.reportContent?.append(contentsOf: new)
        }
        
        if let new = container.reportUserID {
            self.reportUserID?.append(contentsOf: new)
        }

        return self
    }

    
}
