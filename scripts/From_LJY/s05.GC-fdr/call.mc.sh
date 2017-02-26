s=$1
c=$2
t="00.$s.run"
mkdir -p $t $s/info 
touch $t/$s.$c.ing... 
for k in GC GHC HHC;do 
   perl CallModC.pl $s INFO ../s04.GC-no3ch/$s/$c.$k.gz | perl SpltComb.pl /dev/stdin $s/$c.$k. >>$s/info/combSum.xls
   for j in + -;do 
      zcat $s/$c.$k.$j.gz | awk '{print $NF}' >$s/$c.$k.$j.gz.ptm 
      /data/Analysis/lilin/bin/calfdr $s/$c.$k.$j.gz.ptm $s/$c.$k.$j.gz.benj 
      perl CutP.pl 1e-2 $s/$c.$k.$j.gz.benj > $s/$c.$k.$j.gz.fdr1e-2 
      mv $s/$c.$k.$j.gz.benj $s/info 
      rm $s/$c.$k.$j.gz.ptm || exit
   done
done
mv $t/$s.$c.ing... $t/$s.$c.ok
