import Vapor

struct Empty: Content {}

struct ResponseJSON<T: Content>: Content{
    
    private var status: ResponseStatus
    private var message: String
    private var data: T?
    
    init(data: T) {
        self.status = .ok
        self.message = status.desc
        self.data = data
    }
    
    init(status:ResponseStatus = .ok) {
        self.status = status
        self.message = status.desc
        self.data = nil
    }
    
    
    init(status:ResponseStatus = .ok,
         message: String = ResponseStatus.ok.desc) {
        self.status = status
        self.message = message
        self.data = nil
    }
    
    init(status:ResponseStatus = .ok,
         message: String = ResponseStatus.ok.desc,
         data: T?) {
        self.status = status
        self.message = message
        self.data = data
    }
}

enum ResponseStatus:Int,Content {
    case ok = 200
    case error = 400
    case missesPara = 406
    case token = 411
    case unknown = 500
    case userExist = 420
    case userNotExist = 421
    case passwordError = 422
    case pictureTooBig = 423
    
    var desc : String {
        switch self {
        case .ok:
            return "요청이 성공했습니다."
        case .error:
            return "요청이 실패했습니다."
        case .missesPara:
            return "퍄라미터 내용이 부족합니다."
        case .token:
            return "Token 토큰이 효력을 잃었습니다."
        case .unknown:
            return "에러의 원인을 모릅니다."
        case .userExist:
            return "사용자가 이미 있습니다."
        case .userNotExist:
            return "사용자가 없습니다."
        case .passwordError:
            return "비밀번호가 올바르지 않습니다."
        case .pictureTooBig:
            return "사진의 크기가 커 압축이 필요합니다."
        }
        
    }

}






