import Vapor
import Crypto
import Authentication

final class ChapterController: RouteCollection {
    
    func boot(router: Router) throws {
        let group = router.grouped("chapter")
        
        group.post(ChapterInfoContainer.self,
                   at:"create",
                   use: createChapterHandler)
        
        group.post(ChapterInfoContainer.self,
                   at:"chapterlist",
                   use: getChapterListHandler)
        
        group.post(ChapterInfoContainer.self,
                   at:"chapter",
                   use: getChapterHandler)
        
        group.post(ChapterInfoContainer.self,
                   at:"update",
                   use: updateHandler)
        
        group.post(CheckInfoContainer.self,
                   at:"check",
                   use: checkHandler)

        group.delete("delete",
                     use: deleteHandler)
        
    }
    
}

extension ChapterController {
    
    // MARK: - 챕터 생성 API
    
    func createChapterHandler(_ req: Request, container: ChapterInfoContainer) throws -> Future<Response> {
        let bearToken = BearerAuthorization(token: container.token)
        return AccessToken
            .authenticate(using: bearToken, on: req)
            .flatMap({ (existToken) in
                
                guard existToken != nil else {
                    return try ResponseJSON<Empty>(status: .token).encode(for: req)
                }
                
                let futureFirst = Chapter.query(on: req).filter(\.id == container.id).first()
                
                return futureFirst.flatMap({ _ in
                    let chapter: Chapter?
                    
                    chapter = Chapter(id: nil,
                                      title: container.title ?? "",
                                      studyID: container.studyID ?? 0,
                                      content: container.content ?? "",
                                      date: container.date ?? "",
                                      place: container.place ?? ""
                    )
                    
                    
                    return (chapter!.save(on: req).flatMap({ (info) in
                        let check: Check?
                        
                        check = Check(id: nil,
                                      studyID: info.studyID,
                                      chapterID: info.id!,
                                      attendance: [],
                                      tardy: [],
                                      assignment: [])
                        
                        return (check!.save(on: req).flatMap({ (info) in
                            return try ResponseJSON<Empty>(status: .ok,
                                                           message: "요청 성공").encode(for: req)
                            
                        }))
                    }))
                })
            })
    }
    
    // MARK: - 챕터 리스트 검색 API
    
    func getChapterListHandler(_ req: Request, container: ChapterInfoContainer) throws -> Future<Response> {
        let bearToken = BearerAuthorization(token: container.token)
        return AccessToken
            .authenticate(using: bearToken, on: req)
            .flatMap({ (existToken) in
                
                guard existToken != nil else {
                    return try ResponseJSON<Empty>(status: .token).encode(for: req)
                }
                
                
                return Chapter
                    .query(on: req)
                    .filter(\.studyID == container.studyID ?? 0)
                    .sort(\.createdAt,.descending)
                    .query(page: req.page)
                    .all()
                    .flatMap({ (category) in
                        let categorys = category.compactMap({ cate -> Chapter in
                            
                            return cate
                        })
                        return try ResponseJSON<[Chapter]>(data: categorys).encode(for: req)
                    })
            })
    }
    
    // MARK: - 챕터 검색 API
    
    func getChapterHandler(_ req: Request, container: ChapterInfoContainer) throws -> Future<Response> {
        let bearToken = BearerAuthorization(token: container.token)
        return AccessToken
            .authenticate(using: bearToken, on: req)
            .flatMap({ (existToken) in
                
                guard existToken != nil else {
                    return try ResponseJSON<Empty>(status: .token).encode(for: req)
                }
                
                return Chapter
                    .query(on: req)
                    .filter(\.id == container.id)
                    .all()
                    .flatMap({ (category) in
                        let categorys = category.compactMap({ cate -> Chapter in
                            
                            return cate
                        })
                        return try ResponseJSON<[Chapter]>(data: categorys).encode(for: req)
                    })
            })
    }
    
    // 
    
