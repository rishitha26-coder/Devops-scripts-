#!/bin/bash

sqlquery () {
YEAR="$1"
MONTH="$2"
if [[ "$MONTH" = "12" ]] ; then
   YEAR2="$(($YEAR + 1))"
   MONTH2="1"
else
   YEAR2="$YEAR1"
   MONTH2="$(($MONTH1 + 1))"
fi
cat <<EOF
SELECT * FROM soa_prod.third_party_requests 
WHERE created_at >= '$YEAR-$MONTH-01 00:00:00' AND created_at < '$YEAR-$MONTH-01 00:00:00'
INTO OUTFILE S3 's3://mogo-bi/soa_archive/soa_prod/third_party_requests/$YEAR-$MONTH'
CHARACTER SET utf8mb4 FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' MANIFEST OFF OVERWRITE ON;
EOF
}

for year in 2020 2021 2022 ; do
  for month in {1..12} ; do
    sqlquery $year $month
  done
done
