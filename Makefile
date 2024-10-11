

docker:
	docker build --no-cache  --progress plain -t npo-poms/kaniko .


test:
	docker run -it --entrypoint /bin/sh npo-poms/kaniko


