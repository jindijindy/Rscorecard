

###############################################################################
###############################################################################
# �ַ�
f_format <- function(datainput, varname, type=c(1,2), fileout, n_groups=10){
# datainput: ��������ݼ�
# varname:   ������ı�������,�ַ�
# type:      1��ֵ2�ַ�
# fileout:   ������ļ���
# n_groups:  �ֳɼ���

x <- datainput[[varname]]

if (type == 2){
if (!is.factor(x)){
x <- as.factor(as.character(x))
}
x_format <- data.frame(y=levels(x), label=levels(x))
if(any(is.na(x))){
x_format <- rbind(x_format, data.frame(y='missing', label='0.missing'))
}
}

if (type == 1){
if (!is.numeric(x)){
x <- as.numeric(as.character(x))
}
x_format <- data.frame(y=sort(unique(round(c(
# -998, -997, 
max(x, na.rm=T) + 1, -99999,
quantile(na.rm=T, x[!x %in% c(-997, -998, -999)], seq(0, 1 - 1 / n_groups, 1 / n_groups)))))))
# ����ҿ�
if(any(is.na(x))){
x_format <- rbind(x_format, data.frame(y='missing -99999'))
}
}

sink(file=fileout, append=T)
print('# this is the start of a variable')
print(varname)
print(x_format)
print('# this is the end of a variable')
sink()
}



###############################################################################
###############################################################################
# ������WOE������Ѿ���ɢ���ı�����
f_woe_one <- function(datainput0, varname0, yname0){
# datainput0: ��������ݼ�
# varname0:   ������ı�������,�ַ�
# yname0:     Ŀ���������,�ַ�,1��0��(���ֿ�ר��)

x <- datainput0[[varname0]]
y <- datainput0[[yname0]]
index <- which(y %in% c(0, 1) & (!is.na(x)))
x <- x[index]
y <- y[index]
if (length(x) > 0){
X <- addmargins(table(x, y))
m <- data.frame(V=rownames(X), 
N=X[, 3],  P=X[, 3] / X[nrow(X), 3], 
N0=X[, 1], P0=X[, 1] / X[nrow(X), 1], 
N1=X[, 2], P1=X[, 2] / X[nrow(X), 2], 
WOE=NA, IV=NA, BadRate=X[, 1] / X[, 3])
rownames(m) <- NULL
m$WOE <- log(m$P1 / m$P0)
m$WOE[m$P1 == 0 | m$P0 == 0] <- NA
m$IV <- (m$P1 - m$P0) * m$WOE
m$IV[nrow(m)] <- sum(m$IV[-nrow(m)], na.rm=T)
m[, -1] <- round(m[, -1], 4)
colnames(m) <- c(varname0, '#Total', '%Total', '#Bad', '%Bad', '#Good', '%Good', 'WOE', 'IV', 'Bad Rate')
}
if (length(x) <= 0){
m <- matrix(NA, nrow=4, ncol=10)
colnames(m) <- c(varname0, '#Total', '%Total', '#Bad', '%Bad', '#Good', '%Good', 'WOE', 'IV', 'Bad Rate')
winDialog('ok', paste('there is only -999 in this variable: ', varname0, sep=''))
}
return(m)
}



###############################################################################
###############################################################################
# �������������飨����Ѿ���ɢ���ı�����
f_chisq_one <- function(datainput0, varname0, yname0){
# datainput0: ��������ݼ�
# varname0:   ������ı�������,�ַ�
# yname0:     Ŀ���������,�ַ�,1��0��(���ֿ�ר��)

x <- datainput0[[varname0]]
y <- datainput0[[yname0]]
index <- which(y %in% c(0, 1) & (!is.na(x)))
x <- x[index]
y <- y[index]
if (nlevels(x) >= 2){
z <- chisq.test(x, y)$p.value
}
if (nlevels(x) < 2){
z <- 999
winDialog('ok', paste('there is only one level in this variable: ', varname0, sep=''))
}
return(z)
}



