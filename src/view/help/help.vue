<template>
  <div class="help" style="position: relative">
    <div class="help-container">
      <div class="sidebar" >
        <el-menu
          default-active="1-0"
          background-color="#f4f4f5"
          text-color="#333"
          active-text-color="#409eff"
          @select="handleMenuSelect"
        style="max-height: 1100px">
          <el-menu-item :index= 0 style="font-weight: bold;font-size: 18px;color: #051d31;height: 50px; display: flex; align-items: center;">  1.  Introduction</el-menu-item>
          <el-menu-item :index= 1 style="font-weight: bold;font-size: 18px;color: #051d31;height: 50px; display: flex; align-items: center;">  2. Browser</el-menu-item>
          <el-menu-item :index =1.1 style="margin-left: 10px;font-size: 15px;height: 40px; display: flex; align-items: center;"> 2.1 Gene </el-menu-item>
          <el-menu-item :index =1.2 style="margin-left: 10px;font-size: 15px;height: 40px; display: flex; align-items: center;"> 2.2 ncRNA </el-menu-item>
          <el-menu-item :index =1.3 style="margin-left: 10px;font-size: 15px;height: 40px; display: flex; align-items: center;"> 2.3 Gene-Disease </el-menu-item>
          <el-menu-item :index =1.4 style="margin-left: 10px;font-size: 15px;height: 40px; display: flex; align-items: center;"> 2.4 Dataset </el-menu-item>
          <el-menu-item :index= 2 style="font-weight: bold;font-size: 18px;color: #051d31;height: 50px; display: flex; align-items: center;">  3. Analysis</el-menu-item>
          <el-menu-item :index= 2.1 style="margin-left: 10px;font-size: 15px;height: 40px; display: flex; align-items: center;">3.1  mRNA Expression</el-menu-item>
          <el-menu-item :index= 2.2 style="margin-left: 10px;font-size: 15px;height: 40px;display: flex; align-items: center;">3.2  Survival</el-menu-item>
          <el-menu-item :index= 2.4 style="margin-left: 10px;font-size: 16px;height: 40px; display: flex; align-items: center;">3.3  Copy Number Variation</el-menu-item>
<!--          <el-menu-item :index= 2.5 style="margin-left: 10px;font-size: 16px;height: 40px; display: flex; align-items: center;">3-5  Mutation</el-menu-item>-->
          <el-menu-item :index= 2.6 style="margin-left: 10px;font-size: 16px;height: 40px; display: flex; align-items: center;">3.4  DNA Methylation</el-menu-item>
          <el-menu-item :index= 3 style="font-weight: bold;font-size: 18px;color: #051d31;height: 50px; display: flex; align-items: center;">4. Immune</el-menu-item>
          <el-menu-item :index= 2.3 style="margin-left: 10px;font-size: 16px;height: 40px; display: flex; align-items: center;">4.1  ssGSEA</el-menu-item>
          <el-menu-item :index= 3.1 style="margin-left: 10px;font-size: 16px;height: 40px; display: flex; align-items: center;">4.2  Checkpoint</el-menu-item>
          <el-menu-item :index= 3.2 style="margin-left: 10px;font-size: 16px;height: 40px; display: flex; align-items: center;">4.3  Chemokine</el-menu-item>
          <el-menu-item :index= 3.3 style="margin-left: 10px;font-size: 16px;height: 40px; display: flex; align-items: center;">4.4  Receptor</el-menu-item>
          <el-menu-item :index= 3.4 style="margin-left: 10px;font-size: 16px;height: 40px; display: flex; align-items: center;">4.5  Immune Stimulator</el-menu-item>
          <el-menu-item :index= 3.5 style="margin-left: 10px;font-size: 16px;height: 40px; display: flex; align-items: center;">4.6  Immune Inhibitor</el-menu-item>
