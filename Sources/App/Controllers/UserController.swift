import Vapor

import Crypto
import Authentication


final class UserController: RouteCollection {
    
    private let authController = AuthController()
    
    func boot(router: Router) throws {
        
        let group = router.grouped("users")
        
        // post
        group.post(User.self, at: "login", use: loginUserHandler)
        group.post(User.self, at: "register", use: registerUserHandler)
        group.post(PasswordContainer.self, at: "changePassword", use: changePasswordHandler)
        group.post(UserInfoContainer.self, at: "updateInfo", use: updateUserInfoHandler)
        group.post(UserInfoContainer.self, at: "userinfo", use: getOtherUserInfoHandler)
        group.post("exit", use: exitUserHandler)
        group.post(ReportInfoContainer.self,
                   at:"report",
                   use: reportUserHandler)
        
        // get
        group.get("getUserInfo", use: getUserInfoHandler)
        group.get("avatar", String.parameter, use: getUserAvatarHandler)
        
    }
    
}


private extension User {
    
    func user(with digest: BCryptDigest) throws -> User {
        
        return try User(userID: UUID().uuidString,
                        email: email,
                        password: digest.hash(password))
    }
}

extension UserController {
    
    
    func loginUserHandler(_ req: Request,user: User) throws -> Future<Response> {
        
        let futureFirst = User.query(on: req).filter(\.email == user.email).first()
        
        return futureFirst.flatMap({ (existingUser) in
            guard let existingUser = existingUser else {
                return try ResponseJSON<Empty>(status: .userNotExist).encode(for: req)
            }
            
            let digest = try req.make(BCryptDigest.self)
            guard try digest.verify(user.password,
                                    created: existingUser.password) else {
                                        return try ResponseJSON<Empty>(status: .passwordError).encode(for: req)
            }
            
            return try self.authController
                .authContainer(for: existingUser, on: req)
                .flatMap({ (container) in
                    
                    var access = AccessContainer(accessToken: container.accessToken)
                    //                if !req.environment.isRelease {
                    access.userID = existingUser.userID
                    //                }
                    
                    return try ResponseJSON<AccessContainer>(status: .ok,
                                                             message: "성공",
                                                             data: access).encode(for: req)
                })
        })
    }
    
    
    func registerUserHandler(_ req: Request, newUser: User) throws -> Future<Response> {
        
        let futureFirst = User.query(on: req).filter(\.email == newUser.email).first()
        return futureFirst.flatMap { existingUser in
            guard existingUser == nil else {
                return try ResponseJSON<Empty>(status: .userExist).encode(for: req)
            }
            
            if newUser.email.isAccount().0 == false {
                return try ResponseJSON<Empty>(status: .error,
                                               message: newUser.email.isAccount().1).encode(for: req)
            }
            
            if newUser.password.isPassword().0 == false {
                return try ResponseJSON<Empty>(status: .error,
                                               message: newUser.password.isPassword().1).encode(for: req)
            }
            
            
            return try newUser
                .user(with: req.make(BCryptDigest.self))
                .save(on: req)
                .flatMap { user in
                    
                    let logger = try req.make(Logger.self)
                    logger.warning("New user created: \(user.email)")
                    
                    return try self.authController
                        .authContainer(for: user, on: req)
                        .flatMap({ (container) in
                            
                            var access = AccessContainer(accessToken: container.accessToken)
                            //                    if !req.environment.isRelease {
                            access.userID = user.userID
                            //                    }
                            
                            return try ResponseJSON<AccessContainer>(status: .ok,
                                                                     message: "성공",
                                                                     data: access).encode(for: req)
                        })
            }
        }
    }
    
    func exitUserHandler(_ req: Request) throws -> Future<Response> {
        
        return try req.content.decode(TokenContainer.self).flatMap({ container in
            
            let token = BearerAuthorization(token: container.token)
            return AccessToken.authenticate(using: token,
                                            on: req).flatMap({ (existToken) in
                                                
                                                guard let existToken = existToken else {
                                                    return try ResponseJSON<Empty>(status: .token).encode(for: req)
                                                }
                                                
                                                return try self.authController.remokeTokens(userID: existToken.userID,
                                                                                            on: req).flatMap({ _ in
                                                                                                return try ResponseJSON<Empty>(status: .ok,
                                                                                                                               message: "성공").encode(for: req)
                                                                                            })
                                            })
        })
    }
    
    
    private func changePasswordHandler(_ req: Request,
                                       inputContent: PasswordContainer)
        throws -> Future<Response> {
            
            return User.query(on: req).filter(\.email == inputContent.email).first().flatMap({ (existUser) in
                
                guard let existUser = existUser else {
                    return try ResponseJSON<Empty>(status: .userNotExist).encode(for: req)
                }
                
                // digest
                let digest = try req.make(BCryptDigest.self)
                guard try digest.verify(inputContent.password,
                                        created: existUser.password) else {
                                            return try ResponseJSON<Empty>(status: .passwordError).encode(for: req)
                }
                
                if inputContent.newPassword.isPassword().0 == false {
                    return try ResponseJSON<Empty>(status: .error,
                                                   message: inputContent.newPassword.isPassword().1).encode(for: req)
                }
                
                var user = existUser
                user.password = try req.make(BCryptDigest.self).hash(inputContent.newPassword)
                
                return user.save(on: req).flatMap { newUser in
                    
                    let logger = try req.make(Logger.self)
                    logger.info("Password Changed Success: \(newUser.email)")
                    return try ResponseJSON<Empty>(status: .ok,
                                                   message: "성공！").encode(for: req)
                }
            })
    }
    
