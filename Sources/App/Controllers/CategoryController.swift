import Vapor

import Crypto
import Authentication

final class CategoryController: RouteCollection {
    
    func boot(router: Router) throws {
        let group = router.grouped("category")
        
        router.get("getCategory", use: categoryListHandler)
                
        group.post(CategoryContainer.self,
                   at: "add",
                   use:  add)

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
    
    
    func add(_ req: Request, container: CategoryContainer ) throws -> Future<Response> {
        var category: Category?
        
        category = Category(id: nil,
                            name: container.name,
                            startColor: container.startColor,
                            endColor: container.endColor
        )
        
        return (category?.save(on: req).flatMap({ _ in
            return try ResponseJSON<Empty>(status: .ok, message: "삽입 성공").encode(for: req)
        }))!
    }
}

struct CategoryContainer: Content {
    var name: String
    var startColor: String
    var endColor: String
}