<!--          <el-menu-item :index= 3.6 style="margin-left: 10px;font-size: 16px;height: 40px; display: flex; align-items: center;">4-6  Immune Score</el-menu-item>-->
<!--          <el-menu-item :index= 3.7 style="margin-left: 10px;font-size: 16px;height: 40px; display: flex; align-items: center;">4-7  Immune Cell</el-menu-item>-->
          <el-menu-item :index= 4 style="font-weight: bold;font-size: 18px;color: #051d31;height: 50px; display: flex; align-items: center;">5. Drug</el-menu-item>
          <el-menu-item :index= 4.1 style="margin-left: 10px;font-size: 16px;height: 40px; display: flex; align-items: center;">5.1  Drug Relevance</el-menu-item>
          <el-menu-item :index= 4.2 style="margin-left: 10px;font-size: 16px;height: 40px; display: flex; align-items: center;">5.2  Drug Pathway</el-menu-item>
          <el-menu-item :index= 5 style="font-weight: bold;font-size: 18px;color: #051d31;height: 50px; display: flex; align-items: center;">6. Network</el-menu-item>
          <el-menu-item :index =5.1 style="margin-left: 10px;font-size: 15px;height: 40px; display: flex; align-items: center;"> 6.1 TF-gene Network </el-menu-item>
          <el-menu-item :index =5.2 style="margin-left: 10px;font-size: 16px;height: 40px; display: flex; align-items: center;"> 6.2 ncRNA-gene Network </el-menu-item>
          <el-menu-item :index =5.3 style="margin-left: 10px;font-size: 16px;height: 40px; display: flex; align-items: center;"> 6.3 Synthetic Lethality Network </el-menu-item>
          <el-menu-item :index= 7 style="font-weight: bold;font-size: 18px;color: #051d31;height: 50px; display: flex; align-items: center;">7. Evolution</el-menu-item>
          <el-menu-item :index= 6 style="font-weight: bold;font-size: 18px;color: #051d31;height: 50px; display: flex; align-items: center;">8. Others</el-menu-item>
        </el-menu>
      </div>
      <el-card class="content-wrapper">
        <div class="content">
          <el-card id="introduction" >
            <!--introduction页面-->
            <span style="font-weight: bold;font-size: 24px">1. Introduction</span>
            <el-divider></el-divider>
            <p style="font-size: 17px">

              <span style="color: #3a8ee6; font-weight: bold;">Adipokines</span> released by adipose tissue,
              have a critical role in multiple biological processes, physiological
              and pathophysiological processes. AdipokineDis, focusing on adipokines
              and diseases based on the molecular features of adipokines, especially
              for canonical and novel adipokines (ncRNAs), provides insights into disease
              progression and therapeutic potential, aiming to accelerate drug development
              and facilitate personalized treatment strategies based on adipokine profiles.
            </p>
          </el-card>
          <br>
          <el-card id="summary">
            <!--summary页面-->
            <span style="font-weight: bold;font-size: 24px">2. Browser</span>
            <el-divider></el-divider>
            <p>
              In the
              <span style="font-weight: bold;color: #3a8ee6">Browser
            </span>
              module, you can browse data from <span style="font-weight: bold;color: #3a8ee6">Gene ,</span>
              <span style="font-weight: bold;color: #3a8ee6">ncRNA ,</span>
              <span style="font-weight: bold;color: #3a8ee6">obesity-related diseases and</span> <span style="font-weight: bold;color: #3a8ee6"> obesity dataset</span>.
            </p>
            <br>
            <el-card id="Gene" style="width: 98%;cursor: pointer" >
              <span style="font-weight: bold;font-size: 20px;color: #55475b" @click="gene = !gene">2.1  Gene</span>
              <div v-show="gene">
                <el-divider></el-divider>
                <p >In the Gene section, we present the Adipokines related genes that we have collected and organized.</p>
                <br>
                <div >
                  <img v-lazy="'http://tmliang.cn/pic/adi/help/Browser/Browser-Gene.png'" style="width: 100%">
                </div>

              </div>

            </el-card>
            <br>
            <el-card id="ncRNA" style="width: 98%;cursor: pointer" >
              <span style="font-weight: bold;font-size: 20px;color: #55475b" @click="ncRNA = !ncRNA">2.2  ncRNA</span>
              <div v-show="ncRNA">
                <el-divider></el-divider>
                <p >In the ncRNA section, we present the Adipokines related ncRNAs that we have collected and organized.</p>
                <br>
                <div >
                  <img v-lazy="'http://tmliang.cn/pic/adi/help/Browser/Broese-ncRNA.png'" style="width: 100%">
                </div>

              </div>

            </el-card>
            <br>
            <el-card id="Disease" style="width: 98%;cursor: pointer" >
              <span style="font-weight: bold;font-size: 20px;color: #55475b" @click="Disease = !Disease">2.3 Gene-Disease</span>
              <div v-show="Disease">
                <el-divider></el-divider>
                <p >In the gene-disease section, we present the diseases and literature related to adipokines that we have collected and organized.</p>
                <br>
                <div >
                  <img v-lazy="'http://tmliang.cn/pic/adi/help/Browser/Browse-Disease1.png'" style="width: 100%">
                </div>
                <div >
                  <img v-lazy="'http://tmliang.cn/pic/adi/help/Browser/Browse-Disease2.png'" style="width: 100%">
                </div>

              </div>

            </el-card>
            <br>
            <el-card id="Dataset" style="width: 98%;cursor: pointer" >
              <span style="font-weight: bold;font-size: 20px;color: #55475b" @click="Dataset = !Dataset">2.4  Dataset</span>
              <div v-show="Dataset">
                <el-divider></el-divider>
                <p >In the Dataset section, we present the Obesity Related Datasets that we have collected and organized.</p>
                <br>
                <div >
                  <img v-lazy="'http://tmliang.cn/pic/adi/help/Browser/Browse-Dataset.png'" style="width: 100%">
                </div>

              </div>

            </el-card>


