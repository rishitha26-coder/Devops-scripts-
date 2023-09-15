#!/bin/bash

#for secret in amqp-default redis-default soa-api-default soa-db-default ; do
for secret in soa-db-default ; do
	vault kv get -format=json -field=data secrets/k8s/soa/kv/mogo-qa/$secret | sed -e "s/-qua/-dev/g" -e "s/_qua/_dev/g" -e 's/-qa/-dev/g' -e 's/\.qa\./.dev./g' -e 's/QUA/DEV/g' | \
		vault kv put -format=json -field=data secrets/k8s/soa/kv/mogo-dev/$secret -
	vault kv get -format=json -field=data secrets/k8s/soa/kv/mogo-qa/$secret | sed -e "s/-qua/-stg/g" -e "s/_qua/_fin/g" -e 's/-qa/-stg/g' -e 's/\.qa\./.staging./g' -e 's/QUA/Fin/g' | \
		vault kv put -format=json -field=data secrets/k8s/soa/kv/mogo-staging/$secret -
	vault kv get -format=json -field=data secrets/k8s/soa/kv/mogo-qa/$secret | sed -e "s/-qua/-dem/g" -e "s/_qua/_dem/g" -e 's/-qa/-dem/g' -e 's/\.qa\./.demo./g' -e 's/QUA/DEM/g' | \
		vault kv put -format=json -field=data secrets/k8s/soa/kv/mogo-demo/$secret -
	vault kv get -format=json -field=data secrets/k8s/soa/kv/mogo-qa/$secret | sed -e "s/-qua/-trg/g" -e "s/_qua/_trg/g" -e 's/-qa/-trg/g' -e 's/\.qa\./.training./g' -e 's/QUA/TRG/g' | \
		vault kv put -format=json -field=data secrets/k8s/soa/kv/mogo-training/$secret -
done
