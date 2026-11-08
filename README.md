# Web Server Farm · Docker

Granja web de alta disponibilidad con Docker: balanceo de carga con Nginx, servidores Apache con HTTPS, cortafuegos con iptables y pruebas de carga con ab y Locust.

**Autor:** Jose Dimas Sánchez Casas

## Estructura
- `granjaweb/`: `docker-compose.yml` con los servidores Apache y el balanceador Nginx, sus Dockerfiles y su configuración SSL.
- `pruebas_carga/`: scripts de pruebas de carga con `ab` y Locust.
- `docs/`: memoria del trabajo final.

## Puesta en marcha
```bash
cd granjaweb
docker compose up -d --build
```
Los certificados y claves privadas no están en el repositorio: genera los tuyos en `granjaweb/P4-josedimasugr-certificados/`.