<!--            <div>-->
<!--              <el-card >-->
<!--                <img src="../../assets/help/summary/browser1.png" style="width: 100%">-->
<!--              </el-card>-->
<!--              <br>-->
<!--              &lt;!&ndash;            <p>-->
<!--                            As shown in the figure below, the following figure shows the detailed information of the example gene, you can click the hyperlink button to view more literature information of this gene in detail.-->
<!--                          </p>&ndash;&gt;-->
<!--              <el-card >-->
<!--                <img src="../../assets/help/summary/list.png"  style="width: 100%">-->
<!--              </el-card>-->

<!--            </div>-->

          </el-card>
          <br>
          <el-card id="analysis">
            <span style="font-weight: bold;font-size: 24px">3. Analysis</span>
            <el-divider></el-divider>
            <p>In the
              <span style="color: #3a8ee6;font-weight: bold">analysis
            </span>
              module, data from multi-omics analyses of genes on pan-cancer are presented.This module has six elements, which are mRNA Expression， Survival， ssGSEA，Copy Number Variation，Mutation and DNA Methylation.</p>
           <br>
            <img v-lazy="'http://tmliang.cn/pic/adi/help/Analysis/Analysis-Con1.png'" style="width: 100%">
            <br>
            <el-card id="expression" style="width: 98%;cursor: pointer" >
              <span style="font-weight: bold;font-size: 20px;color: #55475b" @click="expression = !expression">3.1  mRNA Expression</span>
              <div v-show="expression">
                <el-divider></el-divider>
                <p >This section demonstrates the Log2FC for mRNA differential expression analysis. You can enter or do a fuzzy search for the genes we have in our library to get the results.</p>
                <br>
                <div >
                  <img v-lazy="'http://tmliang.cn/pic/adi/help/Analysis/Analysis-Expression.png'" style="width: 100%">
                </div>

              </div>

            </el-card>
            <br>
            <el-card id="Survival" style="width: 98%;cursor: pointer">
              <span style="font-size: 20px;font-weight: bold;color: #55475b" @click="survival = !survival">3.2  Survival</span>
              <div v-show="survival">
                <el-divider></el-divider>
                <p>This section shows the results of the survival analysis. You can enter the cancer type and the gene you are interested in or perform a fuzzy search on genes in our library to get results.</p>
                <br>
                <div>

                  <img v-lazy="'http://tmliang.cn/pic/adi/help/Analysis/Analysis-Surv.png'" style="width: 100%">
                </div>

              </div>

            </el-card>
            <br>
            <el-card id="CNV" style="width: 98%;cursor: pointer">
              <span style="font-size: 20px;font-weight: bold ;color: #55475b" @click="cnv = !cnv">3.4  Copy Number Variation</span>
              <div v-show="cnv">
                <el-divider></el-divider>
                <p>This section displays the results for copy number variation. You can enter the gene you are interested in or perform a fuzzy search on genes in our library to get results</p>
                <br>
                <div>

                  <img v-lazy="'http://tmliang.cn/pic/adi/help/Analysis/Analysis-CNV.png'" style="width: 100%">
                </div>

              </div>


            </el-card>
