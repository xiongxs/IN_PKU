s=$1
c=$2
touch $s/$c.ing... && \
/data/bin/samtools view -h ../s03.samtools/$s/$c.bam \
|perl -ne 'print $_ and next if /^@/;my $met = $1 if/XM:Z:(\S+)/;next if ($met =~tr/HX/HX/)>=3;print $_'\
|perl samStat.pl /dev/stdin $s/$c.log \
|/data/bin/samtools view -uSb /dev/stdin \
|/data/bin/samtools mpileup -f /data/Analysis/liuxiaomeng/Database/mm9_splt/$c.fa /dev/stdin \
|perl covStrBed.pl /dev/stdin $s/ 1 \
|perl covStrBed.pl /dev/stdin $s/ 3 \
|perl GpC-modCytSplt.pl /datc/lilin/proj/guofan/NOMe-seq/MA-RRBS/rrbs_2014-09-02/dbSNP_129S1/$c.gz /data/Analysis/liuxiaomeng/Database/mm9_splt/$c.fa  \
/dev/stdin $s/$c. >/dev/null && \
mv $s/$c.ing... $s/$c.ok
