while  true ; do 
	for a in {1..10} ; do
		wget --delete 'http://soa-http.dev.ingress.mogok8s.net/testz?timeout=5' -q & 
	done
	sleep 1s
	for a in {1..10} ; do
		wget --delete 'http://soa-http.dev.ingress.mogok8s.net/testz?timeout=5' -q & 
	done
	sleep 1s
	for a in {1..10} ; do
		wget --delete 'http://soa-http.dev.ingress.mogok8s.net/testz?timeout=5' -q &
	done
	sleep 1s
	wait
	for a in {1..10} ; do
		wget --delete 'http://soa-http.dev.ingress.mogok8s.net/testz?timeout=5' > test.log 2>&1 &
	done
	sleep 1s
	wait
	grep 503 test.log
#	wget --delete http://soa-http.demo.ingress.mogok8s.net/cryptos/market_data/trans/_cryptos_market_data_499775d8-7f5a-4d40-ba0b-d4093de56250 -q &
 done

