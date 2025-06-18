############main code
rm(list = ls())
load(file="./TCGA_GTEx_pancancer_mRNA_pheno.rdata")
library(ggplot2)
library(ggpubr)
library(tidyverse)
library(latex2exp)
library(rstatix)
gene <- read.delim("./tcgaadigenename.txt")
gene <- gene$Gene
gene <- gsub(" ","",gene)
plot_df <- tcga_gtex_mrna_pheno %>%
  select(1:4,all_of(gene)) %>%
  filter(sample_type %in% c("GTEx_normal","TCGA_normal"))
plot_df[1:5,1:10]
plot_df <- plot_df[,c(3,5:94)]

library(data.table) 
library(dplyr)

test <- plot_df %>%
  group_by(project) %>%
  summarise(across(where(is.numeric),  median, .names = "{.col}"))

library("ggheatmap")
library(ComplexHeatmap)
library(circlize)
library(pheatmap)
test1 <- test[,2:91]
test1[1:5,1:5]
test1 <- as.data.frame(test1)
test1[test1 > 8] <- 8 
test1[test1 < -8] <- -8 
test1 <- as.matrix(test1)
rownames(test1) <-test$project
row_sum <- rowSums(test1)
col_sum <- colSums(test1)
get_color <- function(x) { 
  ifelse(x > 0, "#f87669", "#2fa1dd") 
} 
row_ha <- rowAnnotation( 
  Sum = anno_barplot(row_sum, 
                     axis_param = list(side="top"), 
                     bar_width = 0.6, 
                     gp = gpar(fill = get_color(row_sum), col=NA)), 
  show_annotation_name = FALSE 
) 


col_ha <- columnAnnotation( 
  Sum = anno_barplot(col_sum, 
                     axis_param = list(side="left"), 
                     bar_width = 0.6, 
                     gp = gpar(fill = get_color(col_sum), col=NA)), 
  show_annotation_name = FALSE 
) 


pdf(file = "./normal_median.pdf",14,9)

Heatmap(test1,
        name = "Expression",
        col = colorRamp2(c(-5, 0, 5), c("#2fa1dd", "white", "#f87669")),
        cluster_rows = TRUE,
        cluster_columns = TRUE,
        row_names_gp = gpar(fontsize=8),
        column_names_gp = gpar(fontsize=8),
        top_annotation = col_ha,
        left_annotation = row_ha,
        border = NA
        )

dev.off()


####In tumor 

library(ggplot2)
library(ggpubr)
library(tidyverse)
library(latex2exp)
library(rstatix)

plot_df <- tcga_gtex_mrna_pheno %>%
  select(1:4,all_of(gene)) %>%
  filter(sample_type %in% c("TCGA_tumor"))
plot_df[1:5,1:10]
plot_df <- plot_df[,c(3,5:94)]

library(data.table) 
library(dplyr)
library(pheatmap)
test <- plot_df %>%
  group_by(project) %>%
  summarise(across(where(is.numeric),  median, .names = "{.col}"))
test1 <- test[,2:91]
test1[1:5,1:5]
test1 <- as.data.frame(test1)
test1[test1 > 8] <- 8 
test1[test1 < -8] <- -8 
test1 <- as.matrix(test1)
rownames(test1) <- test$project
library("ggheatmap")
library(ComplexHeatmap)
library(circlize)
 
row_sum <- rowSums(test1)
col_sum <- colSums(test1)

get_color <- function(x) { 
  ifelse(x > 0, "#f87669", "#2fa1dd") 
} 

row_ha <- rowAnnotation( 
  Sum = anno_barplot(row_sum, 
                     axis_param = list(side="top"), 
                     bar_width = 0.6, 
                     gp = gpar(fill = get_color(row_sum), col=NA)), 
  show_annotation_name = FALSE 
)  
col_ha <- columnAnnotation( 
  Sum = anno_barplot(col_sum, 
                     axis_param = list(side="left"), 
                     bar_width = 0.6,  
                     gp = gpar(fill = get_color(col_sum), col=NA)), 
  show_annotation_name = FALSE 
) 


pdf(file = "./tumor_median.pdf",14,9)

Heatmap(test1,
        name = "Expression",
        col = colorRamp2(c(-5, 0, 5), c("#2fa1dd", "white", "#f87669")),
        cluster_rows = TRUE,
        cluster_columns = TRUE,
        row_names_gp = gpar(fontsize=8),
        column_names_gp = gpar(fontsize=8),
        top_annotation = col_ha,
        left_annotation = row_ha,
        border = NA
)
dev.off()


drug <- read.csv(paste0("./GDSC/export.csv"))
head(drug)
gene <- read.delim("G:/01 papers/2025 paper/8 zhifangyinzi dataset/tcgaadigenename.txt")
gene <- gene$Gene
gene <- gsub(" ","",gene)

drug <- drug[,c("drug_name","pathway_name","targets")]
drug$pathway_name <- gsub(" ","_",drug$pathway_name)
library(ggalluvial)
library(RColorBrewer)
library(stringr)
library(stringi)
display.brewer.all()
df <- data.frame(Drug_name=drug$drug_name,
                 Pathway_name=drug$pathway_name,
                 Targets=drug$targets
)
df <- df[df$Targets != "-",]

df <- df[df$Pathway_name != "-",]
df <- df[df$Pathway_name != "Other",]
df <- df[df$Pathway_name != "Other,_kinases",]
df1 <- str_split(df$Targets,",")
df1 <- unlist(df1)
df1 <- unique(df1)
df1 <- gsub(" ","",df1)
aa <- intersect(df1,gene)
df2 <- df[df$Targets %in% aa,]
head(df)
table <- c()

for (i in aa) {
  
  df2 <- df[grepl(i,df$Targets),]
  table <- rbind(table,df2)
  
}

df3 <- table
UCB_lodes <- to_lodes_form(df3[,1:ncol(df3)],
                           axes = 1:ncol(df3),
                           id = "Cohort")

UCB_lodes$Freq <- 1
head(UCB_lodes)
tail(UCB_lodes)

