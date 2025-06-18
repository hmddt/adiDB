package com.ysy.data.controller;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.ysy.data.entity.ncRNAdata;
import com.ysy.data.service.NcRNAdataService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.data.redis.core.ValueOperations;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import java.util.List;

@CrossOrigin
@RestController
@RequestMapping("/ncrna")
@Slf4j
public class NcRNAdataController {

  @Resource
  private NcRNAdataService ncRNAdataService;

  @Autowired
  private StringRedisTemplate redisTemplate;

  private static final ObjectMapper objectMapper = new ObjectMapper();

  // 序列化 List
  private static String serializeList(List<ncRNAdata> data) {
    try {
      return objectMapper.writeValueAsString(data);
    } catch (JsonProcessingException e) {
      throw new RuntimeException("序列化失败", e);
    }
  }

  private static List<ncRNAdata> deserializeList(String json) {
    try {
      return objectMapper.readValue(json, new TypeReference<List<ncRNAdata>>() {});
    } catch (JsonProcessingException e) {
      throw new RuntimeException("反序列化失败", e);
    }
  }

  // 刷新缓存
  @GetMapping("/refreshCache")
  public String refreshCache() {
    List<ncRNAdata> all = ncRNAdataService.queryAllNcRNAdata();
    List<ncRNAdata> brief = ncRNAdataService.queryBriefNcRNAdata();

    ValueOperations<String, String> ops = redisTemplate.opsForValue();
    ops.set("ncrna:all", serializeList(all));
    ops.set("ncrna:brief", serializeList(brief));

    return "Redis 缓存刷新成功 ✅";
  }

  // 查询全部数据（优先从缓存）
  @GetMapping("/all")
  public List<ncRNAdata> getAll() {
    String cacheKey = "ncrna:all";
    ValueOperations<String, String> ops = redisTemplate.opsForValue();
    String cache = ops.get(cacheKey);

    if (cache != null) {
      log.info("使用 Redis 缓存：/all");
      return deserializeList(cache);
    }

    List<ncRNAdata> data = ncRNAdataService.queryAllNcRNAdata();
    ops.set(cacheKey, serializeList(data));
    return data;
  }

  // 查询精简数据（前10条）
  @GetMapping("/brief")
  public List<ncRNAdata> getBriefTop10() {
    String cacheKey = "ncrna:brief";
    ValueOperations<String, String> ops = redisTemplate.opsForValue();
    String cache = ops.get(cacheKey);

    if (cache != null) {
      log.info("使用 Redis 缓存：/brief");
      List<ncRNAdata> data = deserializeList(cache);
      return data.size() > 10 ? data.subList(0, 10) : data;
    }

    List<ncRNAdata> data = ncRNAdataService.queryBriefNcRNAdata();
    ops.set(cacheKey, serializeList(data));
    return data.size() > 10 ? data.subList(0, 10) : data;
  }

  @GetMapping("/brief/full")
  public List<ncRNAdata> getBriefFull() {
    String cacheKey = "ncrna:brief";
    ValueOperations<String, String> ops = redisTemplate.opsForValue();
    String cache = ops.get(cacheKey);

    if (cache != null) {
      log.info("使用 Redis 缓存：/brief/full");
      return deserializeList(cache); // ✅ 返回全部数据
    }

    List<ncRNAdata> data = ncRNAdataService.queryBriefNcRNAdata();
    ops.set(cacheKey, serializeList(data));
    return data;
  }

  // 查询全部基因名（用于下拉列表）
  @GetMapping("/genes")
  public String[] getGeneList() {
    List<ncRNAdata> list = ncRNAdataService.queryAllNcRNAdata();
    String[] genes = new String[list.size()];
    for (int i = 0; i < list.size(); i++) {
      genes[i] = list.get(i).getGene();
    }
    return genes;
  }

  // 查询单个基因记录
  @GetMapping("/gene/{gene}")
  public ResponseEntity<ncRNAdata> getByGene(@PathVariable String gene) {
    return ResponseEntity.ok(ncRNAdataService.queryByncRNA(gene));
  }
}
