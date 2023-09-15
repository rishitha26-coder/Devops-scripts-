which terraformer || brew install terraformer || exit 1
awsversion=3.44.0
mkdir -p ~/.terraform.d/plugins/darwin_amd64 && \
	cd ~/.terraform.d/plugins/darwin_amd64 && \
	wget https://releases.hashicorp.com/terraform-provider-aws/${awsversion}/terraform-provider-aws_${awsversion}_darwin_amd64.zip && \
	unzip terraform-provider-aws_${awsversion}_darwin_amd64.zip && \
	rm -f terraform-provider-aws_${awsversion}_darwin_amd64.zip || exit 1
