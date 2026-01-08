FROM ghcr.io/gammu/gammu:latest

COPY gammurc /etc/gammurc
COPY run.sh /run.sh

RUN chmod +x /run.sh

CMD ["/run.sh"]