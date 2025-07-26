package org.example.controller;

import org.example.entity.BlogArticle;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.example.service.BlogArticleService;

import java.util.List;

@RestController
@RequestMapping("/api/articles")
public class BlogArticleController {
    @Autowired
    private BlogArticleService blogArticleService;

    @PostMapping("")
    public BlogArticle createArticle(@RequestBody BlogArticle article) {
        return blogArticleService.createArticle(article);
    }

    @PutMapping("")
    public BlogArticle updateArticle(@RequestBody BlogArticle article) {
        return blogArticleService.updateArticle(article);
    }

    @DeleteMapping("/{id}")
    public boolean deleteArticle(@PathVariable Long id) {
        return blogArticleService.deleteArticle(id);
    }

    @GetMapping("/{id}")
    public BlogArticle getArticleById(@PathVariable Long id) {
        return blogArticleService.getArticleById(id);
    }

    @GetMapping("")
    public List<BlogArticle> getAllArticles() {
        return blogArticleService.getAllArticles();
    }

    @GetMapping("/user/{userId}")
    public List<BlogArticle> getArticlesByUserId(@PathVariable Long userId) {
        return blogArticleService.getArticlesByUserId(userId);
    }
}

