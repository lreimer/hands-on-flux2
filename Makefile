
iam-policy.json:
	@curl -o iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json
	q@aws iam create-policy \
		--policy-name AWSLoadBalancerControllerIAMPolicy \
		--policy-document file://iam-policy.json

create-dev-cluster: iam-policy.json
	@eksctl create cluster -f flux2-dev-cluster.yaml
	@eksctl create iamserviceaccount \
		--cluster=flux2-dev-cluster \
		--namespace=kube-system \
		--name=aws-load-balancer-controller \
		--attach-policy-arn=arn:aws:iam::$(AWS_ACCOUNT_ID):policy/AWSLoadBalancerControllerIAMPolicy \
		--approve

bootstrap-flux2-dev:
	@flux bootstrap github \
		--owner=$(GITHUB_USER) \
  		--repository=hands-on-flux2 \
  		--branch=env/dev \
  		--path=./clusters/flux2-dev-cluster \
		--components-extra=image-reflector-controller,image-automation-controller \
		--read-write-key \
  		--personal

create-prod-cluster: iam-policy.json
	@eksctl create cluster -f flux2-prod-cluster.yaml
	@eksctl create iamserviceaccount \
		--cluster=flux2-prod-cluster \
		--namespace=kube-system \
		--name=aws-load-balancer-controller \
		--attach-policy-arn=arn:aws:iam::$(AWS_ACCOUNT_ID):policy/AWSLoadBalancerControllerIAMPolicy \
		--approve

bootstrap-flux2-prod:
	@flux bootstrap github \
		--owner=$(GITHUB_USER) \
  		--repository=hands-on-flux2 \
  		--branch=env/prod \
  		--path=./clusters/flux2-prod-cluster \
		--components-extra=image-reflector-controller,image-automation-controller \
		--read-write-key \
  		--personal

delete-clusters: delete-dev-cluster delete-prod-cluster

delete-dev-cluster:
	@eksctl delete cluster -f flux2-dev-cluster.yaml

delete-prod-cluster:
	@eksctl delete cluster -f flux2-prod-cluster.yaml
