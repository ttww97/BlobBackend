package org.example.service.impl;

import org.example.entity.BlogArticle;
import org.example.mapper.BlogArticleMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.example.service.BlogArticleService;

import java.util.List;

@Service
public class BlogArticleServiceImpl implements BlogArticleService {
    @Autowired
    private BlogArticleMapper blogArticleMapper;

    @Override
    public BlogArticle createArticle(BlogArticle article) {
        blogArticleMapper.insertArticle(article);
        return article;
    }

    @Override
    public BlogArticle updateArticle(BlogArticle article) {
        blogArticleMapper.updateArticle(article);
        return article;
    }

    @Override
    public boolean deleteArticle(Long id) {
        return blogArticleMapper.deleteArticle(id) > 0;
    }

    @Override
    public BlogArticle getArticleById(Long id) {
        return blogArticleMapper.findById(id);
    }

    @Override
    public List<BlogArticle> getAllArticles() {
        return blogArticleMapper.findAll();
    }

    @Override
    public List<BlogArticle> getArticlesByUserId(Long userId) {
        return blogArticleMapper.findByUserId(userId);
    }
}

