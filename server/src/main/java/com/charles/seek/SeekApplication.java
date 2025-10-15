package com.charles.seek;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

@SpringBootApplication
@EntityScan("com.charles.seek.model")
@EnableJpaRepositories("com.charles.seek.repository")
@ComponentScan(basePackages = "com.charles.seek")
public class SeekApplication {

    public static void main(String[] args) {
        SpringApplication.run(SeekApplication.class, args);
    }

}
