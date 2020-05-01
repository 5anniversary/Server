## API Instructions

[User](API.md/#User)

- [x] [register](API.md/#register)
- [x] [login](API.md/#login)
- [x] [change password](API.md/#changepassword)
- [x] [get user info ](API.md/#getuserinfo)
- [x] [modify user info ](API.md/#modifyuserinfo)
- [x] [logout ](API.md/#logout)

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
	"account":"asdf123",
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
	"account":"asdf123",
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
	"account":"asdf123",
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

# 추후 추가 예정

