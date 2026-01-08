FROM alpine:3.20

# Nainstalujeme gammu a gammu-smsd
RUN apk add --no-cache gammu gammu-smsd bash

# Zkopírujeme konfiguraci a startovací skript
COPY gammurc /etc/gammurc
COPY run.sh /run.sh

# Povolení spouštění
RUN chmod +x /run.sh

# Start
CMD ["/run.sh"]
