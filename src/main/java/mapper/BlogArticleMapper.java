package mapper;

import entity.BlogArticle;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface BlogArticleMapper {
    BlogArticle findById(@Param("id") Long id);
    List<BlogArticle> findByUserId(@Param("userId") Long userId);
    List<BlogArticle> findAll();
    int insertArticle(BlogArticle article);
    int updateArticle(BlogArticle article);
    int deleteArticle(@Param("id") Long id);
}

