main () {
echo '{ "Variables": {'
vault kv get -format json secrets/k8s/trade/kv/lambda-dev/$1| jq '.data.data.Variables | to_entries[]' | jq --raw-output  '"\"\(.key)\": \"#vault#secrets/k8s/trade/kv/lambda-@ENVIRONMENT@/secrets:XXX.\(.key)#\","' | \
	sed -e 's/XXX.CONTENTFUL/contentful.CONTENTFUL/g' \
		-e 's/XXX.BRAZE/braze-api.BRAZE/g' \
		-e 's/XXX.AWS/aws.AWS/g' \
		-e 's/XXX.MONGO_NAME/mongodb.MONGO_DATABASE/g' \
		-e 's/XXX.MONGO/mongodb.MONGO/g' \
		-e 's/XXX.NODE/node-env.NODE/g' \
		-e 's/XXX.QJ/qj-rds.QJ/g' \
		-e 's/XXX.QUOTE/quote-media.QUOTE/g' \
		-e 's/XXX.S3/s3.S3/g' \
		-e 's/XXX.CI/s3.CI/g' \
		-e 's/XXX.USER/s3.USER/g' \
		-e 's/XXX.ORDER/sns.ORDER/g' \
		-e 's/XXX.SOA_EVENT_QUEUE/sqs.SOA_EVENT_QUEUE/g' \
		-e 's/XXX.SOA/stonks-api.SOA/g' \
		-e 's/XXX.REQUEST/stonks-api.REQUEST/g' \
		-e 's/XXX.STONKS/stonks-api.STONKS/g' \
		-e 's/XXX.MARKET/stonks-api.MARKET/g' \
		-e 's/XXX.AWS_TRADE/trade-after-hours.AWS_TRADE/g' 
echo -n "}}" 
  }
echo $(main  "$@") | sed 's/, *}}/}}/g' | jq .
