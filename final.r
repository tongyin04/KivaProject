ls()
rm(list=ls())
setwd("/Volumes/Transcend/class/SI696")
library(readr)
library(pROC)
library (ROCR)

loans <- read_csv("/Volumes/Transcend/class/SI696/loans.csv")
loans[!is.na(loans$sector),]
loans[!is.na(loans$loan_amount),]
loans[!is.na(loans$repayment_term),]
loans[!is.na(loans$num_tags),]
loans=loans[loans$loan_amount <=10000,]
loans$status <- factor(loans$status)
loans$sector <- factor(loans$sector)
loans$id <-factor(loans$id)
loans$partner_id <-factor(loans$partner_id)
loans$repayment_interval <-factor(loans$repayment_interval)
loans$country_code <-factor(loans$country_code)
loans$bonus_credit_eligibility <- as.logical(loans$bonus_credit_eligibility)
loans$video_present <- as.logical(loans$video_present)

#(1 --> unfunded, 0--> funded)
loans$lgAmount=log(loans$loan_amount)
loans$funded_or_not <-rep(1,dim(loans)[1])
loans$funded_or_not[loans$status == 'defaulted' | loans$status == 'funded'| loans$status == 'in_repayment'| loans$status == 'paid'| loans$status == 'issue'| loans$status == 'refunded'] =0
loans$funded_or_not <-factor(loans$funded_or_not)

head(loans)

loansAllNotFund=loans[loans$funded_or_not==1,]
N1=dim(loansAllNotFund)[1]
test = sample(N1, as.integer(N1/5))
UnfundedTest =loansAllNotFund[test, ]
UnfundedTrain=loansAllNotFund[-test,]

loansAllFund=loans[loans$funded_or_not==0,]
N2=dim(loansAllFund)[1]
test2 = sample(N2, as.integer(N2/5))
fundedTest =loansAllFund[test2, ]
fundedTrain=loansAllFund[-test2,]

AllTest = rbind(UnfundedTest,fundedTest)
write.csv(AllTest, file = "AllTest.csv", row.names = FALSE)

##############Origanl Data#####################
AllTrain = rbind(UnfundedTrain,fundedTrain)
write.csv(AllTrain, file = "AllTrain.csv", row.names = FALSE)

glm.fit=glm(funded_or_not~sector+lgAmount+repayment_term +num_tags+ bonus_credit_eligibility,data=AllTrain ,family=binomial,maxit = 1000)
glm.probs=predict(glm.fit,AllTest,type="response")
png(filename="/Volumes/Transcend/class/SI696/Start.png")


modelroc <- roc(AllTest$funded_or_not,glm.probs) 
plot(modelroc, print.auc=TRUE, auc.polygon=TRUE, grid=c(0.1, 0.2),  
     grid.col=c("green", "red"), max.auc.polygon=TRUE,  
     auc.polygon.col="skyblue", print.thres=TRUE,main='ROC for Origanl Data') 
dev.off()
########function for Oversample
iteraion=fundedTrain
iteraion=rbind(UnfundedTrain,fundedTrain)
listAuc <-NULL
Weight  <-NULL
for (coun in 1:20){
  iteraion =  rbind(UnfundedTrain,iteraion)
  glm.fit=glm(funded_or_not~sector+lgAmount+repayment_term +num_tags+ bonus_credit_eligibility,data=iteraion ,family=binomial,maxit = 1000)
  glm.probs=predict(glm.fit,AllTest,type="response")
  modelroc <- roc(AllTest$funded_or_not,glm.probs) 
  listAuc <- append(listAuc, modelroc$auc)
  Weight <- append(Weight,coun)
}



########function for Undersample

discunt = seq(from =0.05, to =1,by=0.05)
nob=dim(fundedTrain)[1]
train1 = sample(nob, as.integer(nob*0.75))

