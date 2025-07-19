package org.example.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.SQLException;

@Configuration
public class DatabaseConfig {

    @Autowired
    private DataSource dataSource;

    @Bean
    public CommandLineRunner databaseConnectionTest() {
        return args -> {
            System.out.println("=== 数据库连接测试 ===");
            try (Connection connection = dataSource.getConnection()) {
                System.out.println("✅ 数据库连接成功！");
                System.out.println("   数据库URL: " + connection.getMetaData().getURL());
                System.out.println("   数据库产品: " + connection.getMetaData().getDatabaseProductName());
                System.out.println("   数据库版本: " + connection.getMetaData().getDatabaseProductVersion());
                System.out.println("   用户名: " + connection.getMetaData().getUserName());
            } catch (SQLException e) {
                System.err.println("❌ 数据库连接失败！");
                System.err.println("   错误信息: " + e.getMessage());
                throw e;
            }
            System.out.println("===================");
        };
    }
} 