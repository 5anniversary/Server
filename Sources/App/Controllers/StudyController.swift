import Vapor
import Crypto
import Authentication

final class StudyController: RouteCollection {
    
    func boot(router: Router) throws {
        let group = router.grouped("study")
        
        group.post(StudyInfoContainer.self,
                   at: "updateInfo",
                   use: updateStudyHandler)
        
//        group.post(StudyInfoContainer.self,
//                   at:"getCategoryInfo",
//                   use: CategoryStudyListHandler)
//        group.post(StudyInfoContainer.self,
//                   at:"getStudyInfo",
//                   use: StudyListHandler)

//        group.get("getInfo", use: allStudyListHandler)
        
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
    
//    func CategoryStudyListHandler(_ req: Request, container: StudyInfoContainer) throws -> Future<Response> {
//        let bearToken = BearerAuthorization(token: container.token)
//        return AccessToken
//            .authenticate(using: bearToken, on: req)
//            .flatMap({ (existToken) in
//
//                guard existToken != nil else {
//                    return try ResponseJSON<Empty>(status: .token).encode(for: req)
//                }
//
//                return Study
//                    .query(on: req)
//                    .filter(\.category == container.category)
//                    .sort(\.id)
//                    .all()
//                    .flatMap({ (category) in
//                        let categorys = category.compactMap({ cate -> Study in
//                            return cate
//                        })
//                        return try ResponseJSON<[Study]>(data: categorys).encode(for: req)
//                    })
//            })
//    }
//
//    func StudyListHandler(_ req: Request, container: StudyInfoContainer) throws -> Future<Response> {
//        let bearToken = BearerAuthorization(token: container.token)
//        return AccessToken
//            .authenticate(using: bearToken, on: req)
//            .flatMap({ (existToken) in
//
//                guard existToken != nil else {
//                    return try ResponseJSON<Empty>(status: .token).encode(for: req)
//                }
//
//                return Study
//                    .query(on: req)
//                    .filter(\.id == container.id)
//                    .all()
//                    .flatMap({ (category) in
//                        let categorys = category.compactMap({ cate -> Study in
//                            return cate
//                        })
//                        return try ResponseJSON<[Study]>(data: categorys).encode(for: req)
//                    })
//            })
//    }

    
    func updateStudyHandler(_ req: Request, container: StudyInfoContainer) throws -> Future<Response> {
        let bearToken = BearerAuthorization(token: container.token)
        return AccessToken
            .authenticate(using: bearToken, on: req)
            .flatMap({ (existToken) in

                guard let existToken = existToken else {
                    return try ResponseJSON<Empty>(status: .token).encode(for: req)
                }

                let futureFirst = Study.query(on: req).filter(\.id == container.id).first()

                return futureFirst.flatMap({ (existInfo) in
                    let study: Study?
                    let studyUser: StudyUser?
                    let fine: Fine?
                    var existInfo = existInfo

                    if existInfo?.id == container.id {
                        study = existInfo?.update(with: container)

                    } else {
                        study = Study(id: nil,
                                      name: container.name ?? "",
                                      categroy: container.category ?? "",
                                      content: container.content ?? "",
                                      image: container.image ?? "",
                                      location: container.location ?? "",
                                      userLimit: container.userLimit ?? 0,
                                      isFine: container.isFine ?? false,
                                      isEnd: container.isEnd ?? false,
                                      chapter: container.chapter ?? [],
                                      chiefUser: container.chiefUser ?? [],
                                      studyUser: container.studyUser ?? [],
                                      wantUser: container.wantUser ?? [],
                                      fine: container.fine ?? Fine.init(id: nil,
                                                                        studyID: 0,
                                                                        attendance: 0,
                                                                        tardy: 0,
                                                                        assignment: 0))
                        

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
    var location: String?
    var content: String?
    var userLimit: Int?
    var isFine: Bool?
    var isEnd: Bool?
    var chiefUser : [StudyUser]?
    var studyUser: [StudyUser]?
    var wantUser: [StudyUser]?
    var category: String?
    var chapter: [Chapter]?
    var fine: Fine?
    
}
