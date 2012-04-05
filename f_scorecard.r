

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
}

if (type == 1){
if (!is.numeric(x)){
x <- as.numeric(as.character(x))
}
x_format <- data.frame(y=sort(unique(round(c(-998, -997, max(x) + 1, 
quantile(x[!x %in% c(-997, -998, -999)], seq(0, 1 - 1 / n_groups, 1 / n_groups)))))))
# ����ҿ�
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
m$IV[nrow(m)] <- sum(m$IV[-nrow(m)])
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
f_woe_adj <- function(datainput, filein, varname, type=c(1,2), yname, varlabels, is_complete=F){
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
for(j in 1:length(main)){
main2 <- strsplit(main[j], ' ')[[1]]
main3 <- main2[main2 != '']
datainput[[new_varname]][datainput[[varname]] == main3[2]] <- main3[3]
}
datainput[[new_varname]][is.na(datainput[[new_varname]])] <- '0.other'
datainput[[new_varname]][datainput[[varname]] == (-999)] <- NA
datainput[[new_varname]] <- as.factor(datainput[[new_varname]])
}

if (type == 1){
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






