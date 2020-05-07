## API Instructions

[User](API.md/#User)

- [x] [register](API.md/#register)
- [x] [login](API.md/#login)
- [x] [change password](API.md/#changepassword)
- [x] [get user info ](API.md/#getuserinfo)
- [x] [modify user info ](API.md/#modifyuserinfo)
- [x] [logout ](API.md/#logout)



[Email](API.md/#Email)

- [x] [emailSend](API.md/#emailSend)



<h2 id="User">User</h2>

> 현재 로그인 Token 유효기간 60 * 60 * 24 * 30 second 

<h3 id="register">register</h3>


> Content-type : application/json

```http
POST /users/register
```

### Request
```json
{
	"email":"123123@gmail.com",
	"password":"123123",
}
```

### Response
> Success : 200
```json
{
    "status": 200,
    "message": "성공",
    "data": {
        "accessToken": "RsIhKMF-MHmdUeGBNTZOKmcu0j1g8CdynGh-NyPaAqs",
        "userID": "AF70896A-E522-4E95-A504-3F8A13035C2F"
    }
}
```




<h3 id="login">login</h3>

> users/login

> Content-type : application/json

```http
POST /users/register
```

### Request
```json
{
	"email":"123123@gmail.com",
	"password":"123123",
}
```


### Response
> Success : 200
```json
{
    "status": 200,
    "message": "성공",
    "data": {
        "accessToken": "QYfCEqwpsilLjKipqkBagtAf7jDmxVHF0I3mjBbA2XQ",
        "userID": "AF70896A-E522-4E95-A504-3F8A13035C2F"
    }
}
```



<h3 id="changePassword">change Password</h3>

> Content-type : application/json

```http
POST /users/changePassword
```

### Request
```json
{
	"email":"123123@gmail.com",
	"password":"123123",
    "newPassword":"123123123"
}
```

### Response
> Success : 200

```
{
    "status": 200,
    "message": "성공！"
}
```





<h2 id="email">email</h2>



<h3 id="emailSend">emailSend</h3>

> Content-type : application/json

```http
POST /sendEmail
```

### Request

```json
{
	"email": "123123@gmail.com",
	"myName" : "StudyTogether",
	"subject" : "이메일 인증",
	"text" : "인증번호를 입력해주세요"
}
```

### Response

> Success : 200

```json
{
    "status": 200,
    "message": "발신에 성공했습니다.",
    "data": {
        "state": true,
        "email": "123123@gmail.com",
        "sendTime": "2020-05-07 18:22:11"
    }
}
```



# 추후 추가 예정

