package com.ysy.data.controller;

import com.ysy.data.entity.ObesityDataset;
import com.ysy.data.service.ObesityDataSetService;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import java.util.List;

@CrossOrigin
@RequestMapping("/odc")
@RestController
@ResponseBody
public class ObesityDatasetController {

  @Resource  ObesityDataSetService obesityDataSetService;

  @GetMapping("alldata")
  public List<ObesityDataset> queryallodcdata(){return this.obesityDataSetService.queryallodcdata();}


}
