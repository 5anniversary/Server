import Vapor
import SwiftSMTP


fileprivate let emailPassword = Environment.get("EMAIL_PASSWORD") ?? ""

fileprivate var emailDic = Dictionary<String,String>()

fileprivate let smtp = SMTP(hostname: "smtp.gmail.com",
                            email: "studyTogether.skhu@gmail.com",
                            password: emailPassword
                            )

struct EmailSender {
    
    static func sendEmail(_ req:Request,content: EmailContent) throws -> Future<Bool> {
    

        let promise = req.eventLoop.newPromise(Bool.self)

        let emailUser = Mail.User(email: content.email)
        
        let myName = content.myName ?? "Study Together"
        let sub = content.subject ?? "Swift Vapor SMTP \(TimeManager.current())"
        let text = content.text ?? ""
        
        let MyEmailUser = Mail.User(name: myName, email: "studyTogether.skhu@gmail.com")

        let mail = Mail(from: MyEmailUser,
                        to: [emailUser],
                        subject:sub,
                        text: text)
        
        smtp.send(mail) { (error) in
            if let error = error {
                print("이메일 발신 오류입니다：",error)
                promise.fail(error: error)
            }else {
                print("발신에 성공했습니다")
                promise.succeed(result: true)
            }
        }
        
        return promise.futureResult
        
    }
}

