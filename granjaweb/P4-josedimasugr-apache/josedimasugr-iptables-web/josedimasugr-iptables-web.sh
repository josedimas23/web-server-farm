#!/bin/bash

#Limpiar reglas

iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X

#1.Denegación implícita de todo el tráfico

iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

#2.Trafico de red entrante

iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

#3.Trafico de red saliente

iptables -A OUTPUT -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT

#4.Manejar tráfico de red de la misma máquina

iptables -A OUTPUT -m state --state NEW -j ACCEPT

#5.Manejar tráfico HTTP y HTTPS

iptables -A INPUT -p tcp --dport 80 -s 192.168.10.50 -m state --state NEW -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -s 192.168.10.50 -m state --state NEW -j ACCEPT


# AVANZADAS 1 

#6.Limitar el numero de ips simultaneas a 5

iptables -A INPUT -p tcp --syn --dport 80 -m connlimit --connlimit-above 5 -j REJECT
iptables -A INPUT -p tcp --syn --dport 443 -m connlimit --connlimit-above 5 -j REJECT

#7.Bloquear escaneo de puertos

iptables -N port-scanning
iptables -A port-scanning -j DROP
iptables -A INPUT -p tcp --tcp-flags SYN,ACK,FIN,RST RST -m limit --limit 1/s -j port-scanning

#8.Mitigar ataques

iptables -A INPUT -p tcp --dport 80 -m string --string 'union select' --algo bm -j DROP
iptables -A INPUT -p tcp --dport 443 -m string --string 'union select' --algo bm -j DROP


# AVANZADAS 2 - DDoS

#9.Limitacion para evitar saturacion

iptables -A INPUT -p tcp --syn --dport 80 -m connlimit --connlimit-above 5 --connlimit-mask 32 -j DROP
iptables -A INPUT -p tcp --syn --dport 443 -m connlimit --connlimit-above 5 --connlimit-mask 32 -j DROP

#10.Controlar el trafico 

iptables -A INPUT -m recent --name ddos_list --rcheck --seconds 43200 --hitcount 5 -j DROP
iptables -A INPUT -m recent --name ddos_list --update --seconds 43200 --hitcount 5 -j DROP
iptables -A INPUT -m recent --name ddos_list --set -j ACCEPT

#11.Prevenir ataques DDoS

iptables -A INPUT -p icmp --icmp-type echo-request -m limit --limit 10/minute --limit-burst 5 -j ACCEPT

#12.Protección Contra Ataques de Fragmentación

iptables -A INPUT -f -j DROP

#Guardarlas

mkdir -p /etc/iptables
iptables-save > /etc/iptables/rules.v4

