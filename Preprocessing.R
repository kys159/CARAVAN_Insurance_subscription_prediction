rm(list=ls())
setwd("C:/Users/82104/Desktop/TIC_The Insurance Company")

library(dplyr)
library(xgboost)
library(caret)
library(DMwR)
library(randomForest)
library(stringr)
library(mlbench)
library(caret)
library(corrplot)
library(car)
library(UBL)
library(ggbiplot)
library(factoextra)
library(ggplot2)

data<-read.csv("data.csv")
# Ÿ�ٺ��� ����
prop.table(table(data$CARAVAN))

str(data)
data$CARAVAN<-as.factor(data$CARAVAN)

colnames(data)
for(i in 44:64){
  ggplot(data, aes(y =data[,i] , x=CARAVAN, group=CARAVAN)) +
    geom_boxplot(fill="darkred") + ylab(colnames(data[i]))
  stat_summary(fun = mean, geom = "errorbar", color="white",
               aes(ymax = ..y.., ymin = ..y.., group =factor(CARAVAN)),
               width = 0.75, linetype = "dashed")
  ggsave(paste("C:/Users/82104/Desktop/TIC_The Insurance Company/boxplot/boxplot",i,".jpg",sep=""),
         width=20,height=20,units=c("cm"))
}


# �ٿ���ø�
set.seed(123)
data_down <- downSample(data, data$CARAVAN) %>% subset(select=-c(Class))
str(data_down)
table(data_down$CARAVAN)

# ���Ժ��� ������ �ö�
corrplot.mixed((data_down %>% select(starts_with("MINK")) %>% cor),upper="circle",lower="number",number.cex=1.5)
# ���� ���� ������ �ö�
corrplot.mixed((data_down %>% select(starts_with("A"),starts_with("P")) %>% cor),upper="circle",lower="number")

colnames(data_down)
# ����� �Ŀ��� ����
tmp <- ifelse((data_down %>% select(starts_with("P")))==0,0,
              ifelse((data_down %>% select(starts_with("P")))==1,25,
                     ifelse((data_down %>% select(starts_with("P")))==2,75,
                            ifelse((data_down %>% select(starts_with("P")))==3,150,
                                   ifelse((data_down %>% select(starts_with("P")))==4,350,
                                          ifelse((data_down %>% select(starts_with("P")))==5,750,
                                                 ifelse((data_down %>% select(starts_with("P")))==6,3000,
                                                        ifelse((data_down %>% select(starts_with("P")))==7,7500,
                                                               ifelse((data_down %>% select(starts_with("P")))==8,15000,
                                                                      ifelse((data_down %>% select(starts_with("P")))==9,25000,999999))))))))))

summary(tmp)
data_down<-cbind((data_down %>% select(-starts_with("P"))),tmp)
colnames(data_down)

#����Ÿ�� -> ����Ÿ�� ���
table(data_down$MOSTYPE,data_down$MOSHOOFD)
#������ -> �ڰ��� ���
table(data_down$MHHUUR,data_down$MHKOOP)
boxplot(data_down$MHHUUR~data_down$CARAVAN)
boxplot(data_down$MHKOOP~data_down$CARAVAN)

#���� -> ��ռ��� ���
cor(data_down %>% select(starts_with("MINK")))
#�����ǷẸ�� -> �����ǷẸ�� ���
table(data_down$MZFONDS,data_down$MZPART)
boxplot(data$MZFONDS~data$CARAVAN)
boxplot(data$MZPART~data$CARAVAN)

#����Ÿ��, ������,���� , �����ǷẸ���� 1�� �ֵ��� �����ϱ� ���ΰǰ� ���ź��� ����
data2 <- subset(data_down,select=-c(MOSTYPE,MHHUUR,MINKM30,MINK3045,MINK4575,MINK7512,MINK123M,MZFONDS))

data2

# ������, 3ä �̻��� ���� �����Ƿ� 2ä�� ������
table(data2$MAANTHUI,data2$CARAVAN)
table(data2$MAANTHUI)
data2$MAANTHUI[data2$MAANTHUI>=2]<-2

# ��ȥ����
data2$MRE <- as.vector(t(data2 %>% select(MRELGE) + data2 %>% select(MFGEKIND,MFWEKIND) %>% apply(1,sum)))
boxplot(data2$MRE~data2$CARAVAN)

# ���� ���� �ֳ� ���ķ� ����
data2$MAUT <- data2$MAUT1 + data2$MAUT2
table(data2$MAUT,data2$MAUT0)
boxplot(data2$MAUT~data2$CARAVAN)

# ��ȥ, �̱�, ����, ���� ����
data3 <- subset(data2, select=-c(MRELGE,MRELSA,MRELOV,MFALLEEN,MFGEKIND,MFWEKIND,MGODRK,MGODPR,MGODOV,MGODGE,MAUT0,MAUT1,MAUT2))
str(data3)

# ����� �ڽ��ö�
#tmp <- data3 %>% select(starts_with("P"), starts_with("A"),CARAVAN)
#dim(tmp)

#for(i in 1:42){
#  png(paste("C:/Users/82104/Desktop/TIC_The Insurance Company/fin_box/boxplot",i,".png",sep=""))
#  boxplot(tmp[,i]~tmp$CARAVAN,main=colnames(tmp)[i])
#  dev.off()
#}

# M���� �����ϴ� ������ ����� 3���� ����
fin_dat <- data3 %>% select(starts_with("M"),CARAVAN,PWAPART,PPERSAUT,PBRAND)

variableNames = c("MOSHOOFD","CARAVAN")
fin_dat[ , variableNames] = lapply(fin_dat[ , variableNames], factor)
str(fin_dat)