package service;

import entity.BlogArticle;
import java.util.List;

public interface BlogArticleService {
    BlogArticle createArticle(BlogArticle article);
    BlogArticle updateArticle(BlogArticle article);
    boolean deleteArticle(Long id);
    BlogArticle getArticleById(Long id);
    List<BlogArticle> getAllArticles();
    List<BlogArticle> getArticlesByUserId(Long userId);
}

