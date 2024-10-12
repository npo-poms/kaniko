

docker:
	#docker build --no-cache  --progress  -t npo-poms/kaniko .
	docker build -t npo-poms/kaniko .


test:
	docker run -it --entrypoint /bin/sh npo-poms/kaniko