<!--            <br>-->
<!--            <el-card id="MUT" style="width: 98%;cursor: pointer">-->
<!--              <span style="font-size: 20px;font-weight: bold;color: #55475b" @click="Mutation = !Mutation">3.5  Mutation</span>-->
<!--              <div v-show="Mutation">-->
<!--                <el-divider></el-divider>-->
<!--                <p>This section shows the results of gene mutation.You can enter the gene you are interested in or perform a fuzzy search on genes in our library to get results</p>-->
<!--               <br>-->
<!--                <el-card>-->
<!--                  <img src="../../assets/help/anslysis/mut.png" style="width: 100%">-->
<!--                </el-card>-->

<!--              </div>-->

<!--            </el-card>-->
            <br>
            <el-card id="METHY" style="width: 98%;cursor: pointer">
              <span style="font-size: 20px;font-weight: bold;color: #55475b" @click="Methylation = !Methylation">3.6  DNA Methylation</span>
              <div v-show="Methylation">
                <el-divider></el-divider>
                <p>This section shows the results of dna methylation.You can enter the gene you are interested in or perform a fuzzy search on genes in our library to get results</p>
                <br>
                <div>

                  <img v-lazy="'http://tmliang.cn/pic/adi/help/Analysis/Analysis-Methy.png'" style="width: 100%">
                </div>

              </div>

            </el-card>
            <br>
          </el-card>
          <br>
          <el-card id="immune">
            <span style="font-weight: bold;font-size: 24px">4. Immune</span>
            <el-divider></el-divider>
            <p>The
              <span style="font-weight: bold;color: #3a8ee6">Immunity
              </span>
              Module presents the results of multi-omics data and immune correlation analysis of relevant regulatory factors. This interface provides a total of seven types of immune correlation analysis, you can choose the corresponding module according to the needs of the analysis results, different analysis modules correspond to the functions and analysis results are as follows.</p>
           <br>
            <img v-lazy="'http://tmliang.cn/pic/adi/help/Immune/Immune-Con1.png'" style="width: 100%">

            <el-card id="GSEA" style="width: 98%;cursor: pointer">
              <span style="font-size: 20px;font-weight: bold;color: #55475b" @click="gsea =!gsea">3.3  ssGSEA</span>
              <div v-show="gsea">
                <el-divider></el-divider>
                <p>This section shows the results of the ssGSEA analysis. You can enter the cancer type and the gene you are interested in or perform a fuzzy search on genes in our library to get results.</p>
                <br>
                <div>
                  <img v-lazy="'http://tmliang.cn/pic/adi/help/Analysis/Analysis-Surv.png'" style="width: 100%">
                </div>

              </div>

            </el-card>
            <br>
            <el-card id="checkpoint" style="width: 98%;cursor: pointer">
              <span style="font-weight: bold;font-size: 20px;color: #55475b" @click="checkpoint = !checkpoint"> 4.1  Checkpoint</span>
              <div v-show="checkpoint">
                <el-divider></el-divider>
                <p>In this section, you can enter a
                  <span style="color: #3a8ee6">gene
                </span>and the results show the correlation between the expression of that gene and the immune checkpoint genes and generate a heatmap graph.</p>
                <br>
                <div>
                  <img v-lazy="'http://tmliang.cn/pic/adi/help/Immune/Immune-Check.png'" style="width: 100%">
                </div>

              </div>


            </el-card>
            <br>
            <el-card id="chemokine" style="width: 98%;cursor: pointer">
              <span style="font-weight: bold;font-size: 20px;color: #55475b" @click="chemokine =!chemokine">4.2  Chemokine</span>
              <div v-show="chemokine">
                <el-divider></el-divider>
                <p>In this section, you can enter a
                  <span style="color: #3a8ee6">gene
                </span>
                  and the results show the correlation of the expression of that gene with chemokine genes and generate a heatmap.</p>
                <br>
                <div>
                  <img v-lazy="'http://tmliang.cn/pic/adi/help/Immune/Immune-Chemokine.png'" style="width: 100%">
                </div>
              </div>


            </el-card>
            <br>
            <el-card id="receptor" style="width: 98%;cursor: pointer">
              <span style="font-weight: bold;font-size: 20px;color: #55475b" @click="receptor = !receptor">4.3  Receptor</span>
              <div v-show="receptor">
                <el-divider></el-divider>
                <p>In this section, you can enter a
                  <span style="color: #3a8ee6">gene
                </span>
                  and the results show the correlation between the expression of that gene and the chemokine receptor and generate a heatmap graph.</p>
                <br>
                <div>
                  <img v-lazy="'http://tmliang.cn/pic/adi/help/Immune/Immune-Receptor.png'" style="width: 100%">
                </div>
              </div>

            </el-card>
            <br>
            <el-card id="stimulator" style="width: 98%;cursor: pointer">
              <span style="font-weight: bold;font-size: 20px;color: #55475b" @click="stimulator =!stimulator">4.4  Immune Stimulator</span>
              <div v-show="stimulator">
                <el-divider></el-divider>
                <p>In this section, you can enter a
                  <span style="color: #3a8ee6">gene
                </span>and the results show the correlation between the expression of that gene and the immunostimulatory factor genes and generate a heatmap graph.</p>
                <br>
                <div>
                  <img v-lazy="'http://tmliang.cn/pic/adi/help/Immune/Immune-ImmuStimuFactor.png'" style="width: 100%">
                </div>

              </div>

            </el-card>
            <br>
            <el-card id="inhibitor" style="width: 98%;cursor: pointer">
              <span style="font-weight: bold;font-size: 20px;color: #55475b" @click="inhibiter =!inhibiter">4.5  Immune Inhibitor</span>
              <div v-show="inhibiter">
                <el-divider></el-divider>
                <p>In this section, you can enter a
                  <span style="color: #3a8ee6">gene
                </span>and the results show the correlation between the expression of that gene and the immunosuppressive factor genes and generate a heatmap.</p>
                <br>
                <div>
                  <img v-lazy="'http://tmliang.cn/pic/adi/help/Immune/Immune-ImmuInhiFactor.png'" style="width: 100%">
                </div>

              </div>

            </el-card>
            <br>
