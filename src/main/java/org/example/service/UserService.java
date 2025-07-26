package org.example.service;

import org.example.entity.User;
import java.util.List;

public interface UserService {
    User register(User user);
    User login(String username, String password);
    List<User> getAllUsers();
    User getUserById(Long id);
    User updateUser(User user);
}

