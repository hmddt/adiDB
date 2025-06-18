package com.ysy.data.controller;

import com.ysy.data.entity.adiDisease;
import com.ysy.data.service.AdiDiseaseService;
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


  @GetMapping("/queryall")


//  这里不查询简介 因为简介太大 在点击的时候可以再单个查询
  public List<adiDisease> queryalladidiseasedata(){
    return adiDiseaseService.queryalladidiseasedata();
  }
}