<!--            <el-card id="score" style="width: 98%;cursor: pointer">-->
<!--              <span style="font-weight: bold;font-size: 20px;color: #55475b" @click="score =!score">4.6  Immune Score</span>-->
<!--              <div v-show="score">-->
<!--                <el-divider></el-divider>-->
<!--                <p>In this section, you can enter a-->
<!--                  <span style="color: #3a8ee6">gene-->
<!--                </span>and the results show the correlation between the expression of that gene and the three immunity score scores and generate a heatmap graph.</p>-->
<!--                <br>-->
<!--                <el-card>-->
<!--                  <img src="../../assets/help/immune/imm6.png" style="width: 100%">-->
<!--                </el-card>-->

<!--              </div>-->

<!--            </el-card>-->
<!--            <br>-->
<!--            <el-card id="cell" style="width: 98%;cursor: pointer">-->
<!--              <span style="font-weight: bold;font-size: 20px;color: #55475b" @click="cell=!cell">4.7  Immune Cell</span>-->
<!--              <div v-show="cell">-->
<!--                <el-divider></el-divider>-->
<!--                <p>In this section, you can enter a-->
<!--                  <span style="color: #3a8ee6">gene-->
<!--                </span>and the results show the correlation between the expression of that gene and the percentage of immune cells and generate a heatmap graph.</p>-->
<!--                <br>-->
<!--                <el-card>-->
<!--                  <img src="../../assets/help/immune/imm7.png" style="width: 100%">-->
<!--                </el-card>-->


