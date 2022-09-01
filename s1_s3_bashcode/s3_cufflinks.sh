## usage: cufflinks.sh
ls  tophat_results/*/accept_hits.bam | while read id ; 
sampleID=` echo $id | cut -d"/" -f 2`
do 
nohup 
~/biosoft/Cufflinks/current/cufflinks -p 20 -o  cufflinks_results/$sampleID  $id 
done 