    func getUserInfoHandler(_ req: Request) throws -> Future< Response> {
        
        guard let token = req.query[String.self,
                                    at: "token"] else {
                                        return try ResponseJSON<Empty>(status: .token,
                                                                       message: "토큰이 없습니다").encode(for: req)
        }
        
        let bearToken = BearerAuthorization(token: token)
        return AccessToken
            .authenticate(using: bearToken, on: req)
            .flatMap({ (existToken) in
                
                guard let existToken = existToken else {
                    return try ResponseJSON<Empty>(status: .token).encode(for: req)
                }
                
                let futureFirst = UserInfo.query(on: req).filter(\.userID == existToken.userID).first()
                
                return futureFirst.flatMap({ (existInfo) in
                    guard let existInfo = existInfo else {
                        return try ResponseJSON<Empty>(status: .error,
                                                       message: "사용자 정보가 없습니다").encode(for: req)
                    }
                    return try ResponseJSON<UserInfo>(data: existInfo).encode(for: req)
                })
            })
    }
    
    func getOtherUserInfoHandler(_ req: Request, container: UserInfoContainer) throws -> Future< Response> {
        
        let bearToken = BearerAuthorization(token: container.token)
        return AccessToken
            .authenticate(using: bearToken, on: req)
            .flatMap({ (existToken) in
                
                guard existToken != nil else {
                    return try ResponseJSON<Empty>(status: .token).encode(for: req)
                }
                
                let futureFirst = UserInfo.query(on: req).filter(\.userID == container.userID ?? "").first()
                return futureFirst.flatMap({ (existInfo) in
                    guard let existInfo = existInfo else {
                        return try ResponseJSON<Empty>(status: .error,
                                                       message: "사용자 정보가 없습니다").encode(for: req)
                    }
                    return try ResponseJSON<UserInfo>(data: existInfo).encode(for: req)
                })
            })
    }
    
    
    func getUserAvatarHandler(_ req: Request) throws -> Future<Response> {
        
        let name = try req.parameters.next(String.self)
        let path = try VaporUtils.localRootDir(at: ImagePath.userPic, req: req) + "/" + name
        if !FileManager.default.fileExists(atPath: path) {
            let json = ResponseJSON<Empty>(status: .error,
                                           message: "Image does not exist")
            return try json.encode(for: req)
        }
        return try req.streamFile(at: path)
    }
    
    
    func updateUserInfoHandler(_ req: Request,container: UserInfoContainer) throws -> Future<Response> {
        
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
                        userInfo = existInfo.update(with: container)
                        
                    } else {
                        userInfo = UserInfo(id: nil,
                                            userID: existToken.userID,
                                            age: container.age,
                                            sex: container.sex,
                                            nickName: container.nickName,
                                            location: container.location,
                                            image: container.image,
                                            content: container.content,
                                            userCategory: container.category,
                                            like: []
                        )
                    }
                    
                    return (userInfo!.save(on: req).flatMap({ (info) in
                        return try ResponseJSON<UserInfo>(data: info).encode(for: req)
                    }))
                })
            })
    }
    
    func reportUserHandler(_ req: Request,container: ReportInfoContainer) throws -> Future<Response> {
        
        let bearToken = BearerAuthorization(token: container.token)
        return AccessToken
            .authenticate(using: bearToken, on: req)
            .flatMap({ (existToken) in
                guard let existToken = existToken else {
                    return try ResponseJSON<Empty>(status: .token).encode(for: req)
                }
                
                let futureFirst = UserReport.query(on: req).filter(\.userID == container.userID).first()
                return futureFirst.flatMap({ (existInfo) in
                    
                    let userInfo: UserReport?
                    
                    if var existInfo = existInfo {
                        userInfo = existInfo.userReport(with: container)
                        
                    } else {
                        userInfo = UserReport(id: nil,
                                              userID: container.userID,
                                              content: container.reportContent,
                                              reportUserID: [existToken.userID],
                                              count: 1)
                    }
                    
                    return (userInfo!.save(on: req).flatMap({ (info) in
                        return try ResponseJSON<Empty>(status: .ok,
                                                       message: "요청 성공").encode(for: req)
                    }))
                })
            })
    }
    
    
    
}



fileprivate struct TokenContainer: Content {
    var token: String
    
}

fileprivate struct PasswordContainer: Content {
    var email: String
    var password: String
    var newPassword: String
    
}

fileprivate struct AccessContainer: Content {
    
    var accessToken: String
    var userID:String?
    
    init(accessToken: String,userID: String? = nil) {
        self.accessToken = accessToken
        self.userID = userID
    }
}

struct UserInfoContainer: Content {
    
    var token:String
    
    var age: Int?
    var sex: Int?
    var nickName: String?
    var location: String?
    var content: String?
    var image: String?
    var category: [String]?
    var like: [LikeStudy]?
    var likeIndex: Int?
    var userID: String?
}

struct ReportInfoContainer: Content {
    var token: String
    
    var content: String?
    var contentID: Int?
    var reportContent: [String]?
    var reportUserID: [String]?
    var userID: String?
}