<!--              </div>-->

<!--            </el-card>-->
          </el-card>
          <br>
          <el-card id="drug">
            <span style="font-weight: bold;font-size: 20px">5. Drug</span>
            <el-divider></el-divider>
            <p>The
              <span style="font-weight: bold;color:#3a8ee6;">drug
              </span>
              module displays the analysis results related to regulatory factor expression and drugs. This interface provides two analysis modules: regulatory factor and drug correlation analysis and related gene screening drug pathways.
            </p>
          <br>
            <div >
              <img v-lazy="'http://tmliang.cn/pic/adi/help/Drug/Drug-Con1.png'" style="width: 60%">
            </div>
            <el-card id="Relevance" style="width: 98%;cursor: pointer">
              <span style="font-weight: bold;font-size: 20px;color: #55475b" @click="Relevance = !Relevance"> 5-1 Drug Relevance</span>
              <div v-show="Relevance">
                <el-divider></el-divider>
                <p>In this section, you can enter a gene to get the correlation results with the drug. The top six correlation results are shown in the figure.</p>
                <br>
                <div >
                  <img v-lazy="'http://tmliang.cn/pic/adi/help/Drug/Drug-Result1.png'" style="width: 100%">
                </div>

              </div>

            </el-card>
            <br>
            <el-card id="Pathway" style="width: 98%;cursor: pointer">
              <span style="font-weight: bold;font-size: 20px;color: #55475b" @click="Pathway = !Pathway"> 5-2 Drug Pathway</span>
              <div v-show="Pathway">
                <el-divider></el-divider>
                <p>In this section you can enter a list of genes to obtain drug pathway information associated with it.</p>
                <br>
                <div >
                  <img v-lazy="'http://tmliang.cn/pic/adi/help/Drug/Drug-Pathway.png'" style="width: 100%">
                </div>
              </div>
            </el-card>
          </el-card>
          <br>
          <el-card id="network">
            <span style="font-weight: bold;font-size: 20px">6. Network</span>
            <el-divider></el-divider>
            <p>This module displays the network diagram associated with TF, ncRNA, and synthetic lethal genes.</p>
            <br>
            <el-card id="TFGene" style="width: 98%;cursor: pointer">
              <span style="font-weight: bold;font-size: 20px;color: #55475b" @click="TFGene = !TFGene"> 6.1 TF-gene Network</span>
              <div v-show="TFGene">
                <el-divider></el-divider>
                <p>This section generates transcription factor and target gene regulatory networks based on the gene you input.</p>
                <br>
                <div >
                  <img v-lazy="'http://tmliang.cn/pic/adi/help/Network/TF-Con1.png'" style="width: 100%">
                </div>
                <div >
                  <img v-lazy="'http://tmliang.cn/pic/adi/help/Network/TF-Result.png'" style="width: 100%">
                </div>
              </div>
            </el-card>
            <br>
            <el-card id="ncRNAGene" style="width: 98%;cursor: pointer">
              <span style="font-weight: bold;font-size: 20px;color: #55475b" @click="ncRNAGene = !ncRNAGene"> 6.2  ncRNA-gene Network</span>
              <div v-show="ncRNAGene">
                <el-divider></el-divider>
                <p>This section generates the ncRNA-gene network based on the ncRNA or gene you input.</p>
                <br>
                <div >
                  <img v-lazy="'http://tmliang.cn/pic/adi/help/Network/ncRNA-Con1.png'" style="width: 100%">
                </div>
                <div >
                  <img v-lazy="'http://tmliang.cn/pic/adi/help/Network/ncRNA-Result.png'" style="width: 100%">
                </div>
              </div>
            </el-card>
            <br>
            <el-card id="SLGene" style="width: 98%;cursor: pointer">
              <span style="font-weight: bold;font-size: 20px;color: #55475b" @click="SLGene = !SLGene"> 6.3  Synthetic Lethality Network</span>
              <div v-show="SLGene">
                <el-divider></el-divider>
                <p>This section generates the ncRNA-gene network based on the ncRNA or gene you input.</p>
                <br>
                <div >
                  <img v-lazy="'http://tmliang.cn/pic/adi/help/Network/sl-Con1.png'" style="width: 100%">
                </div>
                <div >
                  <img v-lazy="'http://tmliang.cn/pic/adi/help/Network/sl-Result.png'" style="width: 100%">
                </div>
              </div>
            </el-card>
