s=$1
for i in $(seq 1 19) X Y
do
sh call.mc.sh $s chr$i >>$s.run 2>>$s.e 
done

