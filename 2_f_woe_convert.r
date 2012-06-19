

###############################################################################
###############################################################################
# WOEת��
f_woe_convert <- function(datainput0, yname0='bad'){
# datainput0: ��������ݼ�(ֻ����Ԥ��Ŀ�꼰�������)
# yname0:     Ŀ���������,�ַ�,1��0��(���ֿ�ר��)

dataoutput <- datainput0
names(dataoutput)[which(names(datainput0) != yname0)] <- 
paste('WOE_', names(datainput0)[which(names(datainput0) != yname0)], sep='')

for(j in which(names(datainput0) != yname0)){
dataoutput[, j] <- NA
x <- datainput0[, j]
y <- datainput0[[yname0]]
# �м�״̬������Ҳ��Ҫת��WOE
index <- which(y %in% c(0, 1))
x <- x[index]
y <- factor(y[index])
X <- addmargins(table(x, y))
m <- data.frame(V=rownames(X), 
N=X[, 3],  P=X[, 3] / X[nrow(X), 3], 
N0=X[, 1], P0=X[, 1] / X[nrow(X), 1], 
N1=X[, 2], P1=X[, 2] / X[nrow(X), 2], 
WOE=NA)
rownames(m) <- NULL
m$WOE <- log(m$P1 / m$P0)
m$WOE[m$P1 == 0 | m$P0 == 0] <- NA
m[, -1] <- round(m[, -1], 4)
colnames(m) <- c('value', '#Total', '%Total', '#Good', '%Good', '#Bad', '%Bad', 'WOE')
m$value <- as.character(m$value)
for(k in 1:(nrow(m) - 1)){
dataoutput[which(datainput0[, j] == m$value[k]), j] <- m$WOE[k]
}
}
return(dataoutput)
}

# # traindata_filtered�Ǿ�������ɸѡ��ѵ����
# traindata_woe <- f_woe_convert(datainput0=na.omit(traindata_filtered), yname0='bad'){

