library(tidyverse)
library(RColorBrewer)
library(ggtree)
library(Rphylip)
library(gtools)
library(forcats)

qual_col_pals = brewer.pal.info[brewer.pal.info$category == 'qual',]
col_vector = unlist(mapply(brewer.pal, qual_col_pals$maxcolors, rownames(qual_col_pals)))

args = commandArgs(trailingOnly = T)

##read in data
file=paste0(args[1],"/",args[2],".csv.tab")
t<-read.table(file,header=T,sep="\t",check.names = FALSE)

##select columns of interest and name rows
t2<-select(t,"norm. fact.":"act. class") %>% select(-"norm. fact.",-"act. class")
row.names(t2)<-t$image

##Mixed sort experiments as factor
t$`act. class`<-fct_relevel(t$`act. class`,mixedsort(levels(t$`act. class`)))

##map experiment names to colours
#tcols <-with(t,data.frame(class = levels(act..class),col = I(brewer.pal(nlevels(act..class), name = 'Dark2'))))
tcols <-with(t,data.frame(class = levels(`act. class`),col = col_vector[1:nlevels(`act. class`)]))

##Compute euclidean distance between rows and a neighbour joining tree
D2<-dist(t2,method="euclidean")
#nj<-nj(D2)
path="/usr/lib/phylip/bin/"
nj2<-Rneighbor(D2,path=path)

##using standard R plotting##

##Plot tree
#plot(nj,type="unrooted",show.tip.lab=F,cex=0.6)
plot=paste0(args[1],"/",args[2],".tree.pdf")
pdf(plot,height=8,width=8)
plot(nj2,type="unrooted",show.tip.lab=F,cex=0.6)
##Add labels
lab<-t$`act. class`[match(nj2$tip.label,t$image)]
cols<-as.character(tcols$col[match(t$`act. class`[match(nj2$tip.label,t$image)], tcols$class)])
tiplabels(text = lab,adj = c(0.5,0,5),frame = "none",col=cols)
dev.off()

##Using ggtree##

##associate tip IDs with an experiment
dd<-select(t,image,`act. class`)

##Create ggplot object
p<-ggtree(nj2,layout="equal_angle")
##Colour tips
p<- p %<+% dd + 
  geom_tippoint(aes(colour=`act. class`),size=4,alpha=0.4)+theme(legend.position=c(0.9,0.8)) +
  scale_color_manual(values = col_vector)
plot2=paste0(args[1],"/",args[2],".tree2.pdf")
ggsave(filename = plot2,plot = p)

###Barplots
tab<-select(t,`norm. fact.`:`act. class`) %>% select(-`norm. fact.`)
tab$ID<-as.factor(1:dim(tab)[1])
gtab<-gather(tab,Experiment,Value,-`act. class`,-ID)
gtab$Experiment <- as.factor(gtab$Experiment)
gtab$Experiment <- fct_relevel(gtab$Experiment,mixedsort(levels(gtab$Experiment)))

g3<-ggplot(gtab,aes(x=ID,y=Value,fill=Experiment))+
  geom_bar(position = "stack",stat="identity")+
  ggtitle(args[2])+theme_bw()+facet_wrap(~`act. class`,scales = "free")+
  theme(axis.text.x = element_text(angle = 90, hjust = 1))
plot3=paste0(args[1],"/",args[2],".bar.pdf")
ggsave(plot3,g3)

tab2<-select(t,`norm. fact.`:`act. class`) %>% select(-`norm. fact.`)
tab2$ID<-as.factor(1:dim(tab)[1])
library(forcats)
tab2$ID<-fct_relevel(tab2$ID,as.character(order(t$`pred. val.`,decreasing = F)))
gtab2<-gather(tab2,Experiment,Value,-`act. class`,-ID)
gtab2$Experiment <- as.factor(gtab2$Experiment)
gtab2$Experiment <- fct_relevel(gtab2$Experiment,mixedsort(levels(gtab2$Experiment)))

g4<-ggplot(gtab2,aes(x=ID,y=Value,fill=Experiment))+
  geom_bar(position = "stack",stat="identity")+
  ggtitle(args[2])+theme_bw()+facet_wrap(~`act. class`,scales = "free")+
  theme(axis.text.x = element_text(angle = 90, hjust = 1))
plot4=paste0(args[1],"/",args[2],".bar.sorted.pdf")
ggsave(plot4,g4)