    func checkHandler(_ req: Request, container: ChapterInfoContainer) throws -> Future<Response> {
        let bearToken = BearerAuthorization(token: container.token)
        return AccessToken
            .authenticate(using: bearToken, on: req)
            .flatMap({ (existToken) in
                
                guard existToken != nil else {
                    return try ResponseJSON<Empty>(status: .token).encode(for: req)
                }
                
                let futureFirst = Chapter.query(on: req).filter(\.id == container.id).first()
                
                return futureFirst.flatMap({ _ in
                    let chapter: Chapter?
                    
                    chapter = Chapter(id: nil,
                                      title: container.title ?? "",
                                      studyID: container.studyID ?? 0,
                                      content: container.content ?? "",
                                      date: container.date ?? "",
                                      place: container.place ?? ""
                    )
                    
                    
                    return (chapter!.save(on: req).flatMap({ (info) in
                        let check: Check?
                        
                        check = Check(id: nil,
                                      studyID: info.studyID,
                                      chapterID: info.id!,
                                      attendance: [],
                                      tardy: [],
                                      assignment: [])
                        
                        return (check!.save(on: req).flatMap({ (info) in
                            return try ResponseJSON<Empty>(status: .ok,
                                                           message: "요청 성공").encode(for: req)
                            
                        }))
                    }))
                })
            })
    }
    
    
    func updateHandler(_ req: Request, container: ChapterInfoContainer) throws -> Future<Response> {
        let bearToken = BearerAuthorization(token: container.token)
        return AccessToken
            .authenticate(using: bearToken, on: req)
            .flatMap({ (existToken) in
                
                guard existToken != nil else {
                    return try ResponseJSON<Empty>(status: .token).encode(for: req)
                }
                
                let futureFirst = Chapter.query(on: req).filter(\.id == container.id).first()
                
                return futureFirst.flatMap({ (existInfo) in
                    let chapter: Chapter?
                    var existInfo = existInfo
                    
                    if existInfo?.id == container.id {
                        chapter = existInfo?.update(with: container)
                    } else {
                        return try ResponseJSON<Empty>(status: .error).encode(for: req)
                    }
                    
                    return (chapter?.save(on: req).flatMap({ result in
                        return try ResponseJSON<Empty>(status: .ok,
                                                       message: "요청 성공").encode(for: req)
                        
                    }))!
                })
            })
    }
    
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
                
                let futureFirst = Chapter.query(on: req).filter(\.id == id).delete()
                
                return futureFirst.flatMap({ (existInfo) in
                    return try ResponseJSON<Empty>(status: .ok,
                                                   message: "요청 성공").encode(for: req)
                })
            })
    }
    
    func checkHandler(_ req: Request, container: CheckInfoContainer) throws -> Future<Response>{
        let bearToken = BearerAuthorization(token: container.token)
        return AccessToken
            .authenticate(using: bearToken, on: req)
            .flatMap({ (existToken) in
                
                guard existToken != nil else {
                    return try ResponseJSON<Empty>(status: .token).encode(for: req)
                }
                
                let futureFirst = StudyUser
                    .query(on: req)
                    .filter(\.userID == container.userID ?? "")
                    .filter(\.studyID == container.studyID)
                    .first()
                
                return futureFirst.flatMap({ info in
                    var info = info
                    
                    if container.assignment != nil {
                        info = info?.assignmentPlus(with: container)
                    }
                    if container.attendance != nil {
                        info = info?.attendancePlus(with: container)
                    }
                    if container.tardy != nil {
                        info = info?.tardyPlus(with: container)
                    }
                    return (info?.save(on: req).flatMap({ info in
                        
                        let futureCheck = Check
                            .query(on: req)
                            .filter(\.studyID == container.studyID ?? 0)
                            .filter(\.chapterID == container.chapterID ?? 0)
                            .first()
                            
                        return (futureCheck.flatMap({ (existInfo) in
                            var existInfo = existInfo
                            var check: Check?
                            
                            
                            if existInfo?.chapterID == container.chapterID {
                                check = existInfo!.update(with: container)
                            } else {
                                return try ResponseJSON<Empty>(status: .error).encode(for: req)
                            }
                            
                            return (check?.save(on: req).flatMap({ result in
                                
                                return try ResponseJSON<Empty>(status: .ok, message: "요청 성공")
                                    .encode(for: req)
                            }))!
                        }))
                        
                        
                    }))!
                })
            })
    }
    
    
}


struct ChapterInfoContainer: Content {
    var token: String
    
    var id: Int?
    var studyID: Int?
    var title: String?
    var number: Int?
    var content: String?
    var date: String?
    var place: String?
    
}

struct CheckInfoContainer: Content {
    var token: String
    
    var studyID: Int?
    var userID: String?
    var chapterID: Int?
    var attendance: [IsCheck]?
    var tardy: [IsCheck]?
    var assignment: [IsCheck]?
}
