import Foundation
import Vapor
import FluentMySQL
import Authentication

public typealias BaseSQLModel = MySQLModel & Migration & Content & Parameter

protocol SuperModel: BaseSQLModel {

    static var entity: String { get }

    static var createdAtKey: TimestampKey? { get }
    static var updatedAtKey: TimestampKey? { get }
    static var deletedAtKey: TimestampKey? { get }
    
    var createdAt: Date? { get set }
    var updatedAt: Date? { get set }
    var deletedAt: Date? { get set }
}

extension SuperModel {
    
    var deletedAt: Date? { return nil }
    
    static var entity: String { return self.name + "s" }

    static var createdAtKey: TimestampKey? { return \Self.createdAt }
    static var updatedAtKey: TimestampKey? { return \Self.updatedAt }
    static var deletedAtKey: TimestampKey? { return \Self.deletedAt }
}

struct MyModel: SuperModel {
    
    var id: Int?
    var updatedAt: Date?
    var createdAt: Date?
    var deletedAt: Date?
    
    var name: String?
    var count: Int = 0
    
    init(name: String?,count: Int) {
        self.name = name
        self.count = count
    }
    
}