listAucUnder <- NULL
Discounted <- NULL
discunt[1:2]
for (coun in discunt){
  trainIt = sample(nob, as.integer(nob*coun))
  fundedTrainIt =fundedTrain[trainIt, ]
  AllTrainIt = rbind(UnfundedTrain,fundedTrainIt)
  glm.fit=glm(funded_or_not~sector+lgAmount+repayment_term +num_tags+ bonus_credit_eligibility,data=AllTrainIt ,family=binomial,maxit = 1000)
  glm.probsIt=predict(glm.fit,AllTest,type="response")
  
  modelrocIt <- roc(AllTest$funded_or_not,glm.probsIt)
  
  listAucUnder <- append(listAucUnder, modelrocIt$auc)
  Discounted <- append(Discounted,coun)
  Discounted
  modelrocIt$auc
  
}


listAucUnder
Discounted

0.05

#> listAuc
#[1] 0.7319474 0.7322706 0.7324713 0.7326139 0.7327136 0.7328012 0.7328650 0.7329180 0.7329786 0.7330129 0.7330383 0.7330598 0.7330756 0.7330922 0.7331055 0.7331187 0.7331295 0.7331379 0.7331452 0.7331480
#> Weight
#[1]  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20

listAuc <- c(0.7319474, 0.7322706, 0.7324713, 0.7326139, 0.7327136 ,0.7328012, 0.7328650, 0.7329180, 0.7329786, 0.7330129, 0.7330383, 0.7330598, 0.7330756, 0.7330922, 0.7331055, 0.7331187, 0.7331295, 0.7331379, 0.7331452,0.7331480)
> Weight
[1]  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20

###############Oversample Unfunded w=200%
AllTrainOver2 = rbind(UnfundedTrain,AllTrain)
glm.fit=glm(funded_or_not~sector+lgAmount+repayment_term +num_tags+ bonus_credit_eligibility,data=AllTrainOver2 ,family=binomial,maxit = 1000)
glm.probs=predict(glm.fit,AllTest,type="response")
png(filename="/Volumes/Transcend/class/SI696/W200.png")
#glm.pred=rep("Funded",dim(AllTest)[1])
#glm.pred[glm.probs >.5]="UnFunded"
#table(glm.pred,AllTest$funded_or_not)

modelroc2 <- roc(AllTest$funded_or_not,glm.probs) 
plot(modelroc2, print.auc=TRUE, auc.polygon=TRUE, grid=c(0.1, 0.2),  
     grid.col=c("green", "red"), max.auc.polygon=TRUE,  
     auc.polygon.col="skyblue", print.thres=TRUE,main='ROC for Oversample Unfunded(w=200%)') 

dev.off()


###############Oversample Unfunded w=300%
AllTrainOver3 = rbind(UnfundedTrain,AllTrainOver2)
glm.fit=glm(funded_or_not~sector+lgAmount+repayment_term +num_tags+ bonus_credit_eligibility,data=AllTrainOver3 ,family=binomial,maxit = 1000)
glm.probs=predict(glm.fit,AllTest,type="response")
png(filename="/Volumes/Transcend/class/SI696/W300.png")


modelroc <- roc(AllTest$funded_or_not,glm.probs) 
plot(modelroc, print.auc=TRUE, auc.polygon=TRUE, grid=c(0.1, 0.2),  
     grid.col=c("green", "red"), max.auc.polygon=TRUE,  
     auc.polygon.col="skyblue", print.thres=TRUE,main='ROC for Oversample Unfunded(w=300%)') 
dev.off()

###############Oversample Unfunded w=400%
AllTrainOver4 = rbind(UnfundedTrain,AllTrainOver3)
glm.fit=glm(funded_or_not~sector+lgAmount+repayment_term +num_tags+ bonus_credit_eligibility,data=AllTrainOver4 ,family=binomial,maxit = 1000)
glm.probs=predict(glm.fit,AllTest,type="response")
png(filename="/Volumes/Transcend/class/SI696/W400.png")


modelroc <- roc(AllTest$funded_or_not,glm.probs) 
plot(modelroc, print.auc=TRUE, auc.polygon=TRUE, grid=c(0.1, 0.2),  
     grid.col=c("green", "red"), max.auc.polygon=TRUE,  
     auc.polygon.col="skyblue", print.thres=TRUE,main='ROC for Oversample Unfunded(w=400%)') 
