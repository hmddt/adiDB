package com.ysy.data.controller;

import com.baomidou.mybatisplus.annotation.TableName;
import org.springframework.web.bind.annotation.*;
import com.ysy.data.entity.synlethalitydata;
import com.ysy.data.service.synlethalityService;

import javax.annotation.Resource;
import java.util.*;
import java.util.stream.Collectors;
import java.util.stream.Stream;

@CrossOrigin
@RequestMapping("/sl")
@RestController
@ResponseBody


public class synlethalityController {
  @Resource synlethalityService synlethalityService;

  @GetMapping("/all")
  public List<synlethalitydata> queryallsldata(){
    return this.synlethalityService.queryallsldata();
  };

  //示例ABCC4
  @GetMapping("/gene/{sample}")
  public Map<String, Object> queryByGene(@PathVariable("sample") String sample) {
    // 查询的所有结果一共6千多条(只用申请一次全部查询,减少服务器压力)
    List<synlethalitydata> allSLData = this.synlethalityService.queryallsldata();

    // 获取 geneA 和 geneB 是关联节点的数据
    List<synlethalitydata> resultSLData = this.synlethalityService.queryByGene(sample);

    // 使用 Map 去重，key 为 GeneA-GeneB 的组合（保持一致性，排序后拼接）
    Map<String, synlethalitydata> uniqueDataMap = new HashMap<>();

    for (synlethalitydata data : resultSLData) {
      // 对 GeneA 和 GeneB 进行排序，确保 "A-B" 和 "B-A" 被视为同一对
      String key = Stream.of(data.getGeneA(), data.getGeneB())
        .sorted()
        .collect(Collectors.joining("-"));

      if (uniqueDataMap.containsKey(key)) {
        // 如果已经存在，合并 PMID
        synlethalitydata existingData = uniqueDataMap.get(key);
        String existingPMID = existingData.getPMID();
        String newPMID = data.getPMID();

        // 合并 PMID，避免重复
        Set<String> pmidSet = new LinkedHashSet<>();
        if (existingPMID != null) pmidSet.addAll(Arrays.asList(existingPMID.split(",")));
        if (newPMID != null) pmidSet.addAll(Arrays.asList(newPMID.split(",")));

        existingData.setPMID(String.join(",", pmidSet));
      } else {
        // 如果不存在，直接放入 map
        uniqueDataMap.put(key, data);
      }
    }
//    将筛选的去重结果分节点


    Map<String, Object> response = new HashMap<>();
//    response.put("totalRecords", resultSLData.size());
//    response.put("uniqueRecords", uniqueDataMap.size());
    response.put("uniqueData", new ArrayList<>(uniqueDataMap.values()));
//    response.put("rawData", resultSLData);

    return response;
  }



}
