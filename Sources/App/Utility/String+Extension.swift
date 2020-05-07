import Foundation
import Vapor
import Crypto

extension String {

//    var isEmail : Bool {
//        let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
//        let str = "SELF MATCHES \(pattern)"
//        let pred = NSPredicate(format: str) // 
//        let isMatch:Bool = pred.evaluate(with: self)
//        return isMatch
//    }
    
    func hashString(_ req: Request) throws -> String {
       return try req.make(BCryptDigest.self).hash(self)
    }
 
    
    func isAccount() -> (Bool,String) {
        if count < AccountMinCount {
            return (false,"계정의 길이가 짧습니다.")
        }
        
        if count > AccountMaxCount {
            return (false,"계정의 길이를 초과되었습니다.")
        }
        return (true,"계정길이가 알맞습니다.")
    }
    
    func isPassword() -> (Bool,String) {
        if count < passwordMinCount {
            return (false,"비밀번호의 길이가 짧습니다.")
        }
        
        if count > PasswordMaxCount {
            return (false,"비밀번호의 길이가 초과되었습니다.")
        }
        return (true,"비밀번호의 길이가 알맞습니다.")
    }
}

extension String {
    
    var outPutUnit: String {
        #if os(Linux)
        let s = "%s"
        #else
        let s = "%@"
        #endif
        return s
    }
    
}
