library(limma)
library(DESeq2)
library(edgeR)
library(baySeq)
library(pasilla)
library(pasilla)
library(Biobase)
library(CLL)
DEG_edger_classic <- function(exprSet=exprSet,group_list=group_list){
  d <- DGEList(counts=exprSet,group=factor(group_list))
  d.full <- d 

  keep <- rowSums(cpm(d)>100) >= 2
  d <- d[keep,]
  d$samples$lib.size <- colSums(d$counts)
  d <- calcNormFactors(d)
  
  png("MDS.png")
  plotMDS(d, method="bcv", col=as.numeric(d$samples$group))
  legend("bottomleft", as.character(unique(d$samples$group)), col=1:3, pch=20)
  dev.off()
  
  d1 <- estimateCommonDisp(d, verbose=T)
  d1 <- estimateTagwiseDisp(d1)
  
  png("BCV.png")
  plotBCV(d1)
  dev.off()
  
  et12 <- exactTest(d1) 
  
  png("MA.png")
  de1 <- decideTestsDGE(et12, adjust.method="BH", p.value=0.05)
  de1tags12 <- rownames(d1)[as.logical(de1)] 
  plotSmear(et12, de.tags=de1tags12)
  dev.off()
  
  nrDEG=topTags(et12, n=nrow(exprSet))
  nrDEG=as.data.frame(nrDEG)
  #write.csv(nrDEG,"edger_classic.results.csv",quote = F)
  
}

DEG_edger_glm <- function(exprSet=exprSet,group_list=group_list){
  d <- DGEList(counts=exprSet,group=factor(group_list))
  d.full <- d
  keep <- rowSums(cpm(d)>100) >= 2
  d <- d[keep,]
  d$samples$lib.size <- colSums(d$counts)
  d <- calcNormFactors(d)   
  
  png("MDS.png")
  plotMDS(d, method="bcv", col=as.numeric(d$samples$group))
  legend("bottomleft", as.character(unique(d$samples$group)), col=1:3, pch=20)
  dev.off()
  
  design.mat <- model.matrix(~ 0 + d$samples$group)
  colnames(design.mat) <- levels(d$samples$group)
  d2 <- estimateGLMCommonDisp(d,design.mat)
  d2 <- estimateGLMTrendedDisp(d2,design.mat, method="auto")
  # method:  "auto", "bin.spline", "power", "spline", "bin.loess".
  d2 <- estimateGLMTagwiseDisp(d2,design.mat)
  
  png("BCV.png")
  plotBCV(d2)
  dev.off()
  
  fit <- glmFit(d2, design.mat)
  lrt12 <- glmLRT(fit)
  
  png("MA.png")
  de2 <- decideTestsDGE(lrt12, adjust.method="BH", p.value = 0.05)
  de2tags12 <- rownames(d2)[as.logical(de2)]
  plotSmear(lrt12, de.tags=de2tags12)
  abline(h = c(-2, 2), col = "blue")
  dev.off()
  
  nrDEG=topTags(lrt12, n=nrow(exprSet))
  nrDEG=as.data.frame(nrDEG)
  #write.csv(nrDEG,"edger_glm.results.csv",quote = F)
}

data(pasillaGenes)
exprSet=counts(pasillaGenes)
samples=sampleNames(pasillaGenes)
pdata=pData(pasillaGenes)[,c("condition","type")]
group_list=as.character(pdata[,1])
DEG_results=DEG_edger_glm(exprSet,group_list)