###############################################################################
###############################################################################
# WOE����(csv�汾),���洢flag��woe�Ķ�Ӧ��ϵ,������IV��Pֵ�����ݼ�
f_woe <- function(datainput, filein, yname, filewoe, varlabels, varlist=NA){
# datainput: ��������ݼ�
# filein:    format���ļ���
# yname:     Ŀ���������,�ַ�,1��0��(���ֿ�ר��)
# filewoe:   woe����ļ���
# varlabels: ���ı�ǩ
# varlist:   ������ı���

flag_woe_list <- list()
df_iv_pvalue <- data.frame(var=NULL, IV=NULL, p_value=NULL)

formatfile <- readLines(filein)
index_start <- grep('# this is the start of a variable', formatfile)
index_end <- grep('# this is the end of a variable', formatfile)

imax <- length(index_start)

for (i in 1:imax){
varname <- formatfile[index_start[i] + 1]
varname <- strsplit(varname, '\"')[[1]][2]

if (is.na(varlist[1]) | varname %in% varlist){

new_varname <- paste('flag_', varname, sep='')
is_factor <- length(grep('label', formatfile[index_start[i] + 2])) > 0
main <- formatfile[(index_start[i] + 3) : (index_end[i] - 1)]
datainput[[new_varname]] <- NA

if (is_factor){
# �ַ�����
for(j in 1:length(main)){
main2 <- strsplit(main[j], ' ')[[1]]
main3 <- main2[main2 != '']
datainput[[new_varname]][datainput[[varname]] == main3[2]] <- main3[3]
}
datainput[[new_varname]][is.na(datainput[[new_varname]])] <- '0.other'
datainput[[new_varname]][datainput[[varname]] == (-999)] <- NA
datainput[[new_varname]] <- as.factor(datainput[[new_varname]])
}

if (!is_factor){
# ��ֵ����
main2 <- unlist(strsplit(main, ' '))
main3 <- main2[main2 != '']
main4 <- as.numeric(main3[c(F,T)])
datainput[[new_varname]] <- cut(datainput[[varname]], breaks=unique(main4), right=F, ordered_result=T)
datainput[[new_varname]][datainput[[varname]] == (-999)] <- NA
datainput[[new_varname]] <- factor(datainput[[new_varname]])
}

varlabels[, 1] <- as.character(varlabels[, 1])
varlabels[, 2] <- as.character(varlabels[, 2])
varlabel <- varlabels[varlabels[, 1] == varname, 2]
m0 <- matrix(NA, nrow=1, ncol=11)
colnames(m0) <- rep('', 11)
m0[1,1] <- varlabel
write.table(m0, filewoe, append=T, sep=',', row.names=F, na='')

m <- f_woe_one(datainput0=datainput, varname0=new_varname, yname0=yname)
chisq_p <- f_chisq_one(datainput0=datainput, varname0=new_varname, yname0=yname)

colnames(m)[1] <- gsub('flag_', '', colnames(m)[1])
m$chisq_p <- c(rep(NA, nrow(m)-1), chisq_p)

m1 <- matrix(NA, nrow=4, ncol=11)
colnames(m1) <- rep('', 11)
write.table(m, filewoe, append=T, sep=',', row.names=F, na='')
write.table(m1, filewoe, append=T, sep=',', row.names=F, na='')
# �����warning��������

flag_woe_list[[varname]] <- m

df_iv_pvalue <- rbind(df_iv_pvalue, data.frame(var=varname, IV=m$IV[nrow(m)], p_value=chisq_p))

print(c(i,date()))
}
}

return(list(data_flag=datainput, flag_woe=flag_woe_list, df_iv_pvalue=df_iv_pvalue))
# data_flag�洢����Ӧ�ķ�����Ϣ,flag_woe�洢�˷�����WOE�Ķ�Ӧ,df_iv_pvalue�洢��IV��Pֵ
}



###############################################################################
###############################################################################
# WOE����(������ʱ��������WOE����(knitr))
f_woe_adj <- function(datainput, filein, varname, type=c(1,2), yname, varlabels=NULL, is_complete=F){
# datainput:   ��������ݼ�
# filein:      format���ļ���
# varname:     ������ı�������,�ַ�
# type:        1��ֵ 2�ַ�
# yname:       Ŀ���������,�ַ�,1��0��(���ֿ�ר��)
# varlabels:   ���ı�ǩ
# is_complete: �Ƿ����ȫ���ֶ�.Ĭ��ֻ���Freq,WOE��IV��

formatfile <- readLines(filein)
index_var <- grep(paste('"', varname, '"', sep=''), formatfile)
index_end <- grep('# this is the end of a variable', formatfile)
index_end <- min(index_end[index_end > index_var])
main <- formatfile[(index_var + 2) : (index_end - 1)]
new_varname <- paste('flag_', varname, sep='')
datainput[[new_varname]] <- NULL

if (type == 2){
# �ַ�����
if(length(grep('missing', main)) == 1){
main2 <- strsplit(main[grep('missing', main)], ' ')[[1]]
main3 <- main2[main2 != '']
datainput[[new_varname]][is.na(datainput[[varname]])] <- main3[3]
}
for(j in 1:length(main)){
main2 <- strsplit(main[j], ' ')[[1]]
main3 <- main2[main2 != '']
datainput[[new_varname]][datainput[[varname]] == main3[2]] <- main3[3]
}
# datainput[[new_varname]][datainput[[varname]] == (-999)] <- NA
datainput[[new_varname]] <- as.factor(datainput[[new_varname]])
}

if (type == 1){
# ��ֵ����
datainput$tttmp <- datainput[[varname]]
if(length(grep('missing', main)) == 1){
main2 <- unlist(strsplit(main[grep('missing', main)], ' '))
main3 <- main2[main2 != '']
datainput$tttmp[is.na(datainput[[varname]])] <- as.numeric(main3[3])
main <- main[-grep('missing', main)]
}
main2 <- unlist(strsplit(main, ' '))
main3 <- main2[main2 != '']
main3 <- main3[c(F,T)]
main4 <- as.numeric(main3[main3 != 'missing'])
datainput[[new_varname]] <- cut(datainput$tttmp, breaks=unique(main4), right=F, ordered_result=T)
# datainput[[new_varname]][is.na(datainput[[new_varname]])] <- '0.missing'
# datainput[[new_varname]][datainput[[varname]] == (-999)] <- NA
datainput[[new_varname]] <- factor(datainput[[new_varname]])
}

# varlabels[, 1] <- as.character(varlabels[, 1])
# varlabels[, 2] <- as.character(varlabels[, 2])
# varlabel <- varlabels[varlabels[, 1] == varname, 2]

m <- f_woe_one(datainput0=datainput, varname0=new_varname, yname0=yname)
chisq_p <- f_chisq_one(datainput0=datainput, varname0=new_varname, yname0=yname)

colnames(m)[1] <- 'levels'
cat('\n', 'variable name: ', varname, '\n', '\n')
if (!is_complete){
m <- m[, c(1, 2, 8, 9)]
}
print(m)

par(mfrow=c(2, 1), cex.axis=1, mar=c(2,4,3,1))
barplot(m[-nrow(m), 2], names.arg=m[-nrow(m), 1], main=paste('Freq_', varname, sep=''))
plot(m$WOE[-nrow(m)], type='l', axes=F, xlab='', ylab='WOE', frame.plot=T, main=paste('WOE_', varname, sep=''), lwd=5)
axis(side=2)
axis(side=1, at=seq_len(nrow(m)-1), labels=m[-nrow(m), 1])

cat('\n', 'chisq_test: p_value = ', chisq_p, '\n')

}


