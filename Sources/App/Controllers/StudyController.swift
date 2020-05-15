import Vapor
import Crypto
import Authentication
import Pagination

final class StudyController: RouteCollection {
    
    func boot(router: Router) throws {
        let group = router.grouped("study")
        
        group.post(StudyInfoContainer.self,
                   at: "createStudy",
                   use: createStudyHandler)
        group.post(StudyInfoContainer.self,
                   at: "updateStudyChief",
                   use: updateStudyChiefHandler)
        
        group.post(StudyInfoContainer.self,
                   at:"getCategoryInfo",
                   use: CategoryStudyListHandler)
        group.post(StudyInfoContainer.self,
                   at:"getStudyInfo",
                   use: StudyListHandler)
        group.post(StudyInfoContainer.self,
                   at:"addwantuser",
                   use: updateStudyWantUserHandler)

        group.get("getInfo", use: allStudyListHandler)
        
    }
    
}

extension StudyController {
    
    // MARK: - 스터디 목록 전체 리스트 불러오기
    
    func allStudyListHandler(_ req: Request) throws -> Future<Response> {
        return Study
            .query(on: req)
            .all()
            .flatMap({ (studies) in
                let study = studies.compactMap({ stu -> Study in
                    return stu
                })
                return try ResponseJSON<[Study]>(data: study).encode(for: req)
            })
    }
    
    // MARK: - 한 카테고리 스터디 목록 불러오기
    
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
                    .filter(\.category == container.category ?? "")
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
    
    // MARK: - 스터디 하나 불러오기
    
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
    
    // MARK: - 스터디 만들기
    
    func createStudyHandler(_ req: Request, container: StudyInfoContainer) throws -> Future<Response> {
        let bearToken = BearerAuthorization(token: container.token)
        return AccessToken
            .authenticate(using: bearToken, on: req)
            .flatMap({ (existToken) in
                
                guard existToken != nil else {
                    return try ResponseJSON<Empty>(status: .token).encode(for: req)
                }
                
                let futureFirst = Study.query(on: req).filter(\.id == container.id).first()
                
                return futureFirst.flatMap({ _ in
                    let study: Study?
                    study = Study(id: nil,
                                  name: container.name ?? "",
                                  category: container.category ?? "",
                                  content: container.content ?? "",
                                  image: container.image ?? "",
                                  location: container.location ?? "",
                                  userLimit: container.userLimit ?? 0,
                                  isFine: container.isFine ?? false,
                                  isEnd: container.isEnd ?? false,
                                  chapter: container.chapter ?? [],
                                  chiefUser: container.chiefUser,
                                  studyUser: container.studyUser ?? [],
                                  wantUser: container.wantUser ?? [],
                                  fine: container.fine ?? Fine.init(id: nil,
                                                                    studyID: 0,
                                                                    attendance: 0,
                                                                    tardy: 0,
                                                                    assignment: 0)
                    )
                    
                    return (study!.save(on: req).flatMap({ (info) in
                        return try ResponseJSON<Empty>(status: .ok,
                                                       message: "요청 성공").encode(for: req)
                    }))
                })
            })
        
    }
    
    // MARK: - 스터디장 수정
    
    func updateStudyChiefHandler(_ req: Request, container: StudyInfoContainer) throws -> Future<Response> {
        let bearToken = BearerAuthorization(token: container.token)
        return AccessToken
            .authenticate(using: bearToken, on: req)
            .flatMap({ (existToken) in
                
                guard existToken != nil else {
                    return try ResponseJSON<Empty>(status: .token).encode(for: req)
                }
                
                let futureFirst = Study.query(on: req).filter(\.id == container.id).first()
                
                return futureFirst.flatMap({ (existInfo) in
                    let study: Study?
                    var existInfo = existInfo
                    
                    if existInfo?.id == container.id {
                        study = existInfo?.updateChief(with: container)
                    } else {
                        return try ResponseJSON<Empty>(status: .error).encode(for: req)
                    }
                    
                    
                    return (study?.save(on: req).flatMap({ (info) in
                        return try ResponseJSON<Empty>(status: .ok,
                                                       message: "요청 성공").encode(for: req)
                    }))!
                })
            })
        
    }
    
    // MARK: - 스터디 신청 API route
    
    func updateStudyWantUserHandler(_ req: Request, container: StudyInfoContainer) throws -> Future<Response> {
        let bearToken = BearerAuthorization(token: container.token)
        return AccessToken
            .authenticate(using: bearToken, on: req)
            .flatMap({ (existToken) in
                
                guard existToken != nil else {
                    return try ResponseJSON<Empty>(status: .token).encode(for: req)
                }
                
                let futureFirst = Study.query(on: req).filter(\.id == container.id).first()
                
                return futureFirst.flatMap({ (existInfo) in
                    let study: Study?
                    var existInfo = existInfo
                    
                    study = existInfo?.updateWantUser(with: container)
                    
                    return (study?.save(on: req).flatMap({ (info) in
                        return try ResponseJSON<Empty>(status: .ok,
                                                       message: "요청 성공").encode(for: req)
                    }))!
                })
            })
    }
    
    // MARK: - 스터디 신청한 유저 확인 추가 API
    
    func updateStudyUserHandler(_ req: Request, container: StudyInfoContainer) throws -> Future<Response> {
        let bearToken = BearerAuthorization(token: container.token)
        return AccessToken
            .authenticate(using: bearToken, on: req)
            .flatMap({ (existToken) in
                
                guard existToken != nil else {
                    return try ResponseJSON<Empty>(status: .token).encode(for: req)
                }
                
                let futureFirst = Study.query(on: req).filter(\.id == container.id).first()
                
                return futureFirst.flatMap({ (existInfo) in
                    let study: Study?
                    var existInfo = existInfo
                    
                    if existInfo?.id == container.id {
                        study = existInfo?.updateChief(with: container)
                    } else {
                        return try ResponseJSON<Empty>(status: .error).encode(for: req)
                    }
                    
                    return (study?.save(on: req).flatMap({ (info) in
                        return try ResponseJSON<Empty>(status: .ok,
                                                       message: "요청 성공").encode(for: req)
                    }))!
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
    var chiefUser : StudyUser?
    var studyUser: [StudyUser]?
    var wantUser: [StudyUser]?
    var category: String?
    var chapter: [Chapter]?
    var fine: Fine?
    
}
