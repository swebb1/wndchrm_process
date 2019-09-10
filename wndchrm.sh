
##usage sh wndchrm.sh <training data> <analytical data> [training]

OUT=wndchrm_output/$1_$2
mkdir -p $OUT

##Run wndchrm training
wndchrm train -m -l $1 $OUT/$1.fit

##Test the training set 30 times
wndchrm test -m -l -n30 $OUT/$1.fit $OUT/$1.html

##Run classification
wndchrm classify -l $OUT/$1.fit $2 > $OUT/$2.csv

##Parse CSV file to get plotting columns
python /usr/local/bin/csv_parse.py $OUT/$2.csv

##Get R output
R --no-save --args $OUT $2 < /usr/local/bin/wndchrm_to_phy.R
