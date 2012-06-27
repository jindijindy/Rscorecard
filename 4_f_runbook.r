

###############################################################################
###############################################################################
# runbook
f_runbook <- function(datainput1=soft_model_scard){
# datainput1:  打分的结果数据

runbookdata <- data.frame(target=datainput1[,1],
score=rowSums(datainput1[,grep('score_',names(datainput1))]))
runbookdata <- runbookdata[runbookdata$target %in% c('0','1'),]
runbookdata <- runbookdata[order(runbookdata$score),]
# quantile(runbookdata$score,seq(0,1,0.1))
runbookdata$cutscore_10 <- cut(runbookdata$score,
c(0, quantile(runbookdata$score,seq(0.1,0.9,0.1)), round(max(runbookdata$score)/100+1)*100),right=F)
summary(runbookdata$cutscore_10)
runbook_10 <- data.frame(score=levels(runbookdata$cutscore_10),N=0,N1=0,N0=0,odds=0,badrate=0)
runbook_10$N0 <- table(runbookdata[,c('target','cutscore_10')])[1,]
runbook_10$N1 <- table(runbookdata[,c('target','cutscore_10')])[2,]
runbook_10$N <- table(runbookdata[,c('cutscore_10')])
runbook_10$odds <- runbook_10$N1 / runbook_10$N0
runbook_10$badrate <- runbook_10$N1 / runbook_10$N
runbook_10$cumsumn <- cumsum(runbook_10$N)
runbook_10$cumpn <- cumsum(runbook_10$N)/sum(runbook_10$N)
runbook_10$cumsum1 <- cumsum(runbook_10$N1)
runbook_10$cump1 <- cumsum(runbook_10$N1)/sum(runbook_10$N1)
runbook_10$cumsum0 <- cumsum(runbook_10$N0)
runbook_10$cump0 <- cumsum(runbook_10$N0)/sum(runbook_10$N0)
runbook_10$ks <- runbook_10$cump1 - runbook_10$cump0
print(max(runbook_10$ks))

runbook <- data.frame(score=unique(runbookdata$score),N=0,N1=0,N0=0,odds=0,badrate=0)
runbook$N0 <- table(runbookdata[,c('target','score')])[1,]
runbook$N1 <- table(runbookdata[,c('target','score')])[2,]
runbook$N <- table(runbookdata[,c('score')])
runbook$odds <- runbook$N1 / runbook$N0
runbook$badrate <- runbook$N1 / runbook$N
runbook$cumsumn <- cumsum(runbook$N)
runbook$cumpn <- cumsum(runbook$N)/sum(runbook$N)
runbook$cumsum1 <- cumsum(runbook$N1)
runbook$cump1 <- cumsum(runbook$N1)/sum(runbook$N1)
runbook$cumsum0 <- cumsum(runbook$N0)
runbook$cump0 <- cumsum(runbook$N0)/sum(runbook$N0)
runbook$ks <- runbook$cump1 - runbook$cump0
print(max(runbook$ks))

return(list(runbook_10=runbook_10,runbook=runbook))
}

# runbook <- f_runbook(datainput1=scard_data[[2]])