dev.off()


###############Undersample Funded 
nob=dim(fundedTrain)[1]

train1 = sample(nob, as.integer(nob*0.75))
fundedTrainU1 =fundedTrain[train1, ]

train2 = sample(nob, as.integer(nob*0.5))
fundedTrainU2 =fundedTrain[train2, ]

train3 = sample(nob, as.integer(nob*0.33))
fundedTrainU3 =fundedTrain[train3, ]


###############Undersample Funded w=75%
AllTrainU1 = rbind(UnfundedTrain,fundedTrainU1)
write.csv(AllTrain, file = "AllTrain_fundedTrainU1.csv", row.names = FALSE)

glm.fit=glm(funded_or_not~sector+lgAmount+repayment_term +num_tags+ bonus_credit_eligibility,data=AllTrainU1 ,family=binomial,maxit = 1000)
glm.probsU1=predict(glm.fit,AllTest,type="response")

png(filename="/Volumes/Transcend/class/SI696/U75.png")
modelrocU1 <- roc(AllTest$funded_or_not,glm.probsU1) 
plot(modelrocU1, print.auc=TRUE, auc.polygon=TRUE, grid=c(0.1, 0.2),  
     grid.col=c("green", "red"), max.auc.polygon=TRUE,  
     auc.polygon.col="skyblue", print.thres=TRUE,main='ROC for Undersample W=75%') 
dev.off()

###############Undersample Funded w=50%
AllTrainU2 = rbind(UnfundedTrain,fundedTrainU2)
write.csv(AllTrain, file = "AllTrain_fundedTrainU2.csv", row.names = FALSE)

glm.fit=glm(funded_or_not~sector+lgAmount+repayment_term +num_tags+ bonus_credit_eligibility,data=AllTrainU2 ,family=binomial,maxit = 1000)
glm.probsU2=predict(glm.fit,AllTest,type="response")
png(filename="/Volumes/Transcend/class/SI696/U50.png")

modelrocU2 <- roc(AllTest$funded_or_not,glm.probsU2) 
plot(modelrocU2, print.auc=TRUE, auc.polygon=TRUE, grid=c(0.1, 0.2),  
     grid.col=c("green", "red"), max.auc.polygon=TRUE,  
     auc.polygon.col="skyblue", print.thres=TRUE,main='ROC for Undersample W=50%') 
dev.off()
###############Undersample Funded w=35%
AllTrainU3 = rbind(UnfundedTrain,fundedTrainU3)
write.csv(AllTrain, file = "AllTrain_fundedTrainU3.csv", row.names = FALSE)

glm.fit=glm(funded_or_not~sector+lgAmount+repayment_term +num_tags+ bonus_credit_eligibility,data=AllTrainU3 ,family=binomial,maxit = 1000)
glm.probsU3=predict(glm.fit,AllTest,type="response")
png(filename="/Volumes/Transcend/class/SI696/U35.png")

modelrocU3 <- roc(AllTest$funded_or_not,glm.probsU3) 
plot(modelrocU3, print.auc=TRUE, auc.polygon=TRUE, grid=c(0.1, 0.2),  
     grid.col=c("green", "red"), max.auc.polygon=TRUE,  
     auc.polygon.col="skyblue", print.thres=TRUE,main='ROC for Undersample W=35%')
dev.off()

ggplot(data =NULL, aes(Weight,listAuc))+geom_point(aes(colour = 'red'))+labs(x='Weight of UnFunded Loan',y ='AUC')+ggtitle("AUC and Weight of UnFunded Loan")+theme(plot.title = element_text(hjust = 0.5))
ggplot(data =NULL, aes(Discounted,listAucUnder))+geom_point(aes(colour = 'red'))+labs(x='Weight of UnFunded Loan',y ='AUC')+ggtitle("AUC and Weight of Funded Loan")+theme(plot.title = element_text(hjust = 0.5))

ggplot(data =NULL) + 
  geom_line(aes(x=Weight ,y = listAuc, colour = "red")) + 
  geom_line(aes(x=DiscountedTras ,y = listAucUnderTrans, colour = "blue"))



