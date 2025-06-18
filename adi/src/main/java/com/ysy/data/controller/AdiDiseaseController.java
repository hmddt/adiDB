package com.ysy.data.controller;

import cn.hutool.log.StaticLog;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.core.type.TypeReference;
import com.ysy.data.entity.adiDisease;
import com.ysy.data.entity.adigene;
import com.ysy.data.service.AdiDiseaseService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.data.redis.core.ValueOperations;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import java.util.List;



@CrossOrigin
@RequestMapping("/adidisease")
@RestController
@ResponseBody

public class AdiDiseaseController {

  @Resource
  AdiDiseaseService adiDiseaseService;

  @Autowired
  private StringRedisTemplate redisTemplate;
  private static final ObjectMapper objectMapper = new ObjectMapper();



  // 序列化 List<adigene>
  public static String serializeList(List<adiDisease> data) {
    try {
      return objectMapper.writeValueAsString(data);
    } catch (JsonProcessingException e) {
      throw new RuntimeException("序列化失败", e);
    }
  }

  // 反序列化 List<adigene>
  public static List<adiDisease> deserializeList(String data) {
    try {
      return objectMapper.readValue(data, new TypeReference<List<adiDisease>>() {});
    } catch (JsonProcessingException e) {
      throw new RuntimeException("反序列化失败", e);
    }
  }



  @GetMapping("/queryall")
  //分布式查询
//  这里不查询简介 因为简介太大 在点击的时候可以再单个查询
  public List<adiDisease> queryalladidiseasedata(){
    String cacheKey = "queryall:all";
    ValueOperations<String,String> valueOps = redisTemplate.opsForValue();
    String CacheData = valueOps.get(cacheKey);
    if(CacheData != null){
      StaticLog.info("脂肪因子疾病数据调用了Redis数据");
      List<adiDisease> alldata =  deserializeList(CacheData);
      return alldata.size() >10 ? alldata.subList(0,10) :alldata;
    }
    List<adiDisease> adiDisease = this.adiDiseaseService.queryalladidiseasedata();
    valueOps.set(cacheKey,serializeList(adiDisease));
    return adiDisease.size() >10 ? adiDisease.subList(0,10) :adiDisease;
  }
  @GetMapping("/queryall/full")
  //分布式查询
//  这里不查询简介 因为简介太大 在点击的时候可以再单个查询
  public List<adiDisease> queryalladidiseasedatafull(){
    String cacheKey = "queryall:all";
    ValueOperations<String,String> valueOps = redisTemplate.opsForValue();
    String CacheData = valueOps.get(cacheKey);
    if(CacheData != null){
      StaticLog.info("脂肪因子疾病数据调用了完整Redis数据");
      return deserializeList(CacheData);
    }
    List<adiDisease> adiDisease = this.adiDiseaseService.queryalladidiseasedata();
    valueOps.set(cacheKey,serializeList(adiDisease));
    return adiDisease;
  }

  @GetMapping("/refreshCache")
  public String refreshAllCache() {
    List<adiDisease> alladidis = this.adiDiseaseService.queryalladidiseasedata();
    ValueOperations<String,String> valueOps = redisTemplate.opsForValue();
    valueOps.set("queryall:all",serializeList(alladidis));
    return "脂肪因子文献基因Redis已更新";
  }

}
