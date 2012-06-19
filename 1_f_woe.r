

###############################################################################
###############################################################################
# ������WOE������Ѿ���ɢ���ı�����
f_woe <- function(datainput0, varname0, yname0='bad'){
# datainput0: ��������ݼ�
# varname0:   ������ı�������,�ַ�
# yname0:     Ŀ���������,�ַ�,1��0��(���ֿ�ר��)

x <- datainput0[[varname0]]
y <- datainput0[[yname0]]
# �Ա�������Ϊȱʧֵ�������Ҫ��Ӧ��֮ǰ����ʱ�ʹ���á�
index <- which(y %in% c(0, 1) & (!is.na(x)))
x <- x[index]
y <- factor(y[index])

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
colnames(m) <- c(varname0, '#Total', '%Total', '#Good', '%Good', '#Bad', '%Bad', 'WOE', 'IV', 'Bad Rate')
print(m)
par(mfrow=c(2, 1), cex.axis=1, mar=c(2,4,3,1))
barplot(m[-nrow(m), 2], names.arg=m[-nrow(m), 1], main=paste('Freq_', varname0, sep=''))
plot(m$WOE[-nrow(m)], type='l', axes=F, xlab='', ylab='WOE', frame.plot=T, main=paste('WOE_', varname0, sep=''), lwd=5)
axis(side=2)
axis(side=1, at=seq_len(nrow(m)-1), labels=m[-nrow(m), 1])
}

if (length(x) <= 0){
m <- matrix(NA, nrow=4, ncol=10)
colnames(m) <- c(varname0, '#Total', '%Total', '#Good', '%Good', '#Bad', '%Bad', 'WOE', 'IV', 'Bad Rate')
winDialog('ok', paste('there are only NAs in this variable: ', varname0, sep=''))
}

}

# # traindata��ѵ����
# names(traindata)

# # ��ɢ��������
# summary(traindata$Cat_x1)
# traindata$c_Cat_x1 <- as.factor(traindata$Cat_x1)
# summary(traindata$c_Cat_x1)
# # levels(traindata$c_Cat_x1) <- paste(1:nlevels(traindata$c_Cat_x1), 
# # levels(traindata$c_Cat_x1), sep=': ')
# # summary(traindata$c_Cat_x1)
# # ���ȱʧֵ���ض�������������ȱʧ��һ���ǵ�����Ϊһ��
# # ����Ƿ����ȱʧ���򿴾���������п���ɾ��������¼
# # traindata$c_Cat_x1 <- as.character(traindata$c_Cat_x1)
# # traindata$c_Cat_x1[is.na(traindata$c_Cat_x1)] <- '0: missing'
# # traindata$c_Cat_x1 <- as.factor(traindata$c_Cat_x1)
# # summary(traindata$c_Cat_x1)
# f_woe(datainput0=traindata, varname0='c_Cat_x1', yname0='bad')

# # ������������
# summary(traindata$Quan_x1)
# plot(density(na.omit(traindata$Quan_x1)))
# quantile(traindata$Quan_x1, seq(0,1,0.1), na.rm=T)
# ����������λ��
# traindata$c_Quan_x1 <- cut(traindata$Quan_x1, c(0,5,15,40,100), 
# right=T, include.lowest=T)
# summary(traindata$c_Quan_x1)
# # levels(traindata$c_Quan_x1) <- paste(1:nlevels(traindata$c_Quan_x1), 
# # levels(traindata$c_Quan_x1), sep=': ')
# # summary(traindata$c_Quan_x1)
# # ���ȱʧֵ���ض�������������ȱʧ��һ���ǵ�����Ϊһ��
# # ����Ƿ����ȱʧ���򿴾���������п���ɾ��������¼
# # traindata$c_Quan_x1 <- as.character(traindata$c_Quan_x1)
# # traindata$c_Quan_x1[is.na(traindata$c_Quan_x1)] <- '0: missing'
# # traindata$c_Quan_x1 <- as.factor(traindata$c_Quan_x1)
# # summary(traindata$c_Quan_x1)
# f_woe(datainput0=traindata, varname0='c_Quan_x1', yname0='bad')

