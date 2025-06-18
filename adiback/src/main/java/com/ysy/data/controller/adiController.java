package com.ysy.data.controller;

import cn.hutool.log.StaticLog;
import com.ysy.data.entity.adigene;
import com.ysy.data.service.adiService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import java.util.List;

@CrossOrigin
@RequestMapping("/adi")
@RestController
@ResponseBody
public class adiController {

  @Resource adiService adiService;

  @GetMapping("/all")
  public List<adigene> queryalladi(){return this.adiService.queryalladi();}


//  调取所有资源太慢，选择除了abstract以外内容调取资源
  @GetMapping("/allToAbstract")
  public List<adigene> queryalladitoabstract(){
    return this.adiService.queryalladitoabstract();
  }


  @GetMapping("/gene")
  public String[] queryByAllGene(){
    List<adigene> alladi=this.adiService.queryalladi();
      String[] gene = new String[alladi.size()];
      for (int i = 0; i < alladi.size(); i++)
      {
        gene[i] = alladi.get(i).getGene();}
      return gene;
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
