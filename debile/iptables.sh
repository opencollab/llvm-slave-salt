#!/bin/bash
# Iptables script de configuration rapide pour iptables
# par Sylvestre ledru <sylvestre@ledru.info>
# 23 mars 2005

############ DEFINITION DES INTERFACES ET RESEAUX


INTERF_LOOPBACK="lo"
INTERF_INTERNET="eth0"
INTERF_VPN="tun0" #or< tunx ...

OUT_TCP=( ssh https www smtp mysql domain auth ntp echo imap2 pop3 144 openvpn munin pop3s imaps 4505 4506) # client
# 144 = imap proxy
OUT_UDP=( ssh domain www https ntp openvpn imaps pop3) # client

IN_TCP=( ssh https www domain auth echo openvpn 12121 smtp 465 munin 4505 4506 22017) #service
IN_UDP=( ssh domain www openvpn) # service

SERVERFTP=1
CLIENTFTP=1
TRACEROUTE=1
PING=1
NOSSHRETRYBLOCK=1

BANNEDIP=()

VERIFICATION=8.8.8.8 # Google DNS

if [ "$INTERF_INTERNET" ==  "" ]; then
	echo "Script not configured"
	exit 0
fi

IPTABLES=/sbin/iptables

################ NE PAS CHANGER EN DESSOUS DE CETTE LIGNE ##############


############ INITIALISATION DE IPTABLES

#J'efface toutes les r?gles existantes
$IPTABLES -F

#j'efface les chaines existantes
$IPTABLES -X


#Par default je refuse tout
$IPTABLES -P INPUT DROP
$IPTABLES -P OUTPUT DROP
$IPTABLES -P FORWARD DROP

# La on logue et on refuse le paquet,
# on rajoute un prefixe pour pouvoir
# s'y retrouver dans les logs
$IPTABLES -N LOG_DROP
$IPTABLES -A LOG_DROP -j LOG --log-prefix '[IPTABLES DROP] : '
$IPTABLES -A LOG_DROP -j DROP

############ PROTECTION CONTRE LES ATTAQUES

#Protection contre l'echo en broadcast
echo 1 > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts

# Protection contre les mauvais messages d'erreur
echo 1 > /proc/sys/net/ipv4/icmp_ignore_bogus_error_responses

#Protection contre l'IP spoofing
for f in /proc/sys/net/ipv4/conf/*/rp_filter; do
	echo 1 > $f
done

#Protection contre l'acceptation des messages ICMP redirig?s
for f in /proc/sys/net/ipv4/conf/*/accept_source_route; do
	echo 0 > $f
done


