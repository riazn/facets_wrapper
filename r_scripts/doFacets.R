#!/cbio/ski/chan/home/riazn/programs/R/bin/Rscript 

library(facets)
library(Cairo)

# HAL Location
SDIR <- "/cbio/ski/chan/home/riazn/programs/FACETS.app/"

# SABA Locaiton
if ( is.na(file.info(SDIR)[1]) ) {
	SDIR <- "/home/riazn/programs/FACETS.app"
}

source(file.path(SDIR,"r_scripts/funcs.R"))
source(file.path(SDIR,"r_scripts/fPlots.R"))
source(file.path(SDIR,"r_scripts/nds.R"))

buildData=installed.packages()["facets",]
cat("#Module Info\n")
for(fi in c("Package","LibPath","Version","Built")){
    cat("#",paste(fi,":",sep=""),buildData[fi],"\n")
}
version=buildData["Version"]
cat("\n")

library(argparse)
parser=ArgumentParser()
parser$add_argument("-s","--snp_nbhd",type="integer",default=250,help="window size")
parser$add_argument("-c","--cval",type="integer",default=300,help="critical value for segmentation")
parser$add_argument("-m","--min_nhet",type="integer",default=25,
    help="minimum number of heterozygote snps in a segment used for bivariate t-statistic during clustering of segments")
parser$add_argument("--genome",type="character",default="hg19",help="Genome of counts file")
parser$add_argument("file",nargs=1,help="Paired Counts File")
args=parser$parse_args()

SNP_NBHD=args$snp_nbhd
CVAL=args$cval
MIN_NHET=args$min_nhet
FILE=args$file
BASE=basename(FILE)
BASE=gsub("countsMerged____","",gsub(".dat.*","",BASE))

sampleNames=gsub(".*recal_","",strsplit(BASE,"____")[[1]])
tumorName=sampleNames[1]
normalName=sampleNames[2]
projectName=gsub("_indel.*","",strsplit(BASE,"____")[[1]])[1]

TAG=paste("facets",projectName,tumorName,normalName,"cval",CVAL,sep="__")
TAG1=cc(projectName,tumorName,normalName)

switch(args$genome,
    hg19={
        data(hg19gcpct)
        chromLevels=c(1:22, "X")
    },
    mm9={
        data(mm9gcpct)
        chromLevels=c(1:19)
    },
    {
        stop(paste("Invalid Genome",args$genome))
    }
)

pre.CVAL=25
dat=preProcSample(FILE,snp.nbhd=SNP_NBHD,cval=pre.CVAL,chromlevels=chromLevels)
out=procSample(dat,cval=CVAL,min.nhet=MIN_NHET)


f<-paste("results/",TAG,"_BiSeg.png",sep="")
CairoPNG(file=f,height=1000,width=800)
plotSample(out,chromlevels=chromLevels)
text(-.08,-.08,paste(projectName,"[",tumorName,normalName,"]","cval =",CVAL),xpd=T,pos=4)
dev.off()

# Run EMCNCF (in original wrapper)
#fit=emcncf(out$jointseg,out$out,dipLogR=out$dipLogR)
# Updated for new version
fit=emcncf(out, trace=TRUE)

out$IGV=formatSegmentOutput(out,TAG1)
f<-paste("results/",TAG,".Rdata",sep="")
save(out,fit,file=f,compress=T)

ff<-paste("results/",TAG,".out",sep="")
cat("# TAG =",TAG1,"\n",file=f)
cat("# Version =",version,"\n",file=ff,append=T)
cat("# Input =",basename(FILE),"\n",file=ff,append=T)
cat("# snp.nbhd =",SNP_NBHD,"\n",file=ff,append=T)
cat("# cval =",CVAL,"\n",file=ff,append=T)
cat("# min.nhet =",MIN_NHET,"\n",file=ff,append=T)
cat("# genome =",args$genome,"\n",file=ff,append=T)
cat("# Project =",projectName,"\n",file=ff,append=T)
cat("# Tumor =",tumorName,"\n",file=ff,append=T)
cat("# Normal =",normalName,"\n",file=ff,append=T)
cat("# Purity =",fit$purity,"\n",file=ff,append=T)
cat("# Ploidy =",fit$ploidy,"\n",file=ff,append=T)
cat("# dipLogR =",fit$dipLogR,"\n",file=ff,append=T)
cat("# dipt =",fit$dipt,"\n",file=ff,append=T)
cat("# loglik =",fit$loglik,"\n",file=ff,append=T)
cat("# FLAG =",out$flags,"\n",file=ff,append=T)

f<-paste("results/",TAG,"_cncf.txt",sep="")
write.xls(cbind(out$IGV[,1:4],fit$cncf[,2:ncol(fit$cncf)]),
    file=f,row.names=F)

f<-paste("results/",TAG,"_CNCF.png",sep="")
CairoPNG(file=f,height=1100,width=850)
plotSampleCNCF(out,fit)
#plotSampleCNCF.custom(out$jointseg,out$out,fit,
#        main=paste(projectName,"[",tumorName,normalName,"]","cval =",CVAL))
dev.off()
