# docker build -t tor:1 .
# - adjust and copy torrc to /usr/local/etc/torrc
# docker run -d --restart always --net host --name tor -v /usr/local/etc/torrc:/etc/tor/torrc tor:1

FROM debian:bookworm-slim

RUN DEBIAN_FRONTEND=noninteractive \
&& apt-get update \
&& apt-get install --no-install-recommends -y gpg wget ca-certificates \
&& wget -qO- https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --dearmor | tee /usr/share/keyrings/deb.torproject.org-keyring.gpg >/dev/null \
&& echo 'deb     [signed-by=/usr/share/keyrings/deb.torproject.org-keyring.gpg] https://deb.torproject.org/torproject.org bookworm main' >> /etc/apt/sources.list.d/tor.list \
&& apt-get update \
&& apt-get install --no-install-recommends -y deb.torproject.org-keyring tor obfs4proxy \
&& apt-get upgrade -y \
&& apt-get purge wget gpg -y \
&& apt-get autoremove -y \
&& rm -rf /var/lib/apt/lists/* 

ENTRYPOINT [ "tor" ]
