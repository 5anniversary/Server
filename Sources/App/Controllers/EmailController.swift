import Vapor
import FluentMySQL

class EmailController: RouteCollection {
    
    func boot(router: Router) throws {
        
        router.post("sendEmail", use: sendEmailHandler)
    }
    
}


extension EmailController {
    
    func sendEmailHandler(_ req: Request) throws -> Future<Response> {
        return try req.content.decode(EmailContent.self).flatMap({ content in
            return EmailResult
                .query(on: req)
                .filter(\.email == content.email)
                .count()
                .flatMap({ (count) in
                guard count < 5 else {
                   return try ResponseJSON<Empty>(status: .error,
                                                  message: "전송 한도가 초과되었습니다.").encode(for: req)
                }
                return try EmailSender.sendEmail(req, content: content).flatMap({ (state) in
                    let result = EmailResult.init(id: nil,
                                                      state: state,
                                                      email: content.email,
                                                      sendTime: TimeManager.current())
                    
                    return result.save(on: req).flatMap({ (us) in
                        return try ResponseJSON(status: .ok,
                                                message: "발신에 성공했습니다.", data: result).encode(for: req)
                    })
                })
            })
        
        })
    }
}


struct EmailContent: Content {
    
    var email: String
    var myName: String?
    var subject: String?
    var text: String?
    
}