#Loger les paquets spoof?s et redirig?s
for f in /proc/sys/net/ipv4/conf/*/log_martians;do
	echo 1 > $f
done
echo 0 > /proc/sys/net/ipv4/ip_forward

############ LO

#j'accepte tous les paquets sur l'interface lo
$IPTABLES -A INPUT -i $INTERF_LOOPBACK -p ALL -j ACCEPT
$IPTABLES -A OUTPUT -o $INTERF_LOOPBACK -p ALL -j ACCEPT

####### VPN

$IPTABLES -A INPUT -i $INTERF_VPN -p ALL -j ACCEPT
$IPTABLES -A OUTPUT -o $INTERF_VPN -p ALL -j ACCEPT


######## Flood protection
$IPTABLES -A OUTPUT -p icmp -m limit --limit 50/s -j ACCEPT
$IPTABLES -A INPUT -p icmp -m limit --limit 50/s -j ACCEPT

########### ETH0: RESEAU INTERNET
if [ $PING -eq 1 ]; then
	echo "ICMP authorized"
#J'accepte tous les paquets icmp pour le ping
	$IPTABLES -A OUTPUT -p icmp -o $INTERF_INTERNET -j ACCEPT
	$IPTABLES -A INPUT -p icmp -i $INTERF_INTERNET -j ACCEPT 
fi


for i in ${BANNEDIP[@]}; do
	echo "IP $i banned"
	$IPTABLES -A OUTPUT -p tcp -d $i -j DROP
	$IPTABLES -A INPUT -p tcp -s $i -j DROP
	$IPTABLES -A OUTPUT -p udp -d $i -j DROP
	$IPTABLES -A INPUT -p udp -s $i -j DROP
	$IPTABLES -A OUTPUT -p icmp -d $i -j DROP
	$IPTABLES -A INPUT -p icmp -s $i -j DROP
done


############# TRACEROUTE #############
if [ $TRACEROUTE -eq 1 ]; then
	echo "Traceroute activated"
	TR_SRC_PORTS="32769:65535" 
	TR_DEST_PORTS="33434:33523" 
	
	$IPTABLES -A OUTPUT -o $INTERF_INTERNET -p udp --sport $TR_SRC_PORTS --dport $TR_DEST_PORTS -j ACCEPT 
fi 
#####################################

function acceptAll () {
#J'efface toutes les r?gles existantes
	$IPTABLES -F

#j'efface les chaines existantes
	$IPTABLES -X

#Par default j'accepte tout
	$IPTABLES -P INPUT ACCEPT
	$IPTABLES -P OUTPUT ACCEPT
	$IPTABLES -P FORWARD ACCEPT
}


function checkRetour () {
	if [ $1 -ne 0 ]; then
		echo "Error !!!"
		acceptAll
		exit 1
	fi

}

function autoriseOutput () {
	if [[ $2 != "TCP" && $2 != "UDP" ]]; then
		echo "Protocol $2 unknown"
		acceptAll
	else 
		$IPTABLES -A OUTPUT -o $INTERF_INTERNET -p $2 --dport $1 -j ACCEPT
		checkRetour $?
		$IPTABLES -A INPUT -i $INTERF_INTERNET -p $2 --sport $1 -j ACCEPT
		checkRetour $?
	fi
}


function autoriseInput () {
	if [[ $2 != "TCP" && $2 != "UDP" ]]; then
		echo "Protocol $2 unknown"
		acceptAll
	else 
		$IPTABLES -A OUTPUT -o $INTERF_INTERNET -p $2 --sport $1 -j ACCEPT
		checkRetour $?
		$IPTABLES -A INPUT -i $INTERF_INTERNET -p $2 --dport $1 -j ACCEPT
		checkRetour $?
	fi
}


if [ $SERVERFTP -eq 1 ]; then
	echo "FTP as server opened"
	$IPTABLES -A INPUT -i $INTERF_INTERNET -p TCP --dport 20:21 -j ACCEPT
	$IPTABLES -A INPUT -i $INTERF_INTERNET -p UDP --dport 20:21 -j ACCEPT
	$IPTABLES -A OUTPUT -o $INTERF_INTERNET -p TCP --sport 20:21 -j ACCEPT
	$IPTABLES -A OUTPUT -o $INTERF_INTERNET -p UDP --sport 20:21 -j ACCEPT
	$IPTABLES -A INPUT -i $INTERF_INTERNET -p tcp --sport 1024:65535 --dport 1024:65535 -m state --state ESTABLISHED,RELATED -j ACCEPT
	$IPTABLES -A OUTPUT -o $INTERF_INTERNET -p tcp --sport 1024:65535 --dport 1024:65535 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
fi

if [ $CLIENTFTP -eq 1 ]; then
	echo "FTP as client opened"
# En Tant Que Client
#J'accepte les ports TCP 20 & 21 et UDP 21 pour le FTP
	$IPTABLES -A INPUT -i $INTERF_INTERNET -p TCP --sport 20:21 -j ACCEPT
	$IPTABLES -A INPUT -i $INTERF_INTERNET -p UDP --sport 20:21 -j ACCEPT
	$IPTABLES -A OUTPUT -o $INTERF_INTERNET -p TCP --dport 20:21 -j ACCEPT
	$IPTABLES -A OUTPUT -o $INTERF_INTERNET -p UDP --dport 20:21 -j ACCEPT
#en tant que client pasv mode
	$IPTABLES -A INPUT -p tcp --sport 1024: --dport 1024:  -m state --state ESTABLISHED -j ACCEPT
	$IPTABLES -A OUTPUT -p tcp --sport 1024: --dport 1024:  -m state --state ESTABLISHED,RELATED -j ACCEPT
fi

if test -z $NOSSHRETRYBLOCK; then
    $IPTABLES -I INPUT -p tcp --dport 22 -i $INTERF_INTERNET -m state --state NEW -m recent   --set
    $IPTABLES -I INPUT -p tcp --dport 22 -i $INTERF_INTERNET -m state --state NEW -m recent --update --seconds 600 --hitcount 5 -j DROP
    #This will limit incoming connections to port 22 to no more than 3 attemps in a minute. Any more will be dropped.
fi


for i in ${OUT_TCP[@]}; do
	echo "OUT TCP : Allow (server => net) $i"
	autoriseOutput $i "TCP"
done



for i in ${IN_TCP[@]}; do
	echo "IN TCP : Allow (net => server) $i"
	autoriseInput $i "TCP"
done



for i in ${OUT_UDP[@]}; do
	echo "OUT UDP : Allow (server => net) $i"
	autoriseOutput $i "UDP"
done



for i in ${IN_UDP[@]}; do
	echo "IN UDP : Allow (net => server) $i"
	autoriseInput $i "UDP"
done

##### VERIFICATION QUE LA CONNEXION EST BIEN UP
echo "Check of the connection against $VERIFICATION"
ping -c 5 $VERIFICATION > /dev/null
retour=$?
echo "Returns : $retour"
if [ $retour -ne 0 ]; then
	echo "Verification echouée"
	acceptAll
else
	echo "Check OK"
fi

$IPTABLES -A FORWARD -j LOG_DROP
$IPTABLES -A INPUT -j LOG_DROP
$IPTABLES -A OUTPUT -j LOG_DROP
