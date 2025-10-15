package com.charles.seek.service;

import com.charles.seek.dto.user.response.UserProfile;

public interface UserService {

    boolean checkPassword(String username, String password);

    UserProfile getByUsername(String username);
}
