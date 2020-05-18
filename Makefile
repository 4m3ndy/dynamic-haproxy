CHDIR_SHELL := $(SHELL)
define chdir
   $(eval _D=$(firstword $(1) $(@D)))
   $(info $(MAKE): cd $(_D)) $(eval SHELL = cd $(_D); $(CHDIR_SHELL))
endef

NAMESPACE = appz-operators

start:
	$(call chdir, sources)
	kopf run entrypoint.py --verbose

build_docker_image:
	docker build . -t service-proxy:v0.1.0 -f Dockerfile

apply_bundle:
	ls $(CURDIR)/deploy/bundle/* | xargs -I FILE sh -c \
		"cat FILE | awk '{gsub(/{{ NAMESPACE }}/, \"$(NAMESPACE)\")}1' \
			| kubectl apply -f -"

delete_bundle:
	ls -r $(CURDIR)/deploy/bundle/* |  xargs -I FILE sh -c \
		"cat FILE | awk '{gsub(/{{ NAMESPACE }}/, \"$(NAMESPACE)\")}1' \
			| kubectl delete --ignore-not-found=true -f -"

apply_crds:
	ls $(CURDIR)/deploy/crds/* | xargs -I NAME kubectl apply -f NAME

delete_crds:
	ls -r $(CURDIR)/deploy/crds/* | xargs -I NAME kubectl delete -f NAME

apply_objs:
	ls $(CURDIR)/deploy/objs/* | xargs -I NAME kubectl apply -f NAME

delete_objs:
	ls -r $(CURDIR)/deploy/objs/* | xargs -I NAME kubectl delete -f NAME

list_objs:
	kubectl get pods
	kubectl get services
	kubectl get statefulset
	kubectl get pvc
