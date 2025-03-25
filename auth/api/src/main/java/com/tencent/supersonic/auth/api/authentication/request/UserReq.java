package com.tencent.supersonic.auth.api.authentication.request;


import lombok.Data;

@Data
public class UserReq {

    private String name;

    private String password;

    private String newPassword;

    private String authKey;
}
