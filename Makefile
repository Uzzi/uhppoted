DEBUG  ?= --debug
DIST   ?= development

.PHONY: debug
.PHONY: docker
.PHONY: simulator
.PHONY: uhppoted-rest
.PHONY: uhppoted-mqtt
.PHONY: uhppoted-app-s3
.PHONY: uhppoted-app-sheets
.PHONY: uhppoted-app-wild-apricot
.PHONY: bump
.PHONY: integration-tests

all: test      \
	 benchmark \
     coverage

clean:
	go clean
	rm -rf bin

format: 
	cd uhppote-core              && go fmt ./...
	cd uhppoted-api              && go fmt ./...
	cd uhppote-simulator         && go fmt ./...
	cd uhppote-cli               && go fmt ./...
	cd uhppoted-rest             && go fmt ./...
	cd uhppoted-mqtt             && go fmt ./...
	cd uhppoted-app-s3           && go fmt ./...
	cd uhppoted-app-sheets       && go fmt ./...
	cd uhppoted-app-wild-apricot && go fmt ./...
	cd integration-tests         && go fmt ./...
	go fmt ./...

build: format
	mkdir -p bin
	cd uhppote-core              && go build            ./...
	cd uhppoted-api              && go build            ./...
	cd uhppote-simulator         && go build -o ../bin/ ./...
	cd uhppote-cli               && go build -o ../bin/ ./...
	cd uhppoted-rest             && go build -o ../bin/ ./...
	cd uhppoted-mqtt             && go build -o ../bin/ ./...
	cd uhppoted-app-s3           && go build -o ../bin/ ./...
	cd uhppoted-app-sheets       && go build -o ../bin/ ./...
	cd uhppoted-app-wild-apricot && go build -o ../bin/ ./...

test: build
	cd uhppote-core              && go test ./...
	cd uhppoted-api              && go test ./...
	cd uhppote-simulator         && go test ./...
	cd uhppote-cli               && go test ./...
	cd uhppoted-rest             && go test ./...
	cd uhppoted-mqtt             && go test ./...
	cd uhppoted-app-s3           && go test ./...
	cd uhppoted-app-sheets       && go test ./...
	cd uhppoted-app-wild-apricot && go test ./...
#	go test ./...

vet: build
	go vet ./...

lint: build
	golint ./...

benchmark: build
	go test -bench ./...

coverage: build
	go test -cover ./...

integration-tests: 
	cd integration-tests; go fmt ./...
