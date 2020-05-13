import Vapor
import Crypto
import Authentication

final class StudyController: RouteCollection {
    
    func boot(router: Router) throws {
        let group = router.grouped("study")
        
        group.post(StudyInfoContainer.self,
                   at: "updateInfo",
                   use: updateStudyHandler)
        
        group.post(StudyInfoContainer.self,
                   at:"getCategoryInfo",
                   use: CategoryStudyListHandler)
        group.post(StudyInfoContainer.self,
                   at:"getStudyInfo",
                   use: StudyListHandler)

        group.get("getInfo", use: allStudyListHandler)
        
    }
    
}

extension StudyController {
    
    func allStudyListHandler(_ req: Request) throws -> Future<Response> {
        return Study
            .query(on: req)
            .all()
            .flatMap({ (category) in
                let categorys = category.compactMap({ cate -> Study in
                    return cate
                })
                return try ResponseJSON<[Study]>(data: categorys).encode(for: req)
            })
    }
    
    func CategoryStudyListHandler(_ req: Request, container: StudyInfoContainer) throws -> Future<Response> {
        let bearToken = BearerAuthorization(token: container.token)
        return AccessToken
            .authenticate(using: bearToken, on: req)
            .flatMap({ (existToken) in
                
                guard existToken != nil else {
                    return try ResponseJSON<Empty>(status: .token).encode(for: req)
                }
                
                return Study
                    .query(on: req)
                    .filter(\.category == container.category)
                    .sort(\.id)
                    .all()
                    .flatMap({ (category) in
                        let categorys = category.compactMap({ cate -> Study in
                            return cate
                        })
                        return try ResponseJSON<[Study]>(data: categorys).encode(for: req)
                    })
            })
    }
    
    func StudyListHandler(_ req: Request, container: StudyInfoContainer) throws -> Future<Response> {
        let bearToken = BearerAuthorization(token: container.token)
        return AccessToken
            .authenticate(using: bearToken, on: req)
            .flatMap({ (existToken) in
                
                guard existToken != nil else {
                    return try ResponseJSON<Empty>(status: .token).encode(for: req)
                }
                
                return Study
                    .query(on: req)
                    .filter(\.id == container.id)
                    .all()
                    .flatMap({ (category) in
                        let categorys = category.compactMap({ cate -> Study in
                            return cate
                        })
                        return try ResponseJSON<[Study]>(data: categorys).encode(for: req)
                    })
            })
    }

    
    func updateStudyHandler(_ req: Request, container: StudyInfoContainer) throws -> Future<Response> {
        let bearToken = BearerAuthorization(token: container.token)
        return AccessToken
            .authenticate(using: bearToken, on: req)
            .flatMap({ (existToken) in
                
                guard let existToken = existToken else {
                    return try ResponseJSON<Empty>(status: .token).encode(for: req)
                }
                
                let futureFirst = Study.query(on: req).filter(\.userID == existToken.userID).filter(\.id == container.id).first()
                
                return futureFirst.flatMap({ (existInfo) in
                    let study: Study?
                    var existInfo = existInfo
                    
                    if existInfo?.id == container.id {
                        study = existInfo?.update(with: container)

                    } else {
                        study = Study(id: nil,
                                      userID: existToken.userID,
                                      name: container.name,
                                      image: container.image,
                                      attendanceFine: container.attendanceFine,
                                      tardyFine: container.tardyFine,
                                      assignmentFine : container.assignmentFine,
                                      location: container.location,
                                      content: container.content,
                                      category: container.category
                        )
                        
                        
                    }
                    
                    return (study!.save(on: req).flatMap({ (info) in
                        return try ResponseJSON<Empty>(status: .ok,
                                                       message: "요청 성공").encode(for: req)
                    }))
                })
            })
        
    }
}

struct StudyInfoContainer: Content {
    var token:String
    
    var id: Int?
    var name: String?
    var image: String?
    var attendanceFine: Int?
    var tardyFine: Int?
    var assignmentFine: Int?
    var location: String?
    var content: String?
    var chiefUserID : StudyUser?
    var category: String?
    var users: StudyUser?
    var chapter: Chapter?
    
}
