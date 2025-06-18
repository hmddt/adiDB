package com.ysy.data.controller;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.core.type.TypeReference;

import cn.hutool.log.StaticLog;
import com.ysy.data.entity.adigene;
import com.ysy.data.service.adiService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.data.redis.core.ValueOperations;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import java.util.List;
import java.util.Objects;
import java.util.Set;
import java.util.stream.Collectors;

@CrossOrigin
@RequestMapping("/adi")
@RestController
@ResponseBody


public class adiController {

  @Resource adiService adiService;

  @Autowired
  private StringRedisTemplate  redisTemplate;

//  序列化和反序列化 Jackson实现
  private static final ObjectMapper objectMapper = new ObjectMapper();
  // 序列化 List<adigene>
  public static String serializeList(List<adigene> data) {
    try {
      return objectMapper.writeValueAsString(data);
    } catch (JsonProcessingException e) {
      throw new RuntimeException("序列化失败", e);
    }
  }

  // 反序列化 List<adigene>
  public static List<adigene> deserializeList(String data) {
    try {
      return objectMapper.readValue(data, new TypeReference<List<adigene>>() {});
    } catch (JsonProcessingException e) {
      throw new RuntimeException("反序列化失败", e);
    }
  }

  // 序列化 adigene
  public static String serializeAdigene(adigene data) {
    try {
      return objectMapper.writeValueAsString(data);
    } catch (JsonProcessingException e) {
      throw new RuntimeException("序列化失败", e);
    }
  }

  // 反序列化 adigene
  public static adigene deserializeAdigene(String data) {
    try {
      return objectMapper.readValue(data, adigene.class);
    } catch (JsonProcessingException e) {
      throw new RuntimeException("反序列化失败", e);
    }
  }

  // 序列化基因数组
  public static String serializeGeneArray(String[] data) {
    try {
      return objectMapper.writeValueAsString(data);
    } catch (JsonProcessingException e) {
      throw new RuntimeException("序列化失败", e);
    }
  }

  // 反序列化基因数组
  public static String[] deserializeGeneArray(String data) {
    try {
      return objectMapper.readValue(data, String[].class);
    } catch (JsonProcessingException e) {
      throw new RuntimeException("反序列化失败", e);
    }
  }


//  更新redis数据
  @GetMapping("/refreshCache")
  public String refreshAllCache() {
    List<adigene> alladi = this.adiService.queryalladi();
    List<adigene> allToAbstract = this.adiService.queryalladitoabstract();
    ValueOperations<String,String> valueOps = redisTemplate.opsForValue();

    valueOps.set("adi:all", serializeList(alladi));
    valueOps.set("allToAbstract:all", serializeList(allToAbstract));

    return "Redis缓存已更新";
  }


  @GetMapping("/all")
  public List<adigene> queryalladi(){
    String cacheKey = "adi:all"; //缓存的key
    ValueOperations<String,String> valueOps = redisTemplate.opsForValue();
    String cacheData = valueOps.get(cacheKey);
    if (cacheData != null){
      //如果有缓存数据 直接返回
      StaticLog.info("调用了Redis数据");
      return deserializeList(cacheData);
    }

    List<adigene> alladi = this.adiService.queryalladi();
    valueOps.set(cacheKey,serializeList(alladi));// 没有则存入redis
    return alladi;
  }


//  调取所有资源太慢，选择除了abstract以外内容调取资源  先加载10条数据
  @GetMapping("/allToAbstract")
  public List<adigene> queryalladitoabstract(){
    String cacheKey = "allToAbstract:all";
    ValueOperations<String,String> valueOps = redisTemplate.opsForValue();
    String cacheData = valueOps.get(cacheKey);
    if (cacheData != null){
      //如果有缓存数据 直接返回

      List<adigene> allData = deserializeList(cacheData);
      StaticLog.info("调用了Redis数据中allToAbstract数据/10条");
//      return allData;
      return allData.size() >10 ? allData.subList(0,10) :allData ;
    }

    List<adigene> allToAbstract = this.adiService.queryalladitoabstract();
    valueOps.set(cacheKey,serializeList(allToAbstract));
    return allToAbstract.size() >10 ? allToAbstract.subList(0,10) :allToAbstract ;
  }
  @GetMapping("/allToAbstract/full")
  public List<adigene> queryalladitoabstractFull(){
    String cacheKey = "allToAbstract:all";
    ValueOperations<String,String> valueOps = redisTemplate.opsForValue();
    String cacheData = valueOps.get(cacheKey);
    if (cacheData != null){
      //如果有缓存数据 直接返回

      List<adigene> allData = deserializeList(cacheData);
      StaticLog.info("调用了Redis数据中allToAbstract数据");
//      return allData;
      return allData;
    }

    List<adigene> allToAbstract = this.adiService.queryalladitoabstract();
    valueOps.set(cacheKey,serializeList(allToAbstract));
    return allToAbstract ;
  }


  @GetMapping("/gene")
  public String[] queryByAllGene() {
    List<adigene> alladi = this.adiService.queryalladi();

    Set<String> geneSet = alladi.stream()
      .map(adigene::getGene)
      .filter(Objects::nonNull)
      .map(String::toUpperCase)
      .collect(Collectors.toSet());
    return geneSet.toArray(new String[0]);
  }


  //使用id进行检索
  @GetMapping("/use/{id}")
  public ResponseEntity<adigene> queryById(@PathVariable("id") String id) {

    return ResponseEntity.ok(this.adiService.queryById(id));
  }

  @GetMapping("/usegene/{gene}")
  public ResponseEntity<adigene> queryByGene(@PathVariable("gene") String gene){
    return ResponseEntity.ok(this.adiService.queryByGene(gene));
  }
}
