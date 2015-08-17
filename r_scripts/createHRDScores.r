rm(list=ls());
PDIR <- "/Users/nadeemriaz/cbio/";
#PDIR <- "/cbio/ski/chan/home/riazn/"
MDIR <- paste(PDIR,"projects/peme-cis/facets/ver1/", sep="");
source(paste(PDIR,"code/SNP_array/HRD/libHRD.r", sep=""));
source(paste(PDIR,"code/SNP_array/facets/libFacets.r", sep=""));

chromInfo<-GetChrominfo()

f<-paste(MDIR,"results/",sep="")
FILE_LIST <- dir(f,"*.cncf.txt")


for (x in 1:length(FILE_LIST)) {
	fl <- FILE_LIST[x];
	# extract sample name from file name
	smp <-  strsplit(fl, "__")[[1]][2]
	print(sprintf("Running sample %s", smp))
	
	cnv_f <- paste(MDIR,"results/", fl, sep="");
	dat <- read.table(cnv_f, sep="\t",header=TRUE, stringsAsFactor=FALSE);

	dat <- fix_facets_column_names(dat);
	
	cdir <- paste(MDIR, "hrd/", sep="");
	if ( ! file.exists(cdir) ) {
		dir.create(cdir);
	}


	# FACETs has only 1 output, although we could use different segmentation cut offs
	segs <- fix_facet_segs(dat);
	sampList <- c();
	hrdScores <- c();
	ntAIScores <- c();
	lstScores <- c();
		
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
	plotHRDSegments(chromInfo, hrd$segs, ntai$segs, lst$segs)
	dev.off();
	
	
	df <- data.frame(samples=sampList, HRD=hrdScores, ntAI=ntAIScores, LST=lstScores);
	outf <- paste(cdir, "/", smp, "_hrd_calls.csv", sep="");
	write.csv(df, file=outf, row.names=FALSE, quote=FALSE);
}

