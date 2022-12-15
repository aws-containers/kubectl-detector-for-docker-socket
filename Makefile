SHELL := bash
.PHONY: help dds eks-cluster

help:			## Show this help.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

dds: kubectl-dds	## Build kubectl-dds binary

kubectl-dds: clean
	goreleaser build --single-target --snapshot --rm-dist

eks-cluster:		## Create an eks cluster
	eksctl create cluster --auto-kubeconfig -f tests/eksctl.yaml

k8s-resources:		## Deploy manifests to k8s cluster
	kubectl apply -f tests/manifests/

e2e: eks-cluster k8s-resources dds		## Test binary in kind cluster with example resources
	./kubectl-dds
	kubectl delete -f tests/manifests
	kind delete cluster

clean:
	rm -f kubectl-dds licenses

THIRD_PARTY.txt: licenses
	cd licenses \
	&& dirname `find . -name LICENSE` | sed -e 's,\./,,g' > THIRD_PARTY.txt \
	&& echo -e "\n====================\n" >> THIRD_PARTY.txt \
	&& for FILE in `find . -name LICENSE`; do \
		echo -e "`dirname $$FILE | sed -e 's,\./,,g'`\n" >> THIRD_PARTY.txt \
		&& cat $$FILE >> THIRD_PARTY.txt \
		&& echo "" >> THIRD_PARTY.txt; \
	done
	mv licenses/THIRD_PARTY.txt ./

licenses:
	go-licenses save . --save_path ./licenses