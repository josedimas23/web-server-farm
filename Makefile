CERT_DIR := granjaweb/P4-josedimasugr-certificados
CERT     := $(CERT_DIR)/certificado_josedimasugr.crt
KEY      := $(CERT_DIR)/certificado_josedimasugr.key
NETWORK  := red_web
SUBNET   := 192.168.10.0/24

.PHONY: up down certs network bench-ab bench-locust

## Generate certs if missing, create the network and start the farm
up: certs network
	cd granjaweb && docker compose up -d --build
	@echo "Load balancer ready at https://localhost:8089 (self-signed certificate)"

## Stop the farm and the load tests
down:
	cd pruebas_carga/locust && docker compose down
	cd pruebas_carga/ab && docker compose down
	cd granjaweb && docker compose down

## Self-signed certificate for local use (only if it doesn't exist yet)
certs: $(KEY)

$(KEY):
	openssl req -x509 -nodes -newkey rsa:2048 -days 365 -subj "/CN=localhost" \
		-keyout $(KEY) -out $(CERT)

## Shared Docker network for the farm and the load tests
network:
	@docker network inspect $(NETWORK) >/dev/null 2>&1 || \
		docker network create --subnet $(SUBNET) $(NETWORK)

## Apache Benchmark: 10,000 requests, 100 concurrent
bench-ab: network
	cd pruebas_carga/ab && docker compose up --build

## Locust: master + 5 workers, web UI at http://localhost:8090
bench-locust: network
	cd pruebas_carga/locust && docker compose up -d
	@echo "Locust UI at http://localhost:8090"
