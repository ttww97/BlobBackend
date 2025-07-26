package org.example.entity;

import lombok.Data;

import java.util.Date;

@Data
public class BlogArticle {
    private Long id;
    private Long userId;
    private String title;
    private String content;
    private Date createdAt;
    private Date updatedAt;
}

