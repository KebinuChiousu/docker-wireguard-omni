build: build-dep build-docker

build-dep:
	rm -rf docker/wireguard-omni/ui
	rsync -av docker/wireguard-ui/ docker/wireguard-omni/ui/ --exclude=.git --exclude=.github
build-docker:
	rm -rf docker/wireguard-omni/ui
	rsync -av docker/wireguard-ui/ docker/wireguard-omni/ui/ --exclude=.git --exclude=.github
	sudo docker build -t meredithkm/wireguard-omni docker/wireguard-omni/.