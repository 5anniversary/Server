import Vapor

import Crypto
import Authentication

final class CategoryController: RouteCollection {
    
    func boot(router: Router) throws {
        
        router.get("getCategory", use: categoryListHandler)
    }
    
}

extension CategoryController {
    
    func categoryListHandler(_ req: Request) throws -> Future<Response> {
     
        return Category
            .query(on: req)
            .all()
            .flatMap({ (category) in
            let categorys = category.compactMap({ cate -> Category in
                return cate
            })
            return try ResponseJSON<[Category]>(data: categorys).encode(for: req)
        })

    }
}
