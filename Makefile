CLI = ./bin/uhppote-cli
SIMULATOR = ./bin/uhppote-simulator
DEBUG ?= --debug
LOCAL ?= 192.168.1.100:51234
CARD ?= 6154410
SERIALNO ?= 423187757
DOOR ?= 3
DIST ?= development
DATETIME = $(shell date "+%Y-%m-%d %H:%M:%S")
VERSION = v0.5.x
LDFLAGS = -ldflags "-X uhppote.VERSION=$(VERSION)" 

all: test      \
	 benchmark \
     coverage

clean:
	go clean
	rm -rf bin

format: 
	go fmt uhppote...

build: format
	go install $(LDFLAGS) uhppote-cli
	go install $(LDFLAGS) uhppoted-rest
	go install $(LDFLAGS) uhppoted/uhppoted-mqtt
	go install $(LDFLAGS) uhppote-simulator

test: build
	go test uhppote...

vet: build
	go vet uhppote...

lint: build
	golint uhppote...

benchmark: build
	go test -bench uhppote...

coverage: build
	go test -cover uhppote...

integration-tests: build
	go fmt src/integration-tests/cli/*.go
	go fmt src/integration-tests/mqttd/*.go
#	go test src/integration-tests/cli/*.go
	go test src/integration-tests/mqttd/*.go

release: test vet
	mkdir -p dist/$(DIST)/windows
	mkdir -p dist/$(DIST)/darwin
	mkdir -p dist/$(DIST)/linux
	mkdir -p dist/$(DIST)/openapi
	env GOOS=linux   GOARCH=amd64  go build -o dist/$(DIST)/linux/uhppote-cli             uhppote-cli
	env GOOS=darwin  GOARCH=amd64  go build -o dist/$(DIST)/darwin/uhppote-cli            uhppote-cli
	env GOOS=windows GOARCH=amd64  go build -o dist/$(DIST)/windows/uhppote-cli.exe       uhppote-cli
	env GOOS=linux   GOARCH=amd64  go build -o dist/$(DIST)/linux/uhppoted-rest           uhppoted-rest
	env GOOS=darwin  GOARCH=amd64  go build -o dist/$(DIST)/darwin/uhppoted-rest          uhppoted-rest
	env GOOS=windows GOARCH=amd64  go build -o dist/$(DIST)/windows/uhppoted-rest.exe     uhppoted-rest
	env GOOS=linux   GOARCH=amd64  go build -o dist/$(DIST)/linux/uhppoted-mqtt           uhppoted/uhppoted-mqtt
	env GOOS=darwin  GOARCH=amd64  go build -o dist/$(DIST)/darwin/uhppoted-mqtt          uhppoted/uhppoted-mqtt
	env GOOS=windows GOARCH=amd64  go build -o dist/$(DIST)/windows/uhppoted-mqtt.exe     uhppoted/uhppoted-mqtt
	env GOOS=linux   GOARCH=amd64  go build -o dist/$(DIST)/linux/uhppote-simulator       uhppote-simulator
	env GOOS=darwin  GOARCH=amd64  go build -o dist/$(DIST)/darwin/uhppote-simulator      uhppote-simulator
	env GOOS=windows GOARCH=amd64  go build -o dist/$(DIST)/windows/uhppote-simulator.exe uhppote-simulator
	cp -r install/openapi/* dist/$(DIST)/openapi/

release-tar: release
	tar --directory=dist --exclude=".DS_Store" -cvzf dist/$(DIST).tar.gz $(DIST)

usage: build
	$(CLI)

debug: build
	go test src/uhppoted/kvs/*.go

help: build
	$(CLI)       help
	$(CLI)       help get-devices
	$(SIMULATOR) help
	$(SIMULATOR) help new-device

version: build
	$(CLI)       version
	$(SIMULATOR) version

get-devices: build
	$(CLI) --bind $(LOCAL) $(DEBUG) get-devices

get-device: build
	$(CLI) --bind $(LOCAL) $(DEBUG) get-device $(SERIALNO)

set-address: build
	$(CLI) -bind $(LOCAL) $(DEBUG) set-address $(SERIALNO) '192.168.1.125' '255.255.255.0' '0.0.0.0'

get-status: build
	$(CLI) --bind $(LOCAL) $(DEBUG) get-status $(SERIALNO)

get-time: build
	$(CLI) --bind $(LOCAL) $(DEBUG) get-time $(SERIALNO)

set-time: build
	$(CLI) --bind $(LOCAL) $(DEBUG) set-time $(SERIALNO)
	$(CLI) --bind $(LOCAL) $(DEBUG) set-time $(SERIALNO) "$(DATETIME)"

get-door-delay: build
	$(CLI) --bind $(LOCAL) $(DEBUG) get-door-delay $(SERIALNO) $(DOOR)

set-door-delay: build
	$(CLI) --bind $(LOCAL) $(DEBUG) set-door-delay $(SERIALNO) $(DOOR) 5

get-door-control: build
	$(CLI) --bind $(LOCAL) $(DEBUG) get-door-control $(SERIALNO) $(DOOR)

set-door-control: build
	$(CLI) --bind $(LOCAL) $(DEBUG) set-door-control $(SERIALNO) $(DOOR) 'normally closed'

get-listener: build
	$(CLI) --bind $(LOCAL) $(DEBUG) get-listener $(SERIALNO)

set-listener: build
	$(CLI) --bind $(LOCAL) $(DEBUG) set-listener $(SERIALNO) 192.168.1.100:40000

get-cards: build
	$(CLI) --bind $(LOCAL) $(DEBUG) get-cards $(SERIALNO)

get-card: build
	$(CLI) $(DEBUG) get-card $(SERIALNO) $(CARD)

grant: build
	$(CLI) $(DEBUG) grant $(SERIALNO) $(CARD) 2019-01-01 2019-12-31 1,2,3,4

revoke: build
	$(CLI) $(DEBUG) revoke $(SERIALNO) $(CARD)

revoke-all: build
	$(CLI) --bind $(LOCAL) $(DEBUG) revoke-all $(SERIALNO)

load-acl: build
	$(CLI) --config .UTO311-L04 $(DEBUG) load-acl debug.tsv

get-events: build
	$(CLI) --bind $(LOCAL) $(DEBUG) get-events $(SERIALNO)

get-event-index: build
	$(CLI) --bind $(LOCAL) $(DEBUG) get-event-index $(SERIALNO)

set-event-index: build
	$(CLI) --bind $(LOCAL) $(DEBUG) set-event-index $(SERIALNO) 23

open: build
	$(CLI) --bind $(LOCAL) $(DEBUG) open $(SERIALNO) 1

listen: build
	$(CLI) --listen 192.168.1.100:60001 $(DEBUG) listen 

simulator: build
	./bin/uhppote-simulator --debug --devices "./runtime/simulation/devices"

simulator-device: build
	./bin/uhppote-simulator --debug --devices "runtime/simulation/devices" new-device 678

uhppoted-rest: build
	./bin/uhppoted-rest --console --debug 

uhppoted-rest-daemonize: build
	sudo ./bin/uhppoted-rest daemonize

uhppoted-rest-undaemonize: build
	sudo ./bin/uhppoted-rest undaemonize

uhppoted-rest-version: build
	./bin/uhppoted-rest version

uhppoted-rest-help: build
	./bin/uhppoted-rest help
	./bin/uhppoted-rest help commands
	./bin/uhppoted-rest help version
	./bin/uhppoted-rest help help

uhppoted-rest-linux: build
	mkdir -p ./dist/development/linux
	env GOOS=linux GOARCH=amd64 go build -o dist/development/linux/uhppoted-rest uhppoted-rest

uhppoted-rest-windows: build
	mkdir -p ./dist/development/windows
	env GOOS=windows GOARCH=amd64 go build -o dist/development/windows/uhppoted-rest.exe uhppoted-rest

uhppoted-mqtt: build
	./bin/uhppoted-mqtt --console

uhppoted-mqtt-help: build
	./bin/uhppoted-mqtt help
	./bin/uhppoted-mqtt help commands
	./bin/uhppoted-mqtt help version
	./bin/uhppoted-mqtt help help

uhppoted-mqtt-version: build
	./bin/uhppoted-mqtt version

uhppoted-mqtt-get-devices:
	mqtt publish --topic 'twystd/uhppoted/gateway/devices:get' \
                 --message '{ "message": { "client-id": "QWERTY54",\
                                           "request": { "request-id":  "AH173635G3", \
                                                        "reply-to":    "reply/97531" } \
                                         }}}'

uhppoted-mqtt-get-devices-hotp:
	mqtt publish --topic 'twystd/uhppoted/gateway/devices:get' \
                 --message '{ "message": { "client-id": "QWERTY54",\
                                           "request": { "request-id":  "AH173635G3", \
                                                        "reply-to":    "reply/97531", \
                                                        "hotp":        "586787" }}}'

uhppoted-mqtt-get-devices-rsa:
	mqtt publish --topic 'twystd/uhppoted/gateway/devices:get' \
                 --message '{ "message": { "client-id": "QWERTY54",\
                                           "signature": "RDtNHYn0WIvct/zygbl/WsQ2kPhHN1fZf3DfQ+x15LCuUhcoYLjrHjIV8GLnX+UbN3zoYif3VCDbk9R2gK4zmbh9NR9ze9dZ5MDLE8Za+9UGKBRNmg6OBbF1axyHczmoMSZgwZxgAg/Qu/3pzKEh+5/kRBRy/W8ILhbuYL+BDL4=",\
                                           "request": { "sequence-no": 8, \
                                                        "request-id":  "AH173635G3", \
                                                        "reply-to":    "reply/97531" }}}'

uhppoted-mqtt-get-devices-encrypted:
	mqtt publish --topic 'twystd/uhppoted/gateway/devices:get' \
                 --message '{ "message": { "client-id": "QWERTY54",\
                                           "signature": "RDtNHYn0WIvct/zygbl/WsQ2kPhHN1fZf3DfQ+x15LCuUhcoYLjrHjIV8GLnX+UbN3zoYif3VCDbk9R2gK4zmbh9NR9ze9dZ5MDLE8Za+9UGKBRNmg6OBbF1axyHczmoMSZgwZxgAg/Qu/3pzKEh+5/kRBRy/W8ILhbuYL+BDL4=",\
                                           "key":       "r5oJH7UFUj20kYucc4U5/I6byEq3+GPpkv989JlGPYKfyYRYyx9GAafdX0+oGJhZV5bMfy7nftFWB/MPQE2RHLUV3hCQNbz/tgrF3Jk1wDziubWsw9Ry6bVN1Py/iu6lOYu68kJSQqTn55OC7LY3QbBvCDVI0OQsVg0QilAP7tJalhXrl0Ig7Hj46Iq+VP1qjZ3zhGAXRmcP6J4FZgctjSZ/T5diOzifWMvNEMtcwYpKXwmgXo1a416i8k6GZ432dqA0NGJ27dTUNRU8YFYgntqWlcPgAn5wE/gIW9FdG2htfnRxz80PY2x6QN2B0Ktr9M8EaaK8qt/diHeq3G2vmg==",\
                                           "iv":        "221CD7E3F03BBDDE46AAE1F272C9997C",\
                                           "request":   "gOfqOIK77RttZTQs4OFM9XlUwqd0YYrEwByfMkMdhrN06+UNUwIpuNQPZo0xNmWsvPkwjynHdvuYcVpDOLJJOz+/jwo2ifm/7ss1fCdzYd3eDy3hifdIoZ+PEc6fHo6K8Mq2HA4EYj7uOqc5hU84ZBRe4I6V9MOeClOxvJdJgUYeDOBtZCIoP8NUUMir2OPmH7TJHR8XaEl21WQ9r90yuVRBbzN6IqEKKDqkYFVaTSI/fxCGsEgdlHsqPdJIR/Nt" \
                                         }, \
                              "hmac": "7006a543cf4bb7c7f9f2273149431b82c05704306db12aac961c8d9171b2630f" }'

uhppoted-mqtt-get-device:
	mqtt publish --topic 'twystd/uhppoted/gateway/device:get' \
                 --message '{ "message": { "client-id": "QWERTY54",\
                                           "request": { "request-id":  "AH173635G3", \
                                                        "reply-to":    "reply/97531", \
                                                        "device-id":   405419896 } \
                                         }}}'

uhppoted-mqtt-get-device-hotp:
	mqtt publish --topic 'twystd/uhppoted/gateway/device:get' \
                 --message '{ "message": { "client-id": "QWERTY54",\
                                           "request": { "request-id":  "AH173635G3", \
                                                        "reply-to":    "reply/97531", \
                                                        "hotp":        "586787", \
                                                        "device-id":   405419896 }}}'

uhppoted-mqtt-get-device-rsa:
	mqtt publish --topic 'twystd/uhppoted/gateway/device:get' \
                 --message '{ "message": { "client-id": "QWERTY54",\
                                           "signature": "K3cnznnLlpk5DLfjSviDktbUnNIWCPGzeUsxuIj84chdr6Oky3vz4tZJHC+dUIN9539aEFILv+EJYU7yYlMIc/wyvydxewgNj+rzKnuHLXidr7YS/pfMGhtb16gsPyLvq+CeD9OgB3m/DTxfEXF1kGEguVLR8uDnGxVNw1B1J10=",\
                                           "request": { "sequence-no": 8, \
                                                        "request-id":  "AH173635G3", \
                                                        "reply-to":    "reply/97531", \
                                                        "device-id":   405419896 }}}'

uhppoted-mqtt-get-device-encrypted:
	mqtt publish --topic 'twystd/uhppoted/gateway/device:get' \
                 --message '{ "message": { "client-id": "QWERTY54",\
                                           "signature": "E+hiR6KlTi5sSKoV4Z9wm4pA1XoqYplgRYEc4uzAsUc8tnSXqs/ITcHKU8aPwRxB3i2T+8JIbPkKUg19Bub9UMu7B8Mm5+3yOHU/NX8TM/akk4Qj8fur5Ui2Szbg/hAVdo7GPwttg4BbN8Ejl5h6UEv6x5i03RHV4DbAY2TbB28=",\
                                           "key":       "4ALW3VOHROywhvgyHlVbGo1B74FqEphcKxfLeug17GqV5igSP6f5oj4h6f+UzvJrVxCb4ekdU9aMBZ9yGmxNbhDZpLCBjFDGZB3sZfQ9WTmYswLLcYic5+om0PlxoegWnRtTsd+9f870ZyyPSGu/J6jei9QIXGqT3jwWiUCFn1ChOvWb5KQNEkAzirAJzQ9vXuxIb0M/kcLskCgM0dcldXYbeycnAPRoFxwjfWWytjN2FmgaF33ph6pF5Tzy+DavGciQ4tI5dVKUCtqfrvbp3yozk1ZZg8waKAcbnqXldRIZwFwFwmnG6ljtQl+2MrXUDG8VmJA+DjgI7aKJFq3bTA==",\
                                           "iv":        "4CE3CFB38F43761A5A53CD6BEAFE50B5",\
                                           "request":   "9K7hEqbZZjtAqwnsJMm2ZypTUJdt6W5qYPr/gVSB3WNxYOuj/ZDI8GeEL5nusdfCnkro/jbnKzGApsX/d7TNdl4210e5ryAvDQxc1HCYovxXalMRw+H8U6K4uSjrqNmgiEvWwL9iOEnsWfCw8LnArpep2bUIHQKWTaY6WyUhATYwQpdoMwZGhdPcH0Wh1aBdADzLr+LVCJqUGo0hKGfl0LZwiVi73KbJtqX1g+Sx+DT5rKLTEM2/SPXN7ic/RvHYp/7/Cegd9vkHh1U20qgAQ2xO288Cwexqodo0D35YcIitwwLTZEBD9P+hq5j/IypU" \
                                         }, \
                              "hmac": "d956cd830d972285255a293f16df36fb2e07b6c9cc39c3466ab3c448992840b3" }'

uhppoted-mqtt-get-status:
	mqtt publish --topic 'twystd/uhppoted/gateway/device/status:get' \
                 --message '{ "message": { "client-id": "QWERTY54",\
                                           "request": { "request-id":  "AH173635G3", \
                                                        "reply-to":    "reply/97531", \
                                                        "device-id":   405419896 }}}'

uhppoted-mqtt-get-time:
	mqtt publish --topic 'twystd/uhppoted/gateway/device/time:get' \
                 --message '{ "message": { "client-id": "QWERTY54",\
                                           "request": { "request-id": "AH173635G3", \
                                                        "reply-to":   "reply/97531", \
                                                        "device-id":  405419896 }}}'

uhppoted-mqtt-set-time:
	mqtt publish --topic 'twystd/uhppoted/gateway/device/time:set' \
                 --message '{ "message": { "client-id": "QWERTY54",\
                                           "request": { "request-id": "AH173635G3", \
                                                        "reply-to":   "reply/97531", \
                                                        "device-id":  405419896, \
                                                        "date-time":  "$(DATETIME)" }}}'

uhppoted-mqtt-get-door-delay:
	mqtt publish --topic 'twystd/uhppoted/gateway/device/door/delay:get' \
                 --message '{ "request": { "request-id": "AH173635G3", "reply-to": "reply/97531", "client-id": "QWERTY54", "hotp": "586787" }, \
	                          "device-id": 405419896, "door": 3  }'

uhppoted-mqtt-set-door-delay:
	mqtt publish --topic 'twystd/uhppoted/gateway/device/door/delay:set' \
                 --message '{ "request": { "request-id": "AH173635G3", "reply-to": "reply/97531", "client-id": "QWERTY54", "hotp": "586787" }, \
                              "device-id": 405419896, "door": 3, "delay": 8 }'

uhppoted-mqtt-get-door-control:
	mqtt publish --topic 'twystd/uhppoted/gateway/device/door/control:get' \
                 --message '{ "request": { "request-id": "AH173635G3", "reply-to": "reply/97531", "client-id": "QWERTY54", "hotp": "586787" }, \
                              "device-id": 405419896, "door": 3, "delay": 8 }'

uhppoted-mqtt-set-door-control:
	mqtt publish --topic 'twystd/uhppoted/gateway/device/door/control:set' \
                 --message '{ "request": { "request-id": "AH173635G3", "reply-to": "reply/97531", "client-id": "QWERTY54", "hotp": "586787" }, \
                              "device-id": 405419896, "door": 3, "control": "normally closed" }'

uhppoted-mqtt-get-cards:
	mqtt publish --topic 'twystd/uhppoted/gateway/device/cards:get' \
                 --message '{ "request": { "request-id": "AH173635G3", "reply-to": "reply/97531", "client-id": "QWERTY54", "hotp": "586787" }, \
                              "device-id": 405419896 }'

uhppoted-mqtt-delete-cards:
	mqtt publish --topic 'twystd/uhppoted/gateway/device/cards:delete' \
                 --message '{ "request": { "request-id": "AH173635G3", "reply-to": "reply/97531", "client-id": "QWERTY54", "hotp": "586787" }, \
                              "device-id": 405419896 }'

uhppoted-mqtt-get-card:
#	mqtt publish --topic 'twystd/uhppoted/gateway/device/card:get' \
#                 --secure --port 8883 --cafile ./docker/hivemq/localhost.pem \
#                 --cert "./docker/hivemq/client-cert.pem"          \
#                 --key  "./docker/hivemq/client-key.pem"           \
#                 --message '{ "request": { "request-id": "AH173635G3", "reply-to": "reply/97531", "client-id": "QWERTY54", "hotp": "586787" }, \
#                              "device-id": 405419896, "card-number": 65537 }'
	mqtt publish --topic 'twystd/uhppoted/gateway/device/card:get' \
                 --message '{ "request": { "request-id": "AH173635G3", "reply-to": "reply/97531", "client-id": "QWERTY54", "hotp": "586787" }, \
                              "device-id": 405419896, "card-number": 65537 }'


uhppoted-mqtt-put-card:
	mqtt publish --topic 'twystd/uhppoted/gateway/device/card:put' \
                 --message '{ "request": { "request-id": "AH173635G3", "reply-to": "reply/97531", "client-id": "QWERTY54", "hotp": "586787" }, \
                              "device-id": 405419896, \
                              "card": { "card-number": 1327679, "valid-from": "2019-11-01", "valid-until": "2019-12-31", "doors": [true,false,false,true] }}'

uhppoted-mqtt-delete-card:
	mqtt publish --topic 'twystd/uhppoted/gateway/device/card:delete' \
                 --message '{ "request": { "request-id": "AH173635G3", "reply-to": "reply/97531", "client-id": "QWERTY54", "hotp": "586787" }, \
                              "device-id": 405419896, "card-number": 1327679 }'


uhppoted-mqtt-get-events:
#	mqtt publish --topic 'twystd/uhppoted/gateway/device/events:get' --message '{ }'
#	mqtt publish --topic 'twystd/uhppoted/gateway/device/events:get' --message '{ "device-id": 405419896 }'
#	mqtt publish --topic 'twystd/uhppoted/gateway/device/events:get' --message '{ "device-id": 405419896, "start": "2019-08-05 08:10:00" , "end": "2019-08-09 20:35:46" }'
#	mqtt publish --topic 'twystd/uhppoted/gateway/device/events:get' --message '{ "device-id": 405419896, "start": "2019-08-05 08:10" , "end": "2019-08-09 20:35" }'
#	mqtt publish --topic 'twystd/uhppoted/gateway/device/events:get' --message '{ "device-id": 405419896, "end": "2019-08-05" , "start": "2019-08-09" }'
#	mqtt publish --topic 'twystd/uhppoted/gateway/device/events:get' --message '{ "device-id": 405419896, "start": "2019-08-05" , "end": "2019-08-09" }'
	mqtt publish --topic 'twystd/uhppoted/gateway/device/events:get' \
                 --message '{ "request": { "request-id": "AH173635G3", "reply-to": "reply/97531", "client-id": "QWERTY54", "hotp": "586787" }, \
                              "device-id": 405419896, "start": "2019-08-05" , "end": "2019-08-09" }'




uhppoted-mqtt-get-event:
	mqtt publish --topic 'twystd/uhppoted/gateway/device/event:get' \
	             --message '{ "request": { "request-id": "98YWRW524", "reply-to": "reply/97531", "client-id": "QWERTY54", "hotp": "586787" }, \
	                          "device-id": 405419896, "event-id": 50 }'

swagger: 
	docker run --detach --publish 80:8080 --rm swaggerapi/swagger-editor 

docker: build
	env GOOS=linux GOARCH=amd64 go build -o docker/simulator/uhppote-simulator     uhppote-simulator
	env GOOS=linux GOARCH=amd64 go build -o docker/uhppoted-rest/uhppote-simulator uhppote-simulator
	env GOOS=linux GOARCH=amd64 go build -o docker/uhppoted-rest/uhppoted-rest     uhppoted-rest
	docker image     prune -f
	docker container prune -f
	docker build -f ./docker/simulator/Dockerfile     -t simulator       . 
	docker build -f ./docker/uhppoted-rest/Dockerfile -t uhppoted        . 
	docker build -f ./docker/hivemq/Dockerfile        -t hivemq/uhppoted . 

docker-simulator:
	docker run --detach --publish 8000:8000 --publish 60000:60000/udp --rm simulator

docker-hivemq:
	docker run --detach --publish 8081:8080 --publish 1883:1883 --publish 8883:8883 --rm hivemq/uhppoted

docker-rest:
	docker run --detach --publish 8080:8080 --rm uhppoted

hivemq-listen:
	mqtt subscribe --topic 'twystd/uhppoted/#'



