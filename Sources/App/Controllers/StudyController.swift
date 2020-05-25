import Vapor
import Crypto
import Authentication

final class StudyController: RouteCollection {
    
    func boot(router: Router) throws {
        let group = router.grouped("study")
        
        group.post(StudyInfoContainer.self,
                   at: "create",
                   use: createStudyHandler)
        
        group.post(StudyInfoContainer.self,
                   at: "updatechief",
                   use: updateStudyChiefHandler)
        
        group.post(StudyInfoContainer.self,
                   at:"getcategory",
                   use: CategoryStudyListHandler)
        
        group.post(StudyInfoContainer.self,
                   at:"getstudyinfo",
                   use: StudyListHandler)
        
        group.post(StudyInfoContainer.self,
                   at:"addwantuser",
                   use: updateStudyWantUserHandler)
        
        group.post(StudyInfoContainer.self,
                   at:"addstudyuser",
                   use: updateStudyUserHandler)
        
        group.get("getinfo", use: allStudyListHandler)
        
    }
    
}

extension StudyController {
    
    // MARK: - 스터디 목록 전체 리스트 불러오기
    
    func allStudyListHandler(_ req: Request) throws -> Future<Response> {
        return Study
            .query(on: req)
            .sort(\.createdAt,.descending)
            .query(page: req.page)
            .all()
            .flatMap({ (studies) in
                let study = studies.compactMap({ stu -> Study in
                    var stu = stu; stu.chapter = nil; stu.chiefUser = nil; stu.studyUser = nil
                    stu.wantUser = nil; stu.fine = nil;
                    return stu
                })
                return try ResponseJSON<[Study]>(data: study).encode(for: req)
            })
    }
    
    func allqStudyListHandler(_ req: Request, container: StudyInfoContainer) throws -> Future<Response> {
        return Study
            .query(on: req)
            .filter(\.studyUser == container.studyUser)
            .sort(\.createdAt,.descending)
            .query(page: req.page)
            .all()
            .flatMap({ (studies) in
                let study = studies.compactMap({ stu -> Study in
                    var stu = stu; stu.chapter = nil; stu.chiefUser = nil;stu.category = nil
                    stu.wantUser = nil; stu.fine = nil;
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
                    .sort(\.createdAt,.descending)
                    .query(page: req.page)
                    .all()
                    .flatMap({ (category) in
                        let categorys = category.compactMap({ cate -> Study in
                            var stu = cate; stu.chapter = nil; stu.chiefUser = nil; stu.studyUser = nil
                            stu.wantUser = nil; stu.fine = nil;
                            return stu
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
                
                return futureFirst.flatMap({ (existInfo) in
                    var study: Study?
                    
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
                                  studyUser: container.studyUser,
                                  wantUser: container.wantUser ?? [],
                                  fine: container.fine ?? Fine.init(id: nil,
                                                                    attendance: 0,
                                                                    tardy: 0,
                                                                    assignment: 0)
                    )
                    
                    return (study!.save(on: req).flatMap({ (info) in
                        let studyUser: StudyUser?
                        
                        studyUser = StudyUser(id: nil,
                                              studyID: info.id,
                                              name: container.chiefUser?.name ?? "",
                                              userID: container.chiefUser?.userID ?? "",
                                              image: container.chiefUser?.image ?? "",
                                              attendance: 0,
                                              tardy: 0,
                                              assignment: 0)
                        
                        return (studyUser!.save(on: req).flatMap({ (info) in
                            return try ResponseJSON<Empty>(status: .ok,
                                                           message: "요청 성공").encode(for: req)
                        }))
                    }))
                })
            })
        
    }
    
    // MARK: - 스터디 수정 API
    
    func updateStudyHandler(_ req: Request, container: StudyInfoContainer) throws -> Future<Response> {
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
                    
                    study = existInfo?.update(with: container)
                    
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
                        study = existInfo?.moveWantToStudy(with: container)
                    } else {
                        return try ResponseJSON<Empty>(status: .error).encode(for: req)
                    }
                    
                    return (study?.save(on: req).flatMap({ (info) in
                        let studyUser: StudyUser?
                        
                        studyUser = StudyUser(id: nil,
                                              studyID: info.id,
                                              name: container.studyUser?[0].name ?? "",
                                              userID: container.studyUser?[0].userID ?? "",
                                              image: container.studyUser?[0].image ?? "",
                                              attendance: 0,
                                              tardy: 0,
                                              assignment: 0)
                        return (studyUser?.save(on: req).flatMap({ (info) in
                            return try ResponseJSON<Empty>(status: .ok,
                                                           message: "요청 성공").encode(for: req)
                        }))!
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
    
    var deleteUserIndex: Int?
}
