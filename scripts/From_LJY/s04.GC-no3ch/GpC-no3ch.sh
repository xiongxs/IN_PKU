#sh shell.sh Hh

mkdir ./$1
touch $1.spikein.run...
/data/bin/samtools mpileup -f /data/Analysis/lilin/Database/UCSC_mouse_genome/bismark_mouse/lambda.fa ../s03.samtools/$1/lambda.bam \
|perl GpC-modCytSplt.pl /data/Analysis/lilin/Database/UCSC_mouse_genome/bismark_mouse/lambda.fa /dev/stdin $1/lambda. >/dev/null && \
 
mv $1.spikein.run...  $1.spikein.ok

for i in {1..19} X Y
do 
	sh GpC-raw.sh $1 chr$i
done

