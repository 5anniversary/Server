import Vapor
import Crypto
import Authentication

final class ChapterController: RouteCollection {
    
    func boot(router: Router) throws {
        let group = router.grouped("chapter")
        
        group.post(ChapterInfoContainer.self,
                   at:"create",
                   use: createChapterHandler)

        
    }
    
}

extension ChapterController {
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
                                      studyID: container.studyID,
                                      content: container.content,
                                      date: container.date,
                                      place: container.place
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

}


struct ChapterInfoContainer: Content {
    var token: String
    
    var id: Int?
    var studyID: Int
    var number: Int
    var content: String
    var date: String
    var place: String
//    var attendance: Int
//    var isAssignment: Bool
}
