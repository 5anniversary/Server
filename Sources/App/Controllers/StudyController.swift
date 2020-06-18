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
        
        group.post(StudyInfoContainer.self,
                   at:"updatestudy",
                   use: updateStudyHandler)
        
        group.post(ReportInfoContainer.self,
                   at:"report",
                   use: reportStudyHandler)
        
        group.post(UserInfoContainer.self,
                   at:"like",
                   use: addLikeStudyHandler)
        group.post(UserInfoContainer.self,
                   at:"cancellike",
                   use: removeLikeStudyHandler)
        
        group.post(StudyInfoContainer.self,
                   at:"end",
                   use: endStudyHandler)

        group.get("search",
                  use: searchHandler)
        
        group.get("studyuser",
                  use: getStudyUserHandler)

        group.delete("delete", use: deleteHandler)
        
        group.get("getinfo", use: allStudyListHandler)
        group.get("mystudy", use: getStudyingHandler)

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
                            var ca = cate; ca.chapter = nil
                            return ca
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
                                  isDate: container.isDate ?? false,
                                  startDate: container.startDate ?? "",
                                  endDate: container.endDate ?? "",
                                  chapter: container.chapter ?? [],
                                  chiefUser: container.chiefUser,
                                  studyUser: container.studyUser ?? [StudyUser].init(arrayLiteral: container.chiefUser!),
                                  wantUser: container.wantUser ?? [],
                                  fine: container.fine ?? Fine.init(id: nil,
                                                                    attendance: 0,
                                                                    tardy: 0,
                                                                    assignment: 0)
                    )
                    
                    return (study!.save(on: req).flatMap({ (info) in
                        let studyUser: StudyUser?
                        let studying: Studying?
                        
                        studyUser = StudyUser(id: nil,
                                              studyID: info.id,
                                              name: container.chiefUser?.name ?? "",
                                              userID: container.chiefUser?.userID ?? "",
                                              image: container.chiefUser?.image ?? "",
                                              attendance: 0,
                                              tardy: 0,
                                              assignment: 0)
                        
                        studying = Studying(id: nil,
                                            name: info.name,
                                            studyID: info.id,
                                            userID: container.chiefUser?.userID,
                                            category: info.category,
                                            isEnd: false,
                                            userLimit: info.userLimit,
                                            image: info.image,
                                            content: info.content,
                                            location: info.location,
                                            isFine: info.isFine
                        )
                        
                        studying!.save(on: req)
                        
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
                    
                    if var existInfo = existInfo {
                        study = existInfo.update(with: container)
                    } else {
                        return try ResponseJSON<Empty>(status: .error,
                                                       message: "실패").encode(for: req)
                    }
                    
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
                    
                    if var existInfo = existInfo {
                        study = existInfo.updateChief(with: container)
                    } else {
                        return try ResponseJSON<Empty>(status: .error,
                                                       message: "실패").encode(for: req)
                    }
                    
                    return (study!.save(on: req).flatMap({ (info) in
                        return try ResponseJSON<Empty>(status: .ok,
                                                       message: "요청 성공").encode(for: req)
                    }))
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
                        let studying: Studying?
                        
                        studyUser = StudyUser(id: nil,
                                              studyID: info.id,
                                              name: container.studyUser?[0].name ?? "",
                                              userID: container.studyUser?[0].userID ?? "",
                                              image: container.studyUser?[0].image ?? "",
                                              attendance: 0,
                                              tardy: 0,
                                              assignment: 0)
                        
                        studying = Studying(id: nil,
                                            name: info.name,
                                            studyID: info.id,
                                            userID: container.studyUser?[0].userID,
                                            category: existInfo?.category,
                                            isEnd: false,
                                            userLimit: info.userLimit,
                                            image: info.image,
                                            content: info.content,
                                            location: info.location,
                                            isFine: info.isFine
                        )
                        
                        studying?.save(on: req)
                        
                        return (studyUser?.save(on: req).flatMap({ (info) in
                            return try ResponseJSON<Empty>(status: .ok,
                                                           message: "요청 성공").encode(for: req)
                        }))!
                    }))!
                })
            })
        
    }
    
    // MARK: - 스터디 종료 API : Todo
    
    func endStudyHandler(_ req: Request, container: StudyInfoContainer) throws -> Future<Response> {
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
                        existInfo?.isEnd = true
                        study = existInfo
                    } else {
                        return try ResponseJSON<Empty>(status: .error).encode(for: req)
                    }
                    
                    var studyID: String?
                    let id:Int! = container.id
                    studyID = String.init(describing: id!)
                    
                    _ = req.withPooledConnection(to: .mysql) { (conn) -> Future<[Studying]> in
                        conn.raw("update j82tawrs7p22ynqg.Studying set isEnd = true where studyID = " + "\(studyID!)").all(decoding:Studying.self)
                    }
                    
                    return (study?.save(on: req).flatMap({ (info) in
                            return try ResponseJSON<Empty>(status: .ok,
                                                           message: "요청 성공").encode(for: req)
                    }))!
                })
            })
        
    }
    
    // MARK: - 스터디 검색 API
    
    func searchHandler(_ req: Request) throws -> Future<Response> {
        guard let name = req.query[String.self, at: "name"] else {
            throw Abort(.badRequest, reason: "Missing search term in request")
        }
        
        guard let token = req.query[String.self, at: "token"] else {
            throw Abort(.badRequest, reason: "Missing token in request")
        }
        
        let bearToken = BearerAuthorization(token: token)
        return AccessToken
            .authenticate(using: bearToken, on: req)
            .flatMap({ (existToken) in
                
                guard existToken != nil else {
                    return try ResponseJSON<Empty>(status: .token).encode(for: req)
                }
                
                let result = req.withPooledConnection(to: .mysql) { conn -> Future<[Study]> in
                    conn.raw("Select * from j82tawrs7p22ynqg.Study where name like '%" + name + "%'" ).all(decoding: Study.self)
                }
                
                return result.flatMap({ (studies) in
                    let study = studies.compactMap({ stu -> Study in
                        var stu = stu; stu.chapter = nil; stu.chiefUser = nil; stu.studyUser = nil
                        stu.wantUser = nil; stu.fine = nil;
                        return stu
                    })
                    return try ResponseJSON<[Study]>(data: study).encode(for: req)
                })
            })
    }
    
    // MARK: - 스터디 삭제 API
    func deleteHandler(_ req: Request) throws -> Future<Response> {
        let token = try req.query.get(String.self, at: "token")
        let id = try req.query.get(Int.self, at: "id")
        
        let bearToken = BearerAuthorization(token: token)
        return AccessToken
            .authenticate(using: bearToken, on: req)
            .flatMap({ (existToken) in
                
                guard existToken != nil else {
                    return try ResponseJSON<Empty>(status: .token).encode(for: req)
                }
                
                let futureResult = Study.query(on: req).filter(\.id == id).delete()
                
                return futureResult.flatMap({ (existInfo) in
                    return try ResponseJSON<Empty>(status: .ok, message: "삭제가 완료되었습니다.").encode(for: req)
                })
            })
    }
    
    func reportStudyHandler(_ req: Request,container: ReportInfoContainer) throws -> Future<Response> {
        
        let bearToken = BearerAuthorization(token: container.token)
        return AccessToken
            .authenticate(using: bearToken, on: req)
            .flatMap({ (existToken) in
                guard let existToken = existToken else {
                    return try ResponseJSON<Empty>(status: .token).encode(for: req)
                }
                
                let futureFirst = StudyReport.query(on: req).filter(\.contentID == container.contentID).first()
                return futureFirst.flatMap({ (existInfo) in
                    
                    let content = Study.query(on: req).filter(\.id == container.contentID).first()
                    
                    return content.flatMap({ contentInfo in
                        let userInfo: StudyReport?
                        
                        var container = container
                        
                        container.reportUserID = [existToken.userID]
                        
                        if var existInfo = existInfo {
                            userInfo = existInfo.studyReport(with: container)
                        } else {
                            userInfo = StudyReport(id: nil,
                                                   contentID: container.contentID,
                                                   content: container.content,
                                                   reportContent: container.reportContent,
                                                   reportUserID: [existToken.userID],
                                                   count: 1)
                        }
                        return (userInfo!.save(on: req).flatMap({ (info) in
                            return try ResponseJSON<Empty>(status: .ok,
                                                           message: "요청 성공").encode(for: req)
                        }))
                    })
                })
            })
    }
    
    func addLikeStudyHandler(_ req: Request,container: UserInfoContainer) throws -> Future<Response> {
        
        let bearToken = BearerAuthorization(token: container.token)
        return AccessToken
            .authenticate(using: bearToken, on: req)
            .flatMap({ (existToken) in
                guard let existToken = existToken else {
                    return try ResponseJSON<Empty>(status: .token).encode(for: req)
                }
                
                let futureFirst = UserInfo.query(on: req).filter(\.userID == existToken.userID).first()
                
                return futureFirst.flatMap({ (existInfo) in
                    let userInfo: UserInfo?
                    
                    if var existInfo = existInfo {
                        
                        userInfo = existInfo.addLikeStudy(with: container)
                        
                    } else {
                        return try ResponseJSON<Empty>(status: .error,
                                                       message: "서버에서 해당 요청에 대한 처리를 하지 못했습니다.").encode(for: req)
                    }
                    
                    return (userInfo!.save(on: req).flatMap({ (info) in
                        return try ResponseJSON<Empty>(status: .ok,
                                                       message: "요청 성공").encode(for: req)
                    }))
                })
            })
    }
    
    
    func removeLikeStudyHandler(_ req: Request,container: UserInfoContainer) throws -> Future<Response> {
        
        let bearToken = BearerAuthorization(token: container.token)
        return AccessToken
            .authenticate(using: bearToken, on: req)
            .flatMap({ (existToken) in
                guard let existToken = existToken else {
                    return try ResponseJSON<Empty>(status: .token).encode(for: req)
                }
                
                let futureFirst = UserInfo.query(on: req).filter(\.userID == existToken.userID).first()
                
                return futureFirst.flatMap({ (existInfo) in
                    let userInfo: UserInfo?
                    
                    if var existInfo = existInfo {
                        userInfo = existInfo.removeLikeStudy(with: container)
                        
                    } else {
                        return try ResponseJSON<Empty>(status: .error,
                                                       message: "서버에서 해당 요청에 대한 처리를 하지 못했습니다.").encode(for: req)
                    }
                    
                    return (userInfo!.save(on: req).flatMap({ (info) in
                        return try ResponseJSON<Empty>(status: .ok,
                                                       message: "요청 성공").encode(for: req)
                    }))
                })
            })
    }
    
    func getStudyingHandler(_ req: Request) throws -> Future<Response> {
        let token = try req.query.get(String.self, at: "token")
        let userID = try req.query.get(String.self, at: "userID")
        
        let bearToken = BearerAuthorization(token: token)
        return AccessToken
            .authenticate(using: bearToken, on: req)
            .flatMap({ (existToken) in
                guard existToken != nil else {
                    return try ResponseJSON<Empty>(status: .token).encode(for: req)
                }
                
                let futureFirst = Studying
                    .query(on: req)
                    .filter(\.userID == userID)
                    .sort(\.id, .descending)
                    .all()
                
                return futureFirst.flatMap({ (existInfo) in
                    return try ResponseJSON<[Studying]>(data: existInfo).encode(for: req)
                })
            })
    }
    
    func getStudyUserHandler(_ req: Request) throws -> Future<Response> {
        let token = try req.query.get(String.self, at: "token")
        let studyID = try req.query.get(Int.self, at: "studyID")
        
        let bearToken = BearerAuthorization(token: token)
        return AccessToken
            .authenticate(using: bearToken, on: req)
            .flatMap({ (existToken) in
                guard existToken != nil else {
                    return try ResponseJSON<Empty>(status: .token).encode(for: req)
                }
                
                let futureFirst = StudyUser
                    .query(on: req)
                    .filter(\.studyID == studyID)
                    .sort(\.id, .ascending)
                    .all()
                
                return futureFirst.flatMap({ (existInfo) in
                    return try ResponseJSON<[StudyUser]>(data: existInfo).encode(for: req)
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
    var isDate: Bool?
    var startDate: String?
    var endDate: String?
    var chiefUser : StudyUser?
    var studyUser: [StudyUser]?
    var wantUser: [StudyUser]?
    var category: String?
    var chapter: [Chapter]?
    var fine: Fine?
    
    var deleteUserIndex: Int?
}

