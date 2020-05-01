import Vapor
import FluentMySQL

/// Called after your application has initialized.
public func boot(_ app: Application) throws {
    // Your code here
}

func foo(on container: Container) {
    
    let future = container.withPooledConnection(to: .mysql) { db in
        return Future.map(on: container){ "\(db) timer running" }
    }
    future.do{ msg in
        print( msg )
        }.catch{ error in
            print("\(error.localizedDescription)")
    }
    
}
