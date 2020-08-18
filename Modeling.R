# 데이터 계층분할 - 8:2로 train test 분할
set.seed(123)
train_index<-createDataPartition(fin_dat$CARAVAN,p=0.8,list=F)
train_tmp<-fin_dat[train_index,]
test<-fin_dat[-train_index,]
prop.table(table(train_tmp$CARAVAN))
prop.table(table(test$CARAVAN))


# PCA
tmp <- train_tmp %>% select(starts_with("MOP"),starts_with("MBER"),starts_with("MSK"))

set.seed(123)
tmp.fit<-prcomp(tmp, center = T, scale = T)

tmp.fit$rotation

# 누적 분산
vars <- apply(tmp.fit$x, 2, var)  
props <- vars / sum(vars)
props
cumsum(props)

# scree plot
fviz_eig(tmp.fit,barcolor = "darkred", barfill = "darkred")

# biplot
g <- ggbiplot(tmp.fit, 
              choices = c(1, 2), 
              obs.scale = 1, 
              var.scale = 1, 
              groups = train_tmp$CARAVAN, 
              ellipse = TRUE, circle = TRUE)
g <- g + scale_color_discrete(name = '') 
g <- g + theme(legend.direction = 'horizontal', legend.position = 'top')
print(g)


# pc 6 까지 사용
train_fin <- data.frame(cbind(train_tmp %>% select(-starts_with("MOP"),-starts_with("MBER"),-starts_with("MSK")),tmp.fit$x[,1:6]))
str(train_fin)

# 로지스틱
fit<-glm(CARAVAN ~ .,data=train_fin,family="binomial")
summary(fit)

# 다중공선성 확인
vif(fit)

# stepwise 
slm.fit<-step(fit,direction='both')
slm.fit$anova
summary(slm.fit)

#다중공선성
vif(slm.fit)

# type 3 sum of square
Anova(slm.fit,type="3")


# cross validation
set.seed(123)
fold_index <- createFolds(train_tmp$CARAVAN, k = 5, list=T)

optcut<-c()

for (i in 1:5){
  train <- train_tmp[-fold_index[[i]],]
  val <- train_tmp[fold_index[[i]],]
  
  tmp <- train %>% select(starts_with("MOP"),starts_with("MBER"),starts_with("MSK"))
  
  set.seed(123)
  tmp.fit2<-prcomp(tmp, center = T, scale = T)
  
  train_fin <- data.frame(cbind(train %>% select(-starts_with("MOP"),-starts_with("MBER"),-starts_with("MSK")),tmp.fit2$x[,1:6]))
  str(train_fin)
  
  # validation에는 pca predict로 적용
  val_fin<-data.frame(cbind(val %>% select(-starts_with("MOP"),-starts_with("MBER"),-starts_with("MSK")), predict(tmp.fit2,newdata=val %>% select(starts_with("MOP"),starts_with("MBER"),starts_with("MSK")))[,1:6]))
  str(val_fin)
  
  tmp_data<-subset(train_fin,select=c(MOSHOOFD,PPERSAUT,PBRAND,PC1,PC3,PC4,PC6,CARAVAN))
  tmp_val<-subset(val_fin,select=c(MOSHOOFD,PPERSAUT,PBRAND,PC1,PC3,PC4,PC6,CARAVAN))
  
  # 로지스틱
  fit<-glm(CARAVAN ~ .,data=tmp_data,family="binomial")
  summary(fit)
  
  # cut off 찾기
  p <- predict(fit, newdata=tmp_val, type="response")
  pr <- ROCR::prediction(p, tmp_val$CARAVAN)
  prf <- ROCR::performance(pr, measure = "tpr", x.measure = "fpr")
  optid<-(1:length(prf@y.values[[1]][-1]))[((prf@x.values[[1]][-1])^2 + (1-prf@y.values[[1]][-11])^2)
                                           ==min((prf@x.values[[1]][-1])^2 + (1-prf@y.values[[1]][-1])^2)]
  optcut<-c(optcut,prf@alpha.values[[1]][-1][optid])
  
  # roc 커브
  aa<-cbind(unlist(prf@x.values),unlist(prf@y.values))
  aa<-as.data.frame(aa)
  
  ggplot(aa,aes(x=V1,y=V2))+
    geom_line()+xlab("False Positive Rate")+ylab("True Positive Rate")+
    geom_segment(aes(x=0,y=0,xend=1,yend=1))+
    geom_segment(aes(x=prf@x.values[[1]][-1][optid],y=prf@y.values[[1]][-1][optid]+0.05,
                     xend=prf@x.values[[1]][-1][optid],yend=prf@y.values[[1]][-1][optid]),
                 arrow=arrow(ends="last",length=unit(0.2,"cm")),color="red",size=2)+
    annotate(geom = "text",x=prf@x.values[[1]][-1][optid],y=prf@y.values[[1]][-1][optid]+0.075,
             label=round(prf@alpha.values[[1]][-1][optid],4),
             colour = "brown",size=6)+
    ggtitle(paste("Fold",i," Validation set \nRoc Curve and Cut off point",sep=""))+
    theme(plot.title = element_text(color="red",size=17,face="bold.italic",hjust=0.5),
          axis.title.x = element_text(color="darkred",size=17,face="bold"),
          axis.title.y = element_text(color="darkred",size=17,face="bold"))
  ggsave(paste("C:/Users/82104/Desktop/TIC_The Insurance Company/roc",i,".jpg",sep=""),
         width=20,height=20,units=c("cm"))
  
}

# cut off
optcut
# cut off 평균
mean(optcut)

# 테스트셋에 최종 적용
test_fin<-data.frame(cbind(test %>% select(-starts_with("MOP"),-starts_with("MBER"),-starts_with("MSK")), predict(tmp.fit,newdata=test %>% select(starts_with("MOP"),starts_with("MBER"),starts_with("MSK")))[,1:6]))
las_test<-subset(test_fin,select=c(MOSHOOFD,PWAPART,PPERSAUT,PC1,PC3,PC4,PC6,CARAVAN))

pred<-as.factor(ifelse(predict(slm.fit,newdata=las_test,type="response")<=mean(optcut),"0","1"))

# test set 혼동행렬
confusionMatrix(pred,las_test$CARAVAN)
# train set 혼동행렬
confusionMatrix(as.factor(ifelse(predict(slm.fit,newdata=train_fin,type="response")<=mean(optcut),"0","1")),train_fin$CARAVAN)