# WOE�и�����и�õı���
f_woe_cut <- function(datainput0, datatrain0=datainput0, filein0, yname0='bad'){

# datainput0:   ��������ݼ�
# datatrain0:   ѵ������
# filein0:      format���ļ���
# yname0:       Ŀ���������,�ַ�,1��0��(���ֿ�ר��)

formatfile <- readLines(filein0)
index_start <- grep('# this is the start of a variable', formatfile)
index_end <- grep('# this is the end of a variable', formatfile)
imax <- length(index_start)

for (i in 1:imax){
varname <- formatfile[index_start[i] + 1]
varname <- strsplit(varname, '\"')[[1]][2]
is_factor <- length(grep('label', formatfile[index_start[i] + 2])) > 0
main <- formatfile[(index_start[i] + 3) : (index_end[i] - 1)]
new_varname <- paste('woeflag_', varname, sep='')
datainput0[[new_varname]] <- NA

if (is_factor){
# �ַ�����
datainput0[[varname]][!datainput0[[varname]] %in% datatrain0[[varname]]] <- NA
if(length(grep('missing', main)) == 1){
main2 <- strsplit(main[grep('missing', main)], ' ')[[1]]
main3 <- main2[main2 != '']
datainput0[[new_varname]][is.na(datainput0[[varname]])] <- main3[3]
}
for(j in 1:length(main)){
main2 <- strsplit(main[j], ' ')[[1]]
main3 <- main2[main2 != '']
datainput0[[new_varname]][datainput0[[varname]] == main3[2]] <- main3[3]
}
datainput0[[new_varname]] <- as.factor(datainput0[[new_varname]])
}

if (!is_factor){
# ��ֵ����
datainput0[[varname]][datainput0[[varname]] > max(datatrain0[[varname]], na.rm=T) & 
!is.na(datainput0[[varname]])] <- max(datatrain0[[varname]], na.rm=T)
datainput0[[varname]][datainput0[[varname]] < min(datatrain0[[varname]], na.rm=T) & 
!is.na(datainput0[[varname]])] <- min(datatrain0[[varname]], na.rm=T)
datainput0$tttmp <- datainput0[[varname]]
if(length(grep('missing', main)) == 1){
main2 <- unlist(strsplit(main[grep('missing', main)], ' '))
main3 <- main2[main2 != '']
datainput0$tttmp[is.na(datainput0[[varname]])] <- as.numeric(main3[3])
main <- main[-grep('missing', main)]
}
main2 <- unlist(strsplit(main, ' '))
main3 <- main2[main2 != '']
main3 <- main3[c(F,T)]
main4 <- as.numeric(main3[main3 != 'missing'])
datainput0[[new_varname]] <- cut(datainput0$tttmp, breaks=unique(main4), right=F, ordered_result=T)
datainput0[[new_varname]] <- factor(datainput0[[new_varname]])
}
}

return(datainput0[,grep(paste(yname0, '|woeflag_', sep=''), names(datainput0))])

}


# WOEת��
f_woe_convert <- function(datatrain, datatest, yname='bad'){

# datatrain:   ѵ������
# datatest:    ��������
# yname:       Ŀ���������,�ַ�,1��0��(���ֿ�ר��)

data_train_cut <- f_woe_cut(datainput0=datatrain, datatrain0=datatrain, filein0=filein, yname0='bad')
data_test_cut <- f_woe_cut(datainput0=datatest, datatrain0=datatrain, filein0=filein, yname0='bad')

for (i in 2:ncol(data_train_cut)){
varname <- names(data_train_cut)[i]
m <- f_woe_one(datainput0=data_train_cut, varname0=varname, yname0=yname)
woe_varname <- paste('woe_', varname, sep='')
data_train_cut[[woe_varname]] <- NA
data_test_cut[[woe_varname]] <- NA
for(k in 1:(nrow(m)-1)){
data_train_cut[[woe_varname]][as.character(data_train_cut[[varname]]) == as.character(m[k, 1])] <- m$WOE[k]
data_test_cut[[woe_varname]][as.character(data_test_cut[[varname]]) == as.character(m[k, 1])] <- m$WOE[k]
}
}

return(list(data_train_woe=data_train_cut[,grep(paste(yname, '|woe_woeflag_', sep=''), names(data_train_cut))],
data_test_woe=data_test_cut[,grep(paste(yname, '|woe_woeflag_', sep=''), names(data_test_cut))]))

}


# ģ������
f_model_eval <- function(model, trainset, testset, yname='bad'){
require(ROCR)
require(rpart)
if(class(model)[1] == 'rpart') score <- predict(model, trainset, type='prob')[, 2]
if(class(model)[1] == 'glm') score <- predict(model, type='response', trainset)
pred <- prediction(score, trainset[[yname]])
perf <- performance(pred, 'tpr', 'fpr')
print(max(attr(perf, 'y.values')[[1]] - attr(perf, 'x.values')[[1]]))
# performance(pred, 'auc')
if(class(model)[1] == 'rpart') score <- predict(model, testset, type='prob')[, 2]
if(class(model)[1] == 'glm') score <- predict(model, type='response', testset)
pred <- prediction(score, testset[[yname]])
perf <- performance(pred, 'tpr', 'fpr')
print(max(attr(perf, 'y.values')[[1]] - attr(perf, 'x.values')[[1]]))
# performance(pred, 'auc')
allset <- rbind(trainset, testset)
if(class(model)[1] == 'rpart') score <- predict(model, allset, type='prob')[, 2]
if(class(model)[1] == 'glm') score <- predict(model, type='response', allset)
pred <- prediction(score, allset[[yname]])
perf <- performance(pred, 'tpr', 'fpr')
print(max(attr(perf, 'y.values')[[1]] - attr(perf, 'x.values')[[1]]))
# performance(pred, 'auc')
}



# ����������
f_tree2rules <- function(model, labeled=F){
require(rpart)
if(!inherits(model, "rpart"))stop("Not a legitimate rpart tree")

frm0 <- model$frame
ylevels <- attr(model, "ylevels")
ds_size <- frm0[1, ]$n
frm <- frm0[order(frm0$yval2[, 5]), ]
ids <- row.names(frm)

sink(gsub('[: ]', '_', paste('rules_', format(Sys.time()), '.txt', sep='')))
for (i in 1:nrow(frm)){
if (frm[i, 1] == "<leaf>"){
# The following [, 5] is hardwired - needs work!
cat("\n")
cat(sprintf("Rule number: %s ", ids[i]))
cat(sprintf("[yval=%s cover=%d (%.0f%%) prob=%0.2f]\n",
ylevels[frm[i, ]$yval], frm[i, ]$n, round(100 * frm[i, ]$n / ds_size), frm[i, ]$yval2[, 5]))
pth <- path.rpart(model, nodes=as.numeric(ids[i]), print.it=FALSE)
cat(sprintf("%s\n", unlist(pth)[-1]), sep="")
}
}
sink()

if (labeled==T){
sink(gsub('[: ]', '_', paste('rules_label_', format(Sys.time()), '.txt', sep='')))
tmp <- read.csv('varlist.csv',head=T)
for (i in 1:nrow(frm)){
if (frm[i,1] == "<leaf>"){
# The following [,5] is hardwired - needs work!
cat("\n")
cat(sprintf("Rule number: %s ",ids[i]))
cat(sprintf("[yval=%s cover=%d (%.0f%%) prob=%0.2f]\n",
ylevels[frm[i, ]$yval], frm[i, ]$n, round(100 * frm[i, ]$n / ds_size), frm[i, ]$yval2[, 5]))
pth <- path.rpart(model, nodes=as.numeric(ids[i]), print.it=FALSE)
pth <- unlist(pth)[-1]
for (j in 1:nrow(tmp)){
pth <- gsub(paste('^', tmp[j, 1], sep=''), tmp[j, 2], pth)
}
cat(sprintf("%s\n",pth), sep="")
}
}
sink()
}
}




