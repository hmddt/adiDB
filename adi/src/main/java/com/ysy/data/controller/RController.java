package com.ysy.data.controller;

import cn.hutool.cache.Cache;
import cn.hutool.cache.CacheUtil;
import com.ysy.data.service.RService;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;

@CrossOrigin//允许跨域
@RequestMapping("/r")
@RestController
public class RController {

  @Resource
  private RService rService;

  private static final Cache<String, String> imgCache = CacheUtil.newFIFOCache(1000);
  //缓存工具

  @GetMapping("/diff/{gene}")
  public String getcheckpoint(@PathVariable String gene){
    String imgEncode;
    String key =  gene + "_mRNA";
    if (imgCache.containsKey(key)){
      imgEncode = imgCache.get(key);
    }else {
      imgEncode =rService.drawcheckpoint(gene);
      imgCache.put(gene,imgEncode);
    }
    return imgEncode;
  }


  @GetMapping("/tissueExpression/{gene}")
  public  String drawTissueExpression(@PathVariable String gene){
    String imgEncode;
    String key =  "Expression_" +  gene;
    if (imgCache.containsKey(key)){
      imgEncode = imgCache.get(key);
    }else {
      imgEncode =rService.drawTissueExpression(gene);
      imgCache.put(gene,imgEncode);
    }
    return imgEncode;
  }





}
