package com.ysy.data.controller;

import com.ysy.data.entity.TF2TG;
import com.ysy.data.service.TF2TGService;
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

  @GetMapping("/alltfdatahomo")
  public List<TF2TG> queryalltfgene(){return this.tf2TGService.queryalltfgene();}
}