<!--            <el-card>-->
<!--             <img src="../../assets/help/network/network.png" style="width: 100%">-->
<!--           </el-card>-->
<!--            <br>-->
<!--&lt;!&ndash;            <p>You can click on the corresponding node to see the other nodes that are associated with this node.</p>&ndash;&gt;-->
<!--            <el-card>-->
<!--              <img src="../../assets/help/network/node.png" style="width: 100%">-->
<!--            </el-card>-->

          </el-card>
          <br>
          <el-card id="evolution" >
            <span style="font-weight: bold;font-size: 20px">7. Evolution</span>
            <el-divider>
            </el-divider>
            <p>In the evolution section, you can select the genes you are interested in from the dropdown menu to obtain the evolutionary map, which has two evolutionary maps that can be switched between, and you can view the specific species appearing in the map on the left side.</p>
            <br>
            <div >
              <img v-lazy="'http://tmliang.cn/pic/adi/help/Evolution/Evolution1.png'" style="width: 100%">
            </div>
<!--            <div >-->
<!--              <img v-lazy="'http://tmliang.cn/pic/adi/help/Evolution/Evolution2.png'" style="width: 100%">-->
<!--            </div>-->
          </el-card>
          <br>
          <el-card id="others">
            <span style="font-weight: bold;font-size: 20px">8. Others</span>
            <el-divider></el-divider>
            <p>If you have additional questions, you can contact us via email by clicking on the "Contact us " section!</p>
            <br>
            <div >
              <img v-lazy="'http://tmliang.cn/pic/adi/help/Others/Others.png'" style="width: 100%">
            </div>
          </el-card>
        </div>
      </el-card>
    </div>
  </div>
</template>

<script>


import MyFooter from "../footer.vue";
import sum1 from "../../assets/help/summary/img.png"

export default {
  name: "Help.vue",
  components: {MyFooter},
  data() {
    return {
      gene:false,
      ncRNA:false,
      Disease:false,
      Dataset:false,
      expression :false,
      survival :false,
      gsea :false,
      cnv :false,
      Mutation :false,
      Methylation :false,
      checkpoint :false,
      chemokine :false,
      receptor:false,
      stimulator :false,
      inhibiter :false,
      score :false,
      cell :false,
      Relevance :false,
      Pathway :false,
      TFGene:false,
      ncRNAGene:false,
      SLGene:false,
    };
  },
  methods: {
    scrollTo(id) {
      const element = document.getElementById(id);
      if (element) {
        element.scrollIntoView({ behavior: "auto", block: "start" });
        window.scrollBy(0, -75);
      };
      console.log('跳转成功')
    },
    handleMenuSelect(index) {
      // Here you can call scrollTo() method based on the selected index
      console.log(index)
      switch (index) {
        case 0:
          this.scrollTo('introduction');
          console.log('跳转到首页帮助页面');
          break;
        case 1:
          this.scrollTo('summary');
          console.log('跳转到介绍帮助页面');
          break;
        // Add cases for other indexes if needed
        case 1.1:
          this.scrollTo('Gene');
          this.gene = true;
          break;
        case 1.2:
          this.scrollTo('ncRNA');
          this.ncRNA = true;
          break;
        case 1.3:
          this.scrollTo('Disease');
          this.Disease = true;
          break;
        case 1.4:
          this.scrollTo('Dataset');
          this.Dataset = true;
          break;
        case 2:
          this.scrollTo('analysis');
          break;
        case 2.1:
          this.scrollTo('expression');
          this.expression =true;
          break;
        case 2.2:
          this.scrollTo('Survival');
          this.survival =true;
          break;
        case 2.3:
          this.scrollTo('GSEA');
          this.gsea = true;
          break;
        case 2.4:
          this.scrollTo('CNV');
          this.cnv =true;
          break;
        case 2.5:
          this.scrollTo('MUT');
          break;
        case 2.6:
          this.scrollTo('METHY');
          this.Methylation = true;
          break;
        case 3:
          this.scrollTo('immune');
          break;
        case 3.1:
          this.scrollTo('checkpoint');
          this.checkpoint = true;
          break;
        case 3.2:
          this.scrollTo('chemokine');
          this.chemokine = true;
          break;
        case 3.3:
          this.scrollTo('receptor');
          this.receptor = true;
          break;
        case 3.4:
          this.scrollTo('stimulator');
          this.stimulator = true;
          break;
        case 3.5:
          this.scrollTo('inhibitor');
          this.inhibiter = true;
          break;
        case 3.6:
          this.scrollTo('score');
          break;
        case 3.7:
          this.scrollTo('cell');
          break;
        case 4:
          this.scrollTo('drug');
          break;
        case 4.1:
          this.scrollTo('Relevance');
          this.Relevance = true;
          break;
        case  4.2:
          this.scrollTo('Pathway');
          this.Pathway = true;
          break
        case 5:
          this.scrollTo('network');
          break;
        case 5.1:
          this.scrollTo('TFGene');
          this.TFGene = true;
          break;
        case 5.2:
          this.scrollTo('ncRNAGene');
          this.ncRNAGene = true;
          break;
        case 5.3:
          this.scrollTo('SLGene');
          this.SLGene = true;
          break;
        case 6:
          this.scrollTo('others');
          break;
        case 7:
          this.scrollTo('evolution');
          break;


      }
    }
  },
  computed :{
  }

}
</script>

<style scoped>
.help{
  width: 1400px;
  margin: 0 auto;
  border-style: solid;
  background-color: #ffffff;
  border-color: rgba(168,168,168,0);
}

.help-container {
  display: flex;
  position: relative;
  flex-direction: row;
  height: 100%;
}

.sidebar {
  width: 280px;
  padding: 15px;
  /*background: #f4f4f5;*/
  border-right: 1px solid #ccc;
  top: 75px; /* 设置导航栏距离页面顶部的距离 */
  display: block; /* 添加此行使标题文本左对齐 */
  text-align: left;
  overflow-y: auto; /* 让内容部分可滚动 */
  /*max-height: calc(100vh ); !* 设置最大高度，确保内容部分不超出屏幕 *!*/
}
.content-wrapper {
  width: 1120px;
  overflow-y: auto; /* 让内容部分可滚动 */
  /*max-height: calc(100vh - 75px); !* 设置最大高度，确保内容部分不超出屏幕 *!*/
  height: 1130px;
  top: 75px; /* 设置导航栏距离页面顶部的距离 */
}

.content {
  width: 100%;
  padding: 20px;
  text-align: left;

}
.content p{
  line-height: 1.5;
  font-size: 18px;
  display: block; /* 添加此行使标题文本左对齐 */
  text-align: left;
}

.content img{
  max-width: 90vh;
}


</style>
