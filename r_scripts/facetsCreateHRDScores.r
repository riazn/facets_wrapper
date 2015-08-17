rm(list=ls());


# HAL Location
PDIR <- "/cbio/ski/chan/home/riazn/"
# SABA Locaiton
if ( is.na(file.info(PDIR)[1]) ) {
	PDIR <- "/home/riazn/"
}
#PDIR <- "/Users/nadeemriaz/cbio/";
source(paste(PDIR,"code/SNP_array/HRD/libHRD.r", sep=""));
source(paste(PDIR,"code/SNP_array/facets/libFacets.r", sep=""));


#### Argument Parsing
library(argparse)
parser=ArgumentParser()
parser$add_argument("sample_list",nargs=1,help="File Containing Samples to process (FACETS CCNF file list)")
parser$add_argument("output_dir",nargs=1,help="Output Location")
args=parser$parse_args()

sample_list <- args$sample_list
ODIR<-args$output_dir

#### End Arg Parisng




chromInfo<-GetChrominfo()
FILE_LIST <- scan(file=sample_list, what="character")


sampList <- c();
hrdScores <- c();
ntAIScores <- c();
lstScores <- c();
		
for (x in 1:length(FILE_LIST)) {
	fl <- FILE_LIST[x];
	# extract sample name from file name
	smp <-  strsplit(basename(fl), "__")[[1]][2]
	print(sprintf("Running sample %s", smp))
	
	cnv_f <- paste(fl, sep="");
	dat <- read.table(cnv_f, sep="\t",header=TRUE, stringsAsFactor=FALSE);

	dat <- fix_facets_column_names(dat);
	
	cdir <- paste(ODIR, sep="");
	if ( ! file.exists(cdir) ) {
		dir.create(cdir);
	}


	# FACETs has only 1 output, although we could use different segmentation cut offs
	segs <- fix_facet_segs(dat);

	hrd <- score_myriad_HRD(segs);
	ntai <- score_ntAI(segs, chromInfo, shrink=TRUE) 
	lst <- score_LST(segs, chromInfo);
	
	hrdScores <- c(hrdScores,hrd$score);
	ntAIScores <- c(ntAIScores,ntai$score);
	lstScores <- c(lstScores,lst$score)
	sampList <- c(sampList,smp);
	
	# make sure directory to output files exists
	outf <- paste(cdir, "/", smp, ".png", sep="");

	png(outf, width=2000, height=1300);
	par(mfrow=c(2,1), cex=2.0);
	plotASCATsegments(chromInfo, segs,0,1-segs[1,"NormalFraction"])
	title(smp);
	plotHRDSegments(chromInfo, hrd$segs, ntai$segs, lst$segs)
	dev.off();
}

df <- data.frame(samples=sampList, HRD=hrdScores, ntAI=ntAIScores, LST=lstScores);
outf <- paste(ODIR, "/", "hrd_calls.csv", sep="");
write.csv(df, file=outf, row.names=FALSE, quote=FALSE);

