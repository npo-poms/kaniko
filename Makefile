.PHONY: help docker test test-ghcr source

help:     ## Show this help.
	@sed -n 's/^##//p' $(MAKEFILE_LIST)
	@grep -h -E '^[/%a-zA-Z0-9._-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'


docker: ## Build locally
	#docker build --no-cache  --progress  -t npo-poms/kaniko .
	docker build -t npo-poms/kaniko .


test: docker ## give a shell to look around
	docker run -it --entrypoint /bin/sh -v $(shell pwd):/workspace npo-poms/kaniko


test-ghcr: docker ## give a shell to look around (ghcr image)
	docker run -it --entrypoint /bin/sh -v $(shell pwd):/workspace ghcr.io/npo-poms/kaniko:10


source:
	export KANIKO_SCRIPTS=$(pwd)/scripts;