colors <- rep(brewer.pal(12, 'Paired'),5) 
p <- ggplot(UCB_lodes,
            aes(x = x, stratum = stratum, alluvium = Cohort,
                fill=stratum,label=stratum)) +
  scale_x_discrete(expand = c(0, 0)) +
  geom_flow(width = 0.75) + 
  geom_stratum(alpha = 0.5,width = 0.75) + 
  geom_text(stat = "stratum",size = 3.5,color="black") +
  theme(legend.position = "none") +
  scale_fill_manual(values = colors) +
  labs(title ="Drug-Targets-Pathway",x="",y="" )+ 
  theme_bw() + 
  theme(axis.line = element_blank(), 
        axis.ticks = element_blank(), 
        axis.text.y  = element_blank(), 
        panel.grid =element_blank(), 
        panel.border = element_blank()) + 
  guides(fill = FALSE) 
print(p)

library(ggplot2)
library(ggsci)
library(survival)
library(randomForestSRC)
library(glmnet)
library(plsRcox)
library(mixOmics)
library(gbm)
library(CoxBoost)
library(survivalsvm)
library(dplyr)
library(tibble)
library(BART)
library("superpc")
library(devtools)
library("devtools")
library(survival)
library(survminer)
library(RCircos)
library(readr)

gene <- read_xlsx("./adigemoic_contextv1_hsa.xlsx",col_names = T)
head(gene)
gene <- gene[,1:4]
head(gene)
data.5 <- gene
head(data.5)
colnames(data.5) <- c("Gene","Chromosome","chromStart","chromEnd")
data.5$Chromosome <- paste0("chr",data.5$Chromosome)
library(dplyr)
library(stringr)
library(limma)
m="BRCA"
n= paste("TCGA-",m,sep = "")
TCGA_gset <- read.table(paste("./",n,".gene_expression_TPM.tsv",sep = ""),header = T,sep = "\t")
TCGA_gset <- data.frame(TCGA_gset)
TCGA_gset = as.data.frame(avereps(TCGA_gset[,-1],ID = TCGA_gset$ID) ) 
colnames(TCGA_gset) <- substring(colnames(TCGA_gset),1,15) %>% gsub("-",".",.)
TCGA_gset <- log2(TCGA_gset+1)
exp <- TCGA_gset[,as.numeric(str_sub(colnames(TCGA_gset),14,15)) > 9]
exp$GeneName <- rownames(exp)
exp.1 <- exp[exp$GeneName %in% data.5$Gene,]
data.5 <- as.data.frame(data.5)
data.5$chromStart <- as.integer(data.5$chromStart) 
data.5$chromEnd <- as.integer(data.5$chromEnd) 
colnames(data.5)[1] <- "GeneName"
data.5 <- cbind(data.5[2:4],data.5[1])
data.6 <- left_join(data.5,exp.1, by = "GeneName")
data(UCSC.HG19.Human.CytoBandIdeogram)
cyto.info <- UCSC.HG19.Human.CytoBandIdeogram
head(cyto.info)
chr.exclude <- NULL
tracks.inside <- 10
tracks.outside <- 0
RCircos.Set.Core.Components(cyto.info, chr.exclude,tracks.inside, tracks.outside)
RCircos.List.Plot.Parameters()
RCircos.Set.Plot.Area()     
RCircos.Chromosome.Ideogram.Plot() 
side <- "in";
track.num <- 1;
RCircos.Gene.Connector.Plot(data.5, track.num, side);
name.col <- 4;
track.num <- 2;

RCircos.Gene.Name.Plot(data.5, name.col,track.num, side);
RCircos.Get.Gene.Name.Plot.Parameters()
table(data.5$Chromosome)  
data(RCircos.Heatmap.Data);
head(RCircos.Heatmap.Data)
data.7 <- data.6
data.7 <- na.omit(data.7)
data.7$value <-  rowMeans(data.7[,5:ncol(data.7)])
data.8 <- cbind(data.7[1:4],data.7$value)
head(data.8)
data.8 <- data.8[which(data.8$`data.7$value`>0),]
data.8$chromStart <- sqrt(data.8$chromStart)
data.8 <- data.8[which(data.8$Chromosome != "chrM"),]
data.col <- 5;
track.num <- 5;
side <- "in";
RCircos.Heatmap.Plot(data.8, data.col, track.num, side);


gene <- c("METRNL","NRG4", "LEP", "ADIPOQ", "FGF21", "FABP4", "RARRES2","FBN1","ANGPTL2","RBP4")
load(file="./BRCA_matrix.Rdata")
load("./TCGA_GTEx_pancancer_mrna_pheno.rdata")
exp_nc[1:6,1:6]
library(ggplot2)
library(ggpubr)
library(tidyverse)
library(latex2exp)
library(rstatix)
for (i in gene) {

  plot_df <- tcga_gtex_mrna_pheno %>%
  select(1:4,all_of(gene)) %>%
  filter(sample_type %in% c("GTEx_normal","TCGA_normal","TCGA_tumor"))
colnames(plot_df)[5] <- "gene"

data_new <- plot_df %>% 
  group_by(project) %>% 
  mutate(median = median(gene), group_max = max(gene)) %>% 
  arrange(desc(median))
data_new$sample_type <- ifelse(data_new$sample_type != "TCGA_tumor","Normal",data_new$sample_type )
data_new$sample_type <- ifelse(data_new$sample_type == "TCGA_tumor","Tumor",data_new$sample_type)
data_new$gene <- ifelse(data_new$gene < -5,5, data_new$gene)
data_new$project <- factor(data_new$project, levels = unique(data_new$project))
data_new <- data.frame(data_new)
data_new$sample_type <- as.factor(data_new$sample_type)
colnames(data_new)[2] <- "Group"
cancer <- c("LGG","BRCA","LIHC","PRAD")
data_new <- data_new[data_new$project %in% cancer,]
library(ggpubr) 
data_new<- as.data.frame(data_new)

if (!is.factor(data_new$Group))  { 
  data_new$Group <- as.factor(data_new$Group)  
} 


p <- ggplot(data = data_new, aes(x = project, y = gene)) + 
  geom_violin(aes(fill=Group)) + 
  geom_boxplot(aes(col=Group),outlier.shape  = NA,width = 0.3, 
               position = position_dodge(0.9)) + 
  theme_bw() + 
  theme(axis.text.x  = element_blank(), 
        legend.position  = 'top', 
        plot.title  = element_text(size = 12, face = "bold.italic"),  
        axis.title.y  = element_text(size = 12, face = "bold")) + 
  ylab(paste0(gene, " expression: log2(TPM+0.01)")) + 
  xlab("Cancer") + 
  facet_wrap(. ~ project, scales = "free_x") + 
  scale_x_discrete(breaks = unique(data_new$project)) 

p1=p + stat_compare_means(aes(x = project, y = gene, group = Group), 
                          method = "wilcox.test",  
                          label = "p.signif",  
                          size = 5, 
                          hide.ns  = TRUE, 
                          label.x = 1.2,
                          label.y = max(data_new$gene) -1) 

p1


rm(list = ls())
options(stringsAsFactors = F)
library(GSVA)
library(ggplot2)
library(limma)
library(pheatmap)
library(reshape2)
library(mclust)
library(stringr)

gene <- read.table("./adigene.txt",header = T,sep = "\t")

cancer <- read.table("./sample.number.txt",header = T,sep = "\t")
  cancer.1 <- cancer[cancer$tumor > 0,]
  cancer.2 <- sort(cancer.1$cancer)
  table <- c()
for (m in cancer.2) {
    print(m)
    n= paste("TCGA-",m,sep = "")
  TCGA_gset <- read.table(paste("./",n,".gene_expression_TPM.tsv",sep = ""),header = T,sep = "\t")
  TCGA_gset <- data.frame(TCGA_gset)
  TCGA_gset = as.data.frame(avereps(TCGA_gset[,-1],ID = TCGA_gset$ID) ) 
  colnames(TCGA_gset) <- substring(colnames(TCGA_gset),1,15) %>% gsub("-",".",.)
  TCGA_gset[1:4,1:4]
  TCGA_gset <- log2(TCGA_gset+1)
  exp <- TCGA_gset[,str_sub(colnames(TCGA_gset),14,15)<10]

  df <- exp[rownames(exp) %in% gene$TCGA_Name,]
  mads <- apply(df,1,mad) 
  df <- df[rev(order(mads)),]
  df <-  sweep(df,1, apply(df,1,median,na.rm=T)) 
  df <- as.matrix(df)
  library(ConsensusClusterPlus)
  maxK <-  6 
  results <-  ConsensusClusterPlus(df,
                                   maxK = maxK,
                                   reps = 1000,              
                                   pItem = 0.8,             
                                   pFeature = 1,
                                   clusterAlg = "pam",       
                                   distance="pearson",      
                                   title=paste("./CLUSTE/",m,sep = ""), 
                                   innerLinkage="complete",  
                                   plot="pdf")              
  
  
  Kvec = 2:maxK
  x1 = 0.1; x2 = 0.9        
  PAC = rep(NA,length(Kvec)) 
  names(PAC) = paste("K=",Kvec,sep="")  
  for(i in Kvec){
    M = results[[i]]$consensusMatrix
    Fn = ecdf(M[lower.tri(M)])          
    PAC[i-1] = Fn(x2) - Fn(x1)
  } 
  
  
  optK = Kvec[which.max(PAC)] 
  
  icl = calcICL(results,
                title=paste("./CLUSTER99-0506/",m,"-0506",sep = ""),
                plot="pdf")
  group <- results[[optK]][["consensusClass"]]
  group <- data.frame(group)
  head(group)
  group$sampleID <- rownames(group)
  group$sampleID <- gsub(".03","",group$sampleID)
  group$sampleID <- gsub(".01","",group$sampleID)
  cli <- read.table(paste("./TCGA.",m,".sampleMap/",m,"_clinicalMatrix",sep = ""),header = T,sep = "\t")  
  cli.1 <- cli[,c("X_PATIENT","vital_status","days_to_death","days_to_last_followup","age_at_initial_pathologic_diagnosis",
                  "gender") ] 
  cli.1$days_to_death = with(cli.1,ifelse(is.na(days_to_death),'',days_to_death))
  cli.1$vital_status <- ifelse(cli.1$vital_status == "LIVING",0,1) #重新赋值alive??? 0，dead??? 1
  cli.1$time <- ifelse(cli.1$vital_status == 1, cli.1$days_to_death, cli.1$days_to_last_followup)
  cli.1$gender <- ifelse(cli.1$gender=="MALE",1,2)
  head(cli.1)
  cli.1 <- cli.1[,c("X_PATIENT","vital_status","time","gender","age_at_initial_pathologic_diagnosis")]   
  colnames(cli.1) <- c( "sampleID","status","time","gender","age")
  cli.1$time <- as.numeric(cli.1$time)
  cli.1 <- na.omit(cli.1)
  cli.1$sampleID <- gsub("-",".",cli.1$sampleID)
  cli.3 <- merge(group,cli.1, by="sampleID")
  cli.3$time <- as.numeric(cli.3$time)
  #### survival analysis based on  clusters
  library(survminer)
  library(survival) 
  cli.3 <- cli.3[,1:4]
  head(cli.3)
  cli.3$group <- as.character(cli.3$group)
  cli.3 <- unique(cli.3)
  fit <- survfit(Surv((time), status) ~ group, data = cli.3)
  summary(fit)

  pdf(file = paste("./CLUSTER/",m,"survival.pdf",sep = ""),onefile = TRUE,width=8,height=8)
  
  p=ggsurvplot(fit,
             data = cli.3,
             pval = TRUE, 
             conf.int = TRUE,
             palette = "hue",
             surv.median.line = "hv",
             risk.table = TRUE)
  
  
  print(p)
  
  dev.off()
  aa <- surv_pvalue(fit, method = "survdiff")
  test <- cbind(cancer=m,group=optK, pval=aa$pval)
  table <- rbind(table,test)
 
}

###### survival 

rm(list = ls())
options(stringsAsFactors = F)
library(survival)
library(survminer)
library(tidyr)
library(dplyr)
library(survivalROC)

gene <- read.table("./tcgaadigenename.txt",header = T,sep = "\t")
head(gene)
cancer <- read.table("./sample.number.txt",header = T,sep = "\t")
cancer.1 <- cancer[cancer$normal > 4,]

cancer.2 <- sort(cancer.1$cancer)

table <- c()
for (m in cancer.2) {
  #m <- cancer[i]
  print(m)
  #m="LIHC"
  n= paste("TCGA-",m,sep = "")
  TCGA_gset <- read.table(paste("./",n,".gene_expression_TPM.tsv",sep = ""),header = T,sep = "\t")
  TCGA_gset <- data.frame(TCGA_gset)
  TCGA_gset = as.data.frame(avereps(TCGA_gset[,-1],ID = TCGA_gset$ID) )
  colnames(TCGA_gset) <- substring(colnames(TCGA_gset),1,15) %>% gsub("-",".",.)
  TCGA_gset[1:4,1:4]
  TCGA_gset <- log2(TCGA_gset+1)
  exp <- TCGA_gset[,str_sub(colnames(TCGA_gset),14,15)<10]
  deg <- read.table(paste0("./",m,"_TPM_limma_mRNA_DEG.txt"),header=T,sep ="\t")
  
  deg <- deg[rownames(deg) %in%gene$Gene,]
  deg <- deg[abs(deg$logFC) > 1.0 & deg$adj.P.Val < 0.05,]
  
  for (i in rownames(deg)) {
  df <- exp[i ,]
   cli <- read.table(paste("./clinical/TCGA.",m,".sampleMap/",m,"_clinicalMatrix",sep = ""),header = T,sep = "\t")  
   cli.1 <- cli[,c("X_PATIENT","vital_status","days_to_death","days_to_last_followup","age_at_initial_pathologic_diagnosis",
                   "gender") ] 
   cli.1$days_to_death = with(cli.1,ifelse(is.na(days_to_death),'',days_to_death))
   cli.1$vital_status <- ifelse(cli.1$vital_status == "LIVING",0,1) #重新赋值alive??? 0，dead??? 1
   cli.1$time <- ifelse(cli.1$vital_status == 1, cli.1$days_to_death, cli.1$days_to_last_followup)
   cli.1$gender <- ifelse(cli.1$gender=="MALE",1,2)
   cli.1 <- cli.1[,c("X_PATIENT","vital_status","time","gender","age_at_initial_pathologic_diagnosis")]   
   colnames(cli.1) <- c( "sampleID","status","time","gender","age")
   cli.1$time <- as.numeric(cli.1$time)
   cli.1 <- na.omit(cli.1)
   cli.1$sampleID <- gsub("-",".",cli.1$sampleID)
   cli.1 <- cli.1[,1:3]
   cli.1 <- unique(cli.1)
   colnames(cli.1)
   colnames(df) <- gsub("\\.01","",colnames(df))
   colnames(df) <- gsub("\\.1","",colnames(df))
   colnames(df) <- gsub("\\.2","",colnames(df))
   colnames(df) <- gsub("\\.05","",colnames(df))
   need_clini <- cli.1
   need_clini<-need_clini[need_clini$sampleID %in% colnames(df),]
   need_hub_exp <- df
   need_hub_exp<-need_hub_exp[,colnames(need_hub_exp) %in% need_clini$sampleID]
   need_hub_exp<-as.matrix(need_hub_exp)
   need_hub_exp<-t(need_hub_exp)
   need_hub_exp<-as.data.frame(need_hub_exp)
   need_hub_exp$sampleID <- rownames(need_hub_exp)
   need_hub_exp <- need_hub_exp[need_clini$sampleID,]
    need_clini <- merge(need_clini,need_hub_exp,by="sampleID")
    colnames(need_clini)[4] <- "value"
    need_clini$group <- ifelse(need_clini$value > median(need_clini$value),"High","Low")
    need_clini$time <- as.numeric(need_clini$time)


library(survival)
library(survminer)
library(dplyr)
library(purrr)
    surv_obj <- Surv(time = need_clini$time, event =need_clini$status )
    fit <- survdiff(Surv(time, status) ~ group, data = need_clini)
    pval <- 1 - pchisq(fit$chisq, length(fit$n) - 1)
    if(pval < 0.05) {
    test <- cbind(cancer=m,gene=i,pval=pval)
    print(test)
    table <- rbind(table,test)
      pdf(paste0("./",m,"_",i, " expression survival analysis.pdf"),onefile = F,8,8)
      plot <- ggsurvplot(
        survfit(surv_obj ~ group, data = need_clini),
        data = need_clini,
        pval = TRUE,
        risk.table  = TRUE,
        title = paste0(i, " survival analysis in ",m),
        palette = c("red", "blue")
      )
      
      print(plot)
     dev.off() 
     
    }
    
  }

}



###### miRNA survival 
rm(list = ls())
options(stringsAsFactors = F)
library(survival)
library(survminer)
library(tidyr)
library(dplyr)
library(survivalROC)

gene <- read.table("./ncRNA.txt",header = T,sep = "\t")
head(gene)
gene <- gene[gene$type == "miRNA",]
gene$gene <- tolower( gene$gene)
cancer <- read.table("./sample.number.txt",header = T,sep = "\t")
cancer.1 <- cancer[cancer$normal > 6,]
cancer.1 <- cancer.1[which(cancer.1$cancer != "READ"),]
cancer.2 <- sort(cancer.1$cancer)
cancer.2 
table <- c()
for (m in cancer.2) { 
  print(m)
  TCGA_gset <- read.delim(paste0("./isomiRNA_exp_RPM/",m,".isomiRNA_exp_RPM.tsv"),header = T)
  TCGA_gset <- data.frame(TCGA_gset)
  TCGA_gset = as.data.frame(avereps(TCGA_gset[,-1],ID = TCGA_gset$gene) ) 
  colnames(TCGA_gset) <- substring(colnames(TCGA_gset),1,15) %>% gsub("-",".",.)
  TCGA_gset <- log2(TCGA_gset+1)
  exp <- TCGA_gset[,str_sub(colnames(TCGA_gset),14,15)<10]
  deg <- read.table(paste0("./isomiRNA/",m,".isomiRNA_limma_result.txt"),header=T,sep ="\t")
  library(stringr)
  deg <- deg[abs(deg$logFC) > 1.0 & deg$adj.P.Val < 0.05,]
  matches <- str_detect(deg$gene, regex(paste(gene$gene, collapse="|"), ignore_case=TRUE))
  deg_filtered <- deg[matches,, drop=FALSE]
  head(deg_filtered)
  for (i in deg_filtered$local) {
    matches1 <- str_detect(rownames(exp) ,i )
    df <- exp[matches1,]
    cli <- read.table(paste("./clinical/TCGA.",m,".sampleMap/",m,"_clinicalMatrix",sep = ""),header = T,sep = "\t")  
    cli.1 <- cli[,c("X_PATIENT","vital_status","days_to_death","days_to_last_followup","age_at_initial_pathologic_diagnosis",
                    "gender") ] 
    cli.1$days_to_death = with(cli.1,ifelse(is.na(days_to_death),'',days_to_death))
    cli.1$vital_status <- ifelse(cli.1$vital_status == "LIVING",0,1) 
    
    cli.1$time <- ifelse(cli.1$vital_status == 1, cli.1$days_to_death, cli.1$days_to_last_followup)
    cli.1$gender <- ifelse(cli.1$gender=="MALE",1,2)
    head(cli.1)
    cli.1 <- cli.1[,c("X_PATIENT","vital_status","time","gender","age_at_initial_pathologic_diagnosis")]   
    colnames(cli.1) <- c( "sampleID","status","time","gender","age")
    cli.1$time <- as.numeric(cli.1$time)
    cli.1 <- na.omit(cli.1)
    cli.1$sampleID <- gsub("-",".",cli.1$sampleID)
    cli.1 <- cli.1[,1:3]
    head(cli.1)
    colnames(df) <- gsub(".01","",colnames(df))
    need_clini <- cli.1
    need_clini<-need_clini[need_clini$sampleID %in% colnames(df),]
    need_hub_exp <- df
    need_hub_exp<-need_hub_exp[,colnames(need_hub_exp) %in% need_clini$sampleID]
    need_hub_exp<-as.matrix(need_hub_exp)
    need_hub_exp<-t(need_hub_exp)
    need_hub_exp<-as.data.frame(need_hub_exp)
    need_hub_exp$sampleID <- rownames(need_hub_exp)
    need_hub_exp <- need_hub_exp[need_clini$sampleID,]
    need_clini <- merge(need_clini,need_hub_exp,by="sampleID")
    colnames(need_clini)[4] <- "value"
    need_clini$group <- ifelse(need_clini$value > median(need_clini$value),"High","Low")
    need_clini$time <- as.numeric(need_clini$time)
    need_clini <- na.omit(need_clini)
    library(survival)
    library(survminer)
    library(dplyr)
    library(purrr)
    surv_obj <- Surv(time = need_clini$time, event =need_clini$status )
    fit <- survdiff(Surv(time, status) ~ group, data = need_clini)
    pval <- 1 - pchisq(fit$chisq, length(fit$n) - 1)
    if(pval < 0.05) {
      aa <- str_split(colnames(need_hub_exp)[1],"_")[[1]][1]
      test <- cbind(cancer=m,gene=paste0(aa,"_",i),pval=pval)
      table <- rbind(table,test)
      pdf(paste0("./miRNA survival/",m,"_",aa, " expression survival analysis.pdf"),onefile = F,8,10)
      plot <- ggsurvplot(
        survfit(surv_obj ~ group, data = need_clini),
        data = need_clini,
        pval = TRUE,
        risk.table  = TRUE,
        title = paste0(colnames(need_hub_exp)[1], "\n",
                       " survival analysis in ",m),
        palette = c("red", "blue")
      )
      
      print(plot)
      dev.off() 
      
    }
    
  }
  
}

#SNV 
require(maftools) 
load(file = './pancancer_TCGA_mutation_10295_sample_mc3.Rdata')
d1 <- as.data.frame(laml@data)
genelist <- read.delim(".t/sl-genelist.txt")
d1$Tumor_Sample_Barcode <- substr(d1$Tumor_Sample_Barcode,1,12)
clinical <- read.delim("./maf/pancancer-clinical.txt")
head(clinical)
clinical <- clinical[which(clinical$group == "Tumor"),]
colnames(clinical)[8] <- "Tumor_Sample_Barcode"
maf <- read.maf(maf  = d1,  
                clinicalData = clinical,  
                verbose = FALSE)
target_maf <- subsetMaf(maf, genes = genelist$gene)
target_maf@clinical.data
gene_summary <- getGeneSummary(target_maf)
gene_summary[1:15,]
gene_summary$mutation_rate <- (gene_summary$MutatedSamples/nrow(target_maf@clinical.data))*100
gene_summary <- gene_summary[order(gene_summary$mutation_rate,decreasing = T),]
pdf("./SL gene oncoplot.pdf",12,8)
oncoplot(maf = target_maf, 
         clinicalFeatures = "cancertype", 
         sortByAnnotation = TRUE,
         top = 15, 
         showTumorSampleBarcodes = FALSE)
dev.off()

### for gene pairs survival analysis
node <- read.delim("./node-TF-gene.txt",header = T)
genes <- c(node$gene,node$TF)
genes <- unique(genes)
target_maf <- subsetMaf(maf, genes = genes)
for (i in 1:nrow(node)) {
print(node[i,])
pdf(paste0("./survival-SL/",node$gene[i],"_",node$TF[i],"_SL gene mutation_survival.pdf"),onefile = TRUE,4,4)
mafSurvival(maf = target_maf,
            genes = c(node$gene[i],node$TF[i]), 
            time = "time", 
            Status = "vital_status",
            groupNames = c("Mutant", "WT"),
            showConfInt = TRUE,
            addInfo = TRUE,
            isTCGA = TRUE,
            col = c("maroon", "royalblue")) 
dev.off()

}

somaticInteractions(maf = target_maf, 
                    genes = genelist$gene,
                    pvalue = 0.05, 
                    showCounts = TRUE)

tmb <- tmb(maf = target_maf, 
           captureSize = 35)
plotTMB(tmb, logScale = TRUE)


library(dplyr)
mygene <- read.table("./gene-interaction-number.txt",header = T,sep = "\t")
head(mygene)
mygene <- genelist$TCGA_Name

file <- list.files("./TCGA_CNV/Gene/",pattern = "*.txt")
table <- c()
for (i in file) {
  print(i)
  cancer <- strsplit(i,"_")[[1]][3]
  cancer <- strsplit(cancer,"\\.")[[1]][1]
  
  TCGA_gset <- read.table(paste0("./TCGA_CNV/Gene/cnv_gene_",cancer,".txt"),header = T,sep = "\t")
  colnames(TCGA_gset) <- substring(colnames(TCGA_gset),1,15)
  tumor_exp <- TCGA_gset[,str_sub(colnames(TCGA_gset),14,15)<10]
  tumor_exp.1 <- tumor_exp[tumor_exp$Gene.Symbol %in% mygene,]
  tumor_exp.1$mean <- apply(tumor_exp.1[,2:length(colnames(tumor_exp.1))],1,mean)
  tumor_exp.1$cnv <- ifelse(tumor_exp.1$mean > 0.2,"Amp",ifelse(tumor_exp.1$mean < -0.2,"Del","None"))
  tumor_exp.2 <- tumor_exp.1[tumor_exp.1$cnv != "None",]
  tumor_exp.2 <- tumor_exp.2[,c("Gene.Symbol","mean","cnv")]
  if (nrow(tumor_exp.2) >0) {
      tumor_exp.2$cancer <- cancer
  table <- rbind(tumor_exp.2,table)
 } 
}
library(ggplot2) 
library(ggExtra) 
library(ggh4x)
library(tidyr) 
table <- table[,c(1,2,4)]
df_wide <- pivot_wider(table, names_from = cancer, values_from = mean) 
df_wide.1 <- df_wide[,-1]
df_wide.1 <- data.frame(df_wide.1)
rownames(df_wide.1) <- df_wide$Gene.Symbol 
df_wide.1[is.na(df_wide.1)] <- 0
mat <- as.matrix(df_wide.1)  
library("ggheatmap")
library(ComplexHeatmap)
library(circlize)
test1 <- t(mat)
row_sum <- rowSums(test1)
col_sum <- colSums(test1)
get_color <- function(x) { 
  ifelse(x > 0, "#f87669", "#2fa1dd") 
} 

row_ha <- rowAnnotation( 
  Sum = anno_barplot(row_sum, 
                     axis_param = list(side="top"), 
                     bar_width = 0.6, 
                     gp = gpar(fill = get_color(row_sum), col=NA)), 
  show_annotation_name = FALSE 
)  
col_ha <- columnAnnotation( 
  Sum = anno_barplot(col_sum, 
                     axis_param = list(side="left"), 
                     bar_width = 0.6,  
                     gp = gpar(fill = get_color(col_sum), col=NA)), 
  show_annotation_name = FALSE 
) 


pdf(file = "./cnv.pdf",10.5,4.5)

Heatmap(test1,
        name = "CNV",
        col = colorRamp2(c(-0.2, 0, 0.2), c("#2fa1dd", "white", "#f87669")),
        cluster_rows = T,
        cluster_columns = T,
        row_names_gp = gpar(fontsize=8),
        column_names_gp = gpar(fontsize=8),
        top_annotation = col_ha,
        left_annotation = row_ha,
        border = NA
        
)
dev.off()

####methylation analysis 
library(ChAMP)
library(tibble)
library(tinyarray)
library(tidyr)
library(dplyr)
library(stringr)
library("ChAMP")
pd <- read.table("./methylation_BRCA_final.txt",
                 header = T,sep = "\t")
rownames(pd) <- pd[,1]
pd <- pd[,-1]
colnames(pd) <- str_sub(colnames(pd),1,15)
tumor.exp <- pd[,str_sub(colnames(pd),14,15) <10,]
normal.exp <- pd [,!str_sub(colnames(pd),14,15) <10,]
x <- c(rep("normal",length(colnames(normal.exp))),rep("tumor",length(colnames(tumor.exp))))
exp <- cbind(normal.exp,tumor.exp)
exp.1 <- as.matrix(exp)
rownames(exp.1) <- rownames(exp)
colnames(exp.1) <- x
library(limma)
group_list  <- x
design <- model.matrix(~0+factor(group_list))
colnames(design)=levels(factor(group_list))
rownames(design)=colnames(exprSet)
design
contrast.matrix<-makeContrasts(paste0(unique(group_list),collapse = "-"),levels = design)
contrast.matrix
fit <- lmFit(exp.1,design)
fit2 <- contrasts.fit(fit, contrast.matrix)
fit2 <- eBayes(fit2) 
tempOutput = topTable(fit2, coef=1, n=Inf)
nrDEG = na.omit(tempOutput)
DEG.sig <- nrDEG[which(abs(nrDEG$logFC) > 0.45 & nrDEG$P.Value < 0.05),]
gene <- strsplit(rownames(DEG.sig),"_") 
gene <- data.frame(gene)[2,]

mydata <- read_xlsx("./DifferentialMethylationTable.xlsx")
head(mydata)
data <- mydata
data <- data.frame(data)
library(ggplot2)
data$Fold=ifelse(data$fc > 0.28,0.28,data$fc)
data$Fold=ifelse(data$Fold< c(-0.28),-0.28,data$Fold)
data$FDR=ifelse(data$fdr< 0.00001,0.00001,data$fdr)
library(ggplot2) 
library(ggh4x) 
library(ggExtra)
pdf(file = "./methalation.pdf",12,2.8)
ggplot(data,aes(x=reorder(symbol, Fold, FUN = median),y=reorder(cancertype, Fold, FUN = median),
                fill=Fold))+
  geom_tile()+
  scale_fill_gradient2(low = "#0000ff", high = "#ff0000", midpoint = 0)+
  geom_text(aes(label=ifelse(abs(fc) > 0.28 & FDR < 0.05 ,"*","")),colour = "black", fontface = "bold")+
  xlab("Gene") + 
  ylab("Cancer type") + 
  theme(legend.position="top") +
  theme_bw() + 
  theme(panel.grid  = element_blank(), 
        panel.border  = element_rect(color = "black"), 
        axis.ticks  = element_blank()) +
    theme(axis.text.x=element_text(angle=90,hjust=1,vjust=0.5,colour = 1),
        axis.text.y=element_text(hjust=1,vjust=0.5,colour = 1))

dev.off()


##### enrichment analysis
mydata <- read.delim("./hepatocyte_hcc_deg-genes.txt",header = T)
library(ReactomePA)
library(tidyverse)
library(data.table)
library(org.Hs.eg.db)   
library(clusterProfiler) 
library(enrichplot)      
library(dplyr)
library(enrichplot)
library(clusterProfiler)
library(org.Hs.eg.db)
library(DOSE)
library(ReactomePA)
library(stringr)
deg <- read.table("./LIHC_TPM_limma_mRNA_DEG.txt",header=T,sep ="\t")

deg <- deg[rownames(deg) %in% mydata$Gene,]
gene_list <- data.frame(
  Gene = rownames(deg),
  Score = deg$logFC  
) %>%
  filter(is.finite(Score)) 
gene_ids <- mapIds(org.Hs.eg.db,
                   keys = gene_list$Gene,
                   column = "ENTREZID",   
                   keytype = "SYMBOL",    
                   multiVals = "first")   
gene_list$ENTREZID <- gene_ids
final_list <- gene_list %>%
  filter(!is.na(ENTREZID)) %>%
  arrange(desc(Score))
gene_scores <- final_list$Score
names(gene_scores) <- final_list$ENTREZID
geneList <- gene_scores
res1 <- enrichPathway(gene_ids)
res1 <- setReadable(res1, OrgDb = org.Hs.eg.db, keyType="ENTREZID")
res2 <- enrichGO(gene_ids, OrgDb = org.Hs.eg.db, ont = "ALL")
res2 <- setReadable(res2, OrgDb = org.Hs.eg.db, keyType="ENTREZID")
res3 <- gseKEGG(geneList     = geneList,
                organism     = 'hsa', 
                pvalueCutoff = 0.1)
res3 <- setReadable(res3, OrgDb = org.Hs.eg.db, keyType="ENTREZID", 
                    pvalueCutoff = 0.1)
data(geneList)
gene <- names(geneList)[abs(geneList) > 2]
res1 <- enrichPathway(gene)
res1 <- setReadable(res1, OrgDb = org.Hs.eg.db, keyType="ENTREZID")
res2 <- enrichGO(gene, OrgDb = org.Hs.eg.db, ont = "ALL")
res2 <- setReadable(res2, OrgDb = org.Hs.eg.db, keyType="ENTREZID")
res3 <- gseKEGG(geneList     = geneList,
                organism     = 'hsa')
res3 <- setReadable(res3, OrgDb = org.Hs.eg.db, keyType="ENTREZID")
df = res3@result
df = df[order(df$enrichmentScore),]
up = head(subset(df, enrichmentScore>0),5);up$group=1
down = tail(subset(df, enrichmentScore<0),5);down$group=-1
dat=rbind(up,down)
dat$pvalue = -log10(dat$pvalue)
dat$pvalue=dat$pvalue*dat$group 
dat=dat[order(dat$pvalue,decreasing = F),]
ggplot(dat, aes(x=reorder(Description,order(pvalue, decreasing = F)), y=pvalue, fill=group)) + 
  geom_bar(stat="identity", aes(fill=factor(group, levels = c(1,-1),  
                                            labels = c("ES>0","ES<0")))) + 
  xlab("Pathway names") +
  ylab("-log10(P.adj)") +
  coord_flip() + 
  scale_y_continuous(breaks=c(-4, -2, 0, 2, 4),
                     labels=c("4", "2", "0","2","4")) +
  scale_fill_manual(values = c("#ff6633","#34bfb5")) + 
  theme(plot.title = element_text(size = 15,hjust = 0.5),  
        axis.text = element_text(size = 12,face = 'bold'),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank(),
        legend.title = element_blank()) +
  ggtitle("Pathway Enrichment") 
gseaplot2(res3, geneSetID = 1:3, pvalue_table = T)
cnetplot(res1, foldChange=geneList,showCategory = 4, colorEdge = T, layout = "circle")
kegmt<-read.gmt("./c2.cp.kegg_medicus.v2024.1.Hs.entrez.gmt") 

KEGG<-GSEA(geneList,
           TERM2GENE = kegmt,
           minGSSize = 10,
           maxGSSize = 500,
           pvalueCutoff = 0.05,
           pAdjustMethod = "BH",
           seed = 456) 
gseaplot2(KEGG,1:3,color="red",pvalue_table = T) 
ridgeplot(KEGG,
          showCategory = 10,
          fill = "p.adjust", 
          core_enrichment = TRUE,
          label_format = 30,
          orderBy = "NES",
          decreasing = FALSE
)+
  theme(axis.text.y = element_text(size=8))

gsea_res_symbol <- setReadable(KEGG,"org.Hs.eg.db","ENTREZID")
GO_enrich = enrichGO(gene = final_list$ENTREZID,
                     OrgDb = org.Hs.eg.db, 
                     keyType = "ENTREZID", 
                     ont = "ALL",
                     pvalueCutoff = 1,qvalueCutoff = 1) 
GO_enrich_data  = data.frame(GO_enrich)
GO_enrich_data <- GO_enrich_data[which(GO_enrich_data$p.adjust < 0.05),]
KEGG_enrich = enrichKEGG(gene = final_list$ENTREZID,
                         keyType = "kegg",
                         pAdjustMethod = 'fdr', 
                         organism= "hsa",  
                         qvalueCutoff = 1, 
                         pvalueCutoff=1) 
KEGG_enrich_data  = data.frame(KEGG_enrich)
KEGG_enrich_data <- KEGG_enrich_data[which(KEGG_enrich_data$p.adjust < 0.05),]
GO_enrich_data_BP <- subset(GO_enrich_data, subset = GO_enrich_data$ONTOLOGY == "BP")
GO_enrich_data_CC <- subset(GO_enrich_data, subset = GO_enrich_data$ONTOLOGY == "CC")
GO_enrich_data_MF <- subset(GO_enrich_data, subset = GO_enrich_data$ONTOLOGY == "MF")

GO_enrich_data_filter <- rbind(GO_enrich_data_BP[1:5,], GO_enrich_data_CC[1:5,], GO_enrich_data_MF[1:5,])
GO_enrich@result <- GO_enrich_data_filter
KEGG_enrich@result <- KEGG_enrich_data
ncol(KEGG_enrich@result)
KEGG_enrich@result$ONTOLOGY <- "KEGG"
KEGG_enrich@result <- KEGG_enrich@result[,c(10,1:9)]
ego_GO_KEGG <- GO_enrich
ego_GO_KEGG@result <- rbind(ego_GO_KEGG@result, KEGG_enrich@result[1:3,])
ego_GO_KEGG@result$ONTOLOGY <- factor(ego_GO_KEGG@result$ONTOLOGY, levels = c("BP", "CC", "MF","KEGG"))##规定分组顺序

pdf("edger_diff_up_dotplot.pdf", width = 7, height = 7)
dotplot(ego_GO_KEGG, split = "ONTOLOGY", title="UP-GO&KEGG", label_format = 60, color = "pvalue") + 
  facet_grid(ONTOLOGY~., scale = "free_y")+
  theme(plot.title = element_text(hjust = 0.5, size = 13, face = "bold"), axis.text.x = element_text(angle = 90, hjust = 1))
dev.off()

cancer <- read.table("./sample.number.txt",header = T,sep = "\t")
cancer.1 <- cancer[cancer$tumor > 6,].
cancer.2 <- sort(cancer.1$cancer).
for (m in cancer.2) {
mut <- read.delim(paste0("./mutation/",m,"_mut.txt"),header = T).
mut <- mut[,c("Hugo_Symbol","Variant_Classification","Variant_Type","Tumor_Sample_Barcode","Consequence","BIOTYPE","SIFT","PolyPhen","Chromosome","Start_Position","End_Position")]
mut$Tumor_Sample_Barcode <- str_sub(mut$Tumor_Sample_Barcode,1,15)
mut.T <- mut[str_sub(mut$Tumor_Sample_Barcode,14,15) < 10,]
sl_gene <- read.delim("./sl-node.txt")
cli <- read.table(paste("./clinical/TCGA.",m,".sampleMap/",m,"_clinicalMatrix",sep = ""),header = T,sep = "\t")  
cli.1 <- cli[,c("X_PATIENT","vital_status","days_to_death","days_to_last_followup","age_at_initial_pathologic_diagnosis",
                "gender") ] 
cli.1$days_to_death = with(cli.1,ifelse(is.na(days_to_death),'',days_to_death))
cli.1$vital_status <- ifelse(cli.1$vital_status == "LIVING",0,1)
cli.1$time <- ifelse(cli.1$vital_status == 1, cli.1$days_to_death, cli.1$days_to_last_followup)
cli.1$gender <- ifelse(cli.1$gender=="MALE",1,2)

cli.1 <- cli.1[,c("X_PATIENT","vital_status","time","gender","age_at_initial_pathologic_diagnosis")]   

colnames(cli.1) <- c( "sampleID","status","time","gender","age")
cli.1$time <- as.numeric(cli.1$time)
cli.1 <- na.omit(cli.1)
cli.1$sampleID <- gsub("-",".",cli.1$sampleID)
table <- c()
for (i in 1:nrow(sl_gene)) {
  geneA <- sl_gene$geneA[i]
  geneB <- sl_gene$geneB[i]
  
  for (tt in unique(mut.T$Tumor_Sample_Barcode)){
  
  sample.group <- mut.T[mut.T$Tumor_Sample_Barcode==tt,]
  sample.group <- sample.group[,c("Hugo_Symbol","Tumor_Sample_Barcode")]
  samples_with_geneA <- unique(sample.group$Tumor_Sample_Barcode[sample.group$Hugo_Symbol == geneA]) 
  samples_with_geneB <- unique(sample.group$Tumor_Sample_Barcode[sample.group$Hugo_Symbol == geneB]) 
  samples_with_both <- intersect(samples_with_geneA, samples_with_geneB) 
  samples_with_one <- union(setdiff(samples_with_geneA, samples_with_geneB), setdiff(samples_with_geneB, samples_with_geneA)) 
  all_samples <- unique(sample.group$Tumor_Sample_Barcode) 
  samples_without_both <- setdiff(all_samples, union(samples_with_geneA, samples_with_geneB)) 
  if(length(unique(group$group)) == 3){
  mutgroup <- group
  head(mutgroup)
  colnames(mutgroup)[4] <- "sampleID"
  mutgroup$sampleID <- gsub("\\-",".",mutgroup$sampleID)
  mutgroup$sampleID <- gsub("\\.01","",mutgroup$sampleID)
  
  library(survminer)
  library(survival) 
  cli.2 <- merge(cli.1,mutgroup,by="sampleID")
  write.csv(cli.2,paste0("./cancer mutation/",m,"_",geneA,"_",geneB,"_mut_3_group.csv"),row.names = F)
  cli.3 <- cli.2[,c(1:3,16)]
  cli.3$group <- as.character(cli.3$group)
  cli.3 <- unique(cli.3)
  fit <- survfit(Surv((time), status) ~ group, data = cli.3)
  aa <- surv_pvalue(fit, method = "survdiff")
  pdf(file = paste0("./cancer mutation/",m,"_",geneA,"_",geneB,"_mut_3_group_survival.pdf"),onefile = TRUE,width=8,height=8)
  p=ggsurvplot(fit,
               data = cli.3,
               pval = TRUE, 
               conf.int = TRUE,
               palette = "hue",
               surv.median.line = "hv",
               risk.table = TRUE,
               main = paste0(m,"_",geneA,"_",geneB," mutation survival"),
               ggtheme = theme_bw(),
               legend.title = "Gene mutation",
               legend.labs = c(paste0(geneA," or ",geneB, " mut"), paste0(geneA," and ",geneB, " mut"), "None mut")
  )
  
  print(p)
  
  dev.off()
  aa <- surv_pvalue(fit, method = "survdiff")
  
  test <- cbind(cancer=m, gene = paste0(geneA,"_",geneB), pval=aa$pval)
  print(test)
  table <- rbind(table,test)
 
   
   }
  }
 }
  
}


