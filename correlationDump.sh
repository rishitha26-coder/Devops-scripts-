#!/bin/bash 

shopt -s extglob

for correlationId in $(cat $1) ; do
	memberEmail="$(getCorrelationIdMember.sh $correlationId)"
	memberUuid="$(mysql -Bse "select uuid from members where email_address = '$memberEmail';" soa_prod)"
	[[ -n "$memberUuid" ]] || echo "UUID Not found for correlation id $correlationId and email address $memberEmail"
	echo $correlationId ${memberEmail} ${memberUuid}
	mkdir -p ~/incident/${memberEmail}_${memberUuid}/ || continue
	./getMemberLogs.sh $memberEmail $memberUuid >> ~/incident/${memberEmail}_${memberUuid}/memberlogs_${correlation_Id}.json
done