#	go test integration-tests/cli/*.go
	go test -v integration-tests/mqttd/*.go
	# go clean -testcache && go test -count=1 integration-tests/simulator/*.go

build-all: test vet
	mkdir -p dist/linux/$(DIST)
	mkdir -p dist/arm7/$(DIST)
	mkdir -p dist/darwin/$(DIST)
	mkdir -p dist/windows/$(DIST)
	mkdir -p dist/openapi/$(DIST)

	cd uhppote-cli; env GOOS=linux   GOARCH=amd64       go build -o ../dist/linux/$(DIST)    ./...
	cd uhppote-cli; env GOOS=linux   GOARCH=arm GOARM=7 go build -o ../dist/arm7/$(DIST)     ./...
	cd uhppote-cli; env GOOS=darwin  GOARCH=amd64       go build -o ../dist/darwin/$(DIST)   ./...
	cd uhppote-cli; env GOOS=windows GOARCH=amd64       go build -o ../dist/windows/$(DIST)  ./...

	cd uhppoted-rest; env GOOS=linux   GOARCH=amd64       go build -o ../dist/linux/$(DIST)   ./...
	cd uhppoted-rest; env GOOS=linux   GOARCH=arm GOARM=7 go build -o ../dist/arm7/$(DIST)    ./...
	cd uhppoted-rest; env GOOS=darwin  GOARCH=amd64       go build -o ../dist/darwin/$(DIST)  ./...
	cd uhppoted-rest; env GOOS=windows GOARCH=amd64       go build -o ../dist/windows/$(DIST) ./...

	cd uhppoted-mqtt; env GOOS=linux   GOARCH=amd64       go build -o ../dist/linux/$(DIST)   ./...
	cd uhppoted-mqtt; env GOOS=linux   GOARCH=arm GOARM=7 go build -o ../dist/arm7/$(DIST)    ./...
	cd uhppoted-mqtt; env GOOS=darwin  GOARCH=amd64       go build -o ../dist/darwin/$(DIST)  ./...
	cd uhppoted-mqtt; env GOOS=windows GOARCH=amd64       go build -o ../dist/windows/$(DIST) ./...	

	cd uhppoted-app-s3; env GOOS=linux   GOARCH=amd64       go build -o ../dist/linux/$(DIST)   ./...
	cd uhppoted-app-s3; env GOOS=linux   GOARCH=arm GOARM=7 go build -o ../dist/arm7/$(DIST)    ./...
	cd uhppoted-app-s3; env GOOS=darwin  GOARCH=amd64       go build -o ../dist/darwin/$(DIST)  ./...
	cd uhppoted-app-s3; env GOOS=windows GOARCH=amd64       go build -o ../dist/windows/$(DIST) ./...	

	cd uhppoted-app-sheets; env GOOS=linux   GOARCH=amd64       go build -o ../dist/linux/$(DIST)   ./...
	cd uhppoted-app-sheets; env GOOS=linux   GOARCH=arm GOARM=7 go build -o ../dist/arm7/$(DIST)    ./...
	cd uhppoted-app-sheets; env GOOS=darwin  GOARCH=amd64       go build -o ../dist/darwin/$(DIST)  ./...
	cd uhppoted-app-sheets; env GOOS=windows GOARCH=amd64       go build -o ../dist/windows/$(DIST) ./...	

	cd uhppoted-app-wild-apricot; env GOOS=linux   GOARCH=amd64       go build -o ../dist/linux/$(DIST)   ./...
	cd uhppoted-app-wild-apricot; env GOOS=linux   GOARCH=arm GOARM=7 go build -o ../dist/arm7/$(DIST)    ./...
	cd uhppoted-app-wild-apricot; env GOOS=darwin  GOARCH=amd64       go build -o ../dist/darwin/$(DIST)  ./...
	cd uhppoted-app-wild-apricot; env GOOS=windows GOARCH=amd64       go build -o ../dist/windows/$(DIST) ./...	

	cd uhppote-simulator; env GOOS=linux   GOARCH=amd64       go build -o ../dist/linux/$(DIST)   ./...
	cd uhppote-simulator; env GOOS=linux   GOARCH=arm GOARM=7 go build -o ../dist/arm7/$(DIST)    ./...
	cd uhppote-simulator; env GOOS=darwin  GOARCH=amd64       go build -o ../dist/darwin/$(DIST)  ./...
	cd uhppote-simulator; env GOOS=windows GOARCH=amd64       go build -o ../dist/windows/$(DIST) ./...

	cp uhppoted-rest/documentation/uhppoted-api.yaml      documentation/openapi/
	cp uhppote-simulator/documentation/simulator-api.yaml documentation/openapi/
	cp uhppoted-rest/documentation/uhppoted-api.yaml      install/openapi/
	cp uhppote-simulator/documentation/simulator-api.yaml install/openapi/
	cp -r install/openapi/* dist/openapi/$(DIST)/

	cp uhppoted-mqtt/documentation/TLS.md        cookbook/mqtt/
	cp uhppoted-mqtt/documentation/signatures.md cookbook/mqtt/
	cp uhppoted-app-s3/documentation/signing.md  cookbook/s3/

release: build-all docker integration-tests
	find . -name ".DS_Store" -delete
	tar --directory=dist/linux  --exclude=".DS_Store" -cvzf dist/$(DIST)-linux.tar.gz $(DIST)
	tar --directory=dist/arm7   --exclude=".DS_Store" -cvzf dist/$(DIST)-arm7.tar.gz $(DIST)
	tar --directory=dist/darwin --exclude=".DS_Store" -cvzf dist/$(DIST)-darwin.tar.gz $(DIST)
	cd dist/windows; zip --recurse-paths ../$(DIST)-windows.zip $(DIST)

build-github: 
	cd uhppote-core;              go build ./...
	cd uhppoted-api;              go build ./...
	cd uhppote-simulator;         go build ./...
	cd uhppote-cli;               go build ./...
	cd uhppoted-rest;             go build ./...
	cd uhppoted-mqtt;             go build ./...
	cd uhppoted-app-s3;           go build ./...
	cd uhppoted-app-sheets;       go build ./...
	cd uhppoted-app-wild-apricot; go build ./...

debug: build
	echo ">>> DEBUG"

simulator: 
	./bin/uhppote-simulator --debug --bind 0.0.0.0:60000 --rest 0.0.0.0:8000 --devices "./runtime/simulation/devices"

uhppoted-rest:
	./bin/uhppoted-rest --console

uhppoted-mqtt: 
	./bin/uhppoted-mqtt --console

swagger: 
	docker run --detach --publish 80:8080 --name swagger --rm swaggerapi/swagger-editor 
	sleep 1
	open http://127.0.0.1:80

docker:
	cd uhppote-simulator; env GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o ../docker/simulator     ./...
	cd uhppote-simulator; env GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o ../docker/uhppoted-rest ./...
	cd uhppote-simulator; env GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o ../docker/integration-tests/simulator ./...
	cd uhppoted-rest;     env GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o ../docker/uhppoted-rest ./...
	cd uhppoted-mqtt;     env GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o ../docker/uhppoted-mqtt ./...
	
	docker image     prune -f
	docker container prune -f
	cd ./docker/simulator;     docker build -f Dockerfile -t uhppoted/simulator . 
	cd ./docker/uhppoted-rest; docker build -f Dockerfile -t uhppoted/rest      . 
	cd ./docker/uhppoted-mqtt; docker build -f Dockerfile -t uhppoted/mqtt      . 
	cd ./docker/hivemq;        docker build -f Dockerfile -t hivemq/uhppoted    . 
	cd ./docker/integration-tests/simulator; docker build -f Dockerfile -t integration-tests/simulator . 
	cd ./docker/integration-tests/mqttd;     docker build -f Dockerfile -t integration-tests/mqttd     . 
	cd ./docker/integration-tests/hivemq;    docker build -f Dockerfile -t integration-tests/hivemq    . 

docker-simulator:
	docker run --detach --publish 8000:8000 --publish 60000:60000/udp --name simulator --rm uhppoted/simulator
	sleep 1
	./bin/uhppote-cli --debug set-listener 405419896 192.168.1.100:60001
	./bin/uhppote-cli --debug set-listener 303986753 192.168.1.100:60001
	./bin/uhppote-cli --debug set-listener 201020304 192.168.1.100:60001

docker-hivemq:
	docker run --detach --publish 8081:8080 --publish 1883:1883 --publish 8883:8883 --name hivemq --rm hivemq/uhppoted

docker-rest:
	docker run --detach --publish 8080:8080 --name restd --rm uhppoted/rest

docker-mqtt:
	docker run --detach --name mqttd --rm uhppoted/mqtt

docker-stop:
	docker stop $$(docker container ls -q)

docker-integration-tests:
	docker run --detach --publish 8000:8000 --publish 60000:60000/udp --name qwerty --rm integration-tests/simulator

hivemq-listen:
	mqtt subscribe --topic 'uhppoted/reply/#' | jq '.' 
#	mqtt subscribe --topic 'uhppoted/#' | jq '.' 
#	open runtime/mqtt-spy-0.5.4-jar-with-dependencies.jar



