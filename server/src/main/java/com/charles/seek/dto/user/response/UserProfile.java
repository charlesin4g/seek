package com.charles.seek.dto.user.response;

import lombok.Data;

@Data
public class UserProfile {
    private String userId;
    private String username;
    private String displayName;
    private String email;
    private String phone;
    private int sex;
    private String signature;
}
