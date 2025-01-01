# tor-proxy-in-docker
Running a TOR proxy in docker, especially to connect to a raspberry pi's wifi and route all traffic through TOR
- **Goal**: 
Use the wifi of my raspberry pi as a tor proxy; when connectiong to the raspi's wifi, all apps are automatically anonymized by the TOR network. In addition, run it as a TOR bridge relay to support the TOR project.
- **Situation**: I run a Raspberry Pi 4 Model B Rev 1.2, cable-connected to my regular internet wifi router. The raspberry is configured as a wifi hotspot, too (although not capable of covering my entire home). The wlan0 interface offers DNS/DHCP using dnsmasq on 10.42.0.1.

## Brief how-to
**Install and run docker**
```
apt-get update && apt-get install docker.io` 
systemctl enable --now docker`
```

**Adjust and supply configuration for tor**

vi torrc
```
cp torrc /usr/local/etc/
```


**Create docker image**
```
docker build -t tor:1 .
```

**Add iptables rules to route all wlan0 traffic through TOR, except ssh port 22 for maintenance**
```
iptables -t nat -A PREROUTING -i wlan0 -p tcp --dport 22 -j REDIRECT --to-ports 22
iptables -t nat -A PREROUTING -i wlan0 -p udp --dport 53 -j REDIRECT --to-ports 153
iptables -t nat -A PREROUTING -i wlan0 -p tcp --syn -j REDIRECT --to-ports 9040
iptables-save > /etc/iptables.ipv4.nat
```


**Load rules automatically**

vi /etc/network/if-pre-up.d/iptables
```
#!/bin/bash
/sbin/iptables-restore </etc/iptables.ipv4.nat
```
```
chmod 755 /etc/network/if-pre-up.d/iptables
```


**Ensure ip forwarding is enabled**
```
sysctl net.ipv4.ip_forward
```
> net.ipv4.ip_forward = 1

If result is not '1', uncomment that line in /etc/sysctl.conf.



**Run container**
```
docker run -d --restart always --net host --name tor -v /usr/local/etc/torrc:/etc/tor/torrc tor:1
```

**Optional: Install nyx to monitor the tor client**
```
apt-get install -y nyx
nyx
```

***Reboot and check functionality***
```
nyx
docker logs tor
```
Finally, connect to raspi's wifi and check [https://check.torproject.org/](https://check.torproject.org/) wether you are using TOR.
If yes, [https://www.whatsmyip.org/more-info-about-you/](https://www.whatsmyip.org/more-info-about-you/) should show you an arbitrary location on the world where your traffic is relayed to the internet.
