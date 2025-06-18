package com.ysy.data.controller;

import cn.hutool.log.StaticLog;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.ysy.data.entity.adigene;
import com.ysy.data.service.DrugInteractionsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.data.redis.core.ValueOperations;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import com.ysy.data.entity.DrugInteractionsDrug;

import javax.annotation.Resource;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

@CrossOrigin
@RequestMapping("/DrugInteractions")
@RestController
@ResponseBody

public class DrugInteractionsController {

  @Resource
  DrugInteractionsService drugInteractionsService;

  @Autowired
  private StringRedisTemplate redisTemplate;

  private static final ObjectMapper objectMapper = new ObjectMapper();

  public static String serializeList(List<DrugInteractionsDrug> data) {
    try {
      return objectMapper.writeValueAsString(data);
    } catch (JsonProcessingException e) {
      throw new RuntimeException("序列化失败", e);
    }
  }
  public static List<DrugInteractionsDrug> deserializeList(String data) {
    try {
      return objectMapper.readValue(data,new TypeReference<List<DrugInteractionsDrug>>() {});
    } catch (JsonProcessingException e) {
      throw new RuntimeException("反序列化失败", e);
    }
  }



  @GetMapping("/Gene/{gene}")
  public List<DrugInteractionsDrug> QueryDrugInteractionsGene(@PathVariable("gene") String gene){
    String cacheKey = "drugInteractions:"+gene; //缓存的key
    ValueOperations<String,String> valueOps = redisTemplate.opsForValue();
    String cacheData = valueOps.get(cacheKey);
    if (cacheData != null){
      //如果有缓存数据 直接返回
      StaticLog.info("调用了这个"+gene+"的Redis数据");
      List<DrugInteractionsDrug> cachedResult = deserializeList(cacheData);
      return cachedResult;
    }
    // 如果缓存没有命中，查询数据库
    List<DrugInteractionsDrug> result = drugInteractionsService.QueryDrugInteractionsGene(gene);
    result = result.stream()
      .filter(item -> item.getInteractionScore() != null &&
        !item.getInteractionScore().equalsIgnoreCase("NULL"))
      .collect(Collectors.toList());


    if (result == null) {
      return Collections.emptyList();
    }

    // 写入缓存（可设置过期时间）
    try {
      valueOps.set(cacheKey, serializeList(result));
    } catch (Exception e) {
      StaticLog.warn("Redis 写入失败，不影响返回");
    }
    return result;
  }

  @DeleteMapping("/cache/{key}")
  public ResponseEntity<String> deleteCacheByKey(@PathVariable("key") String key) {
    String fullKey = "drugInteractions:" + key;  // 根据你的命名规则构建完整的 Redis key
    Boolean result = redisTemplate.delete(fullKey);

    if (Boolean.TRUE.equals(result)) {
      StaticLog.info("已删除 Redis 缓存: {}", fullKey);
      return ResponseEntity.ok("缓存已删除: " + fullKey);
    } else {
      StaticLog.warn("未找到 Redis 缓存: {}", fullKey);
      return ResponseEntity.ok("未找到缓存或删除失败: " + fullKey);
    }
  }

}
