package com.ysy.data;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@MapperScan("com.ysy.data.dao")
public class DataApplication {

  public static void main(String[] args) {
    SpringApplication.run(DataApplication.class, args);
  }

}
