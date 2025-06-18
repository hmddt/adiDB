package com.ysy.data.controller;

import cn.hutool.log.StaticLog;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.ysy.data.entity.TF2TG;
import java.util.Map;
import java.util.HashMap;
import java.util.Set;
import java.util.stream.Stream;
import java.util.stream.Collectors;
import java.time.Duration;
import com.ysy.data.entity.adigene;
import com.ysy.data.service.TF2TGService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.data.redis.core.ValueOperations;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import java.util.List;

@CrossOrigin
@RequestMapping("/TF2TG")
@RestController
@ResponseBody

public class TF2TGController {

  @Resource
  TF2TGService tf2TGService;

  @Autowired
  private StringRedisTemplate redisTemplate;

  private static final ObjectMapper objectMapper = new ObjectMapper();


  public static String serializeList(List<TF2TG> data) {
    try {
      return objectMapper.writeValueAsString(data);
    } catch (JsonProcessingException e) {
      throw new RuntimeException("序列化失败", e);
    }
  }

  // 反序列化 List<adigene>
  public static List<TF2TG> deserializeList(String data) {
    try {
      return objectMapper.readValue(data, new TypeReference<List<TF2TG>>() {});
    } catch (JsonProcessingException e) {
      throw new RuntimeException("反序列化失败", e);
    }
  }
  private String serializeMap(Map<String, Object> map) {
    try {
      ObjectMapper objectMapper = new ObjectMapper();
      return objectMapper.writeValueAsString(map);
    } catch (Exception e) {
      e.printStackTrace();
      return null;
    }
  }

  private Map<String, Object> deserializeMap(String json) {
    try {
      ObjectMapper objectMapper = new ObjectMapper();
      return objectMapper.readValue(json, new TypeReference<Map<String, Object>>() {});
    } catch (Exception e) {
      e.printStackTrace();
      return null;
    }
  }



  @GetMapping("/alltfdatahomo")
  public List<TF2TG> queryalltfgene(){
    String cachekey = "TF2TG:all";
    ValueOperations<String,String> valueOps = redisTemplate.opsForValue();
    String Cachedata = valueOps.get(cachekey);
    if( Cachedata != null){
      StaticLog.info("调用了TF的Redis数");
      return deserializeList(Cachedata);
    }

    List<TF2TG> allTF  = this.tf2TGService.queryalltfgene();
    valueOps.set(cachekey,serializeList(allTF));
    return allTF;
  }


}
