#!/bin/sh

default_scan_networks=$(ip -o route | awk '$3 !~ /^(docker|cni)/ && $2 == "dev" {print $1}' | paste -d ' ' -s)
scan_networks=$(dialog --inputbox "Enter networks to scan:" 8 80 "$default_scan_networks" 3>&1 1>&2 2>&3) || exit 0
scan_networks=$(echo "$scan_networks" | tr , " ")

node_list_file=$(mktemp)
{
  printf "%s\nXXX\n%s\n%s\nXXX\n" "20" "Searching talos nodes in $scan_networks..."
  CANDIDATE_NODES=$(nmap -Pn -n -p 50000 $scan_networks -vv | awk '/Discovered open port/ {print $NF}')

  #echo found:
  #printf "  - %s\n" $CANDIDATE_NODES

  printf "%s\nXXX\n%s\n%s\nXXX\n" "50" "Filtering nodes in maintenance mode..."
  NODES=
  for node in $CANDIDATE_NODES; do
    if talosctl -n "$node" get info -i >/dev/null 2>/dev/null; then
      NODES="$NODES $node"
    fi
  done
  
  #echo filtered:
  #printf "  - %s\n" $NODES

  printf "%s\nXXX\n%s\n%s\nXXX\n" "70" "Collecting information about the nodes..."
  node_list=$(
    seen=
    for node in $NODES; do
      mac=$(talosctl -n "$node" get hardwareaddresses.net.talos.dev first -i -o jsonpath={.spec.hardwareAddr})
      case " $seen " in *" $mac "*) continue ;; esac # remove duplicated nodes
      seen="$seen $mac"
      name="$node"
      hostname=$(talosctl -n "$node" get hostname -i -o jsonpath='{.spec.hostname}')
      if [ -n "$hostname" ]; then
        name="$name ($hostname)"
      fi
      manufacturer=$(talosctl -n "$node" get cpu -i -o jsonpath={.spec.manufacturer} | head -n1)
      cpu=$(talosctl -n "$node" get cpu -i -o jsonpath={.spec.threadCount} -i | awk '{sum+=$1;} END{print sum "-core";}')
      ram=$(talosctl -n "$node" get ram -o jsonpath={.spec.sizeMiB} -i | awk '{sum+=$1;} END{print sum/1024 "GB";}')
      disks=$(talosctl -n "$node" disks -i | awk -F'  +' 'NR>1 {print $1 ":" $9}' | sed 's|^/dev/||' | tr -d ' ' | paste -d, -s)
      echo "\"$name\"" "\"$mac, $cpu ${manufacturer:-CPU}, RAM: $ram, Disks: [$disks]\""
    done
  )

  echo "$node_list" > "$node_list_file"
} | dialog --gauge "Please wait" 10 70 0 3>&1 1>&2 2>&3

node_list=$(cat "$node_list_file")

if [ -z "$node_list" ]; then
  dialog --msgbox "No talos nodes in maintenance mode found!

Searched networks: $scan_networks" 10 60
  exit 1
fi

# Screen 1: node list
node=$(echo "$node_list" | dialog --menu "choose node to bootstrap" 0 0 0 --file /dev/stdin 3>&1 1>&2 2>&3) || exit 0
# cut hostname
node=$(echo "$node" | awk '{print $1}')

# Screen 2: Choose hostname
default_hostname=$(talosctl -n "$node" get hostname -i -o jsonpath='{.spec.hostname}')
hostname=$(dialog --inputbox "Enter hostname:" 8 40 "$default_hostname" 3>&1 1>&2 2>&3) || exit 0

# Screen 3: Choose disk to install
disks_list=$(talosctl -n "$node" disks -i | awk 'NR>1 {printf "\"" $1 "\""; $1=""; print " \"" $0 "\""}')
disk=$(echo "$disks_list" | dialog --menu "choose disk to install" 0 0 0 --file /dev/stdin 3>&1 1>&2 2>&3)

# Screen 4: Choose interface
link_list=$(talosctl -n "$node" get link -i | awk -F'  +' 'NR>1 && $4 ~ /^(ID|eno|eth|enp|enx)/ {print $4 "|" $(NF-2)}')
address_list=$(talosctl -n "$node" get addresses -i | awk 'NR>1 {print $NF " " $(NF-1)}') || exit 0

interface_list=$(
  for link_mac in $link_list; do
    link="${link_mac%%|*}"
    mac="${link_mac#*|}"
    ips=$(set -x; echo "$address_list" | awk "\$1 == \"$link\" {print \$2}" | paste -d, -s)
    details="$mac"
    if [ -n "$ips" ]; then
      details="$mac ($ips)"
    fi
    echo "\"$link\" \"$details\""
  done
)

default_mac=$(talosctl -n "$node" get hardwareaddresses.net.talos.dev first -i -o jsonpath={.spec.hardwareAddr})
default_interface=$(echo "$link_list" | awk -F'|' "\$2 == \"$default_mac\" {print \$1}")

interface=$(echo "$interface_list" | dialog --default-item "$default_interface" --menu "choose interface:" 0 0 0 --file /dev/stdin 3>&1 1>&2 2>&3)

# Screen 5: configure networks
default_addresses=$(talosctl -n "$node" get nodeaddress default -i -o jsonpath={.spec.addresses[*]} | paste -d, -)
addresses=$(dialog --inputbox "Enter addresses:" 8 40 "$default_addresses" 3>&1 1>&2 2>&3) || exit 0
addresses=$(echo "$dns_servers" | paste -d, -s)
address=$(echo "$addresses" | awk -F/ '{print $1}')

# Screen 6: configure default gateway
default_gateway=$(talosctl -n "$node" get routes -i -o jsonpath={.spec.gateway} | grep -v '^$' -m1)
gateway=$(dialog --inputbox "Enter gateway:" 8 40 "$default_gateway" 3>&1 1>&2 2>&3) || exit 0

# Screen 7: configure dns servers
default_dns_servers=$(talosctl -n 192.168.100.127 get resolvers resolvers -i -o jsonpath='{.spec.dnsServers[*]}' | paste -d, -s)
dns_servers=$(dialog --inputbox "Enter dns servers:" 8 80 "$default_dns_servers" 3>&1 1>&2 2>&3) || exit 0
dns_servers=$(echo "$dns_servers" | paste -d, -s)

# Screen 9: Confirm configuration
machine_config=$(cat <<EOT
machine:
  type: controlplane
  install:
    disk: $disk
  network:
    hostname: $hostname
    nameservers: [$dns_servers]
    interfaces:
    - interface: $interface
      addresses: [$addresses]
      routes:
        - network: 0.0.0.0/0
          gateway: $gateway
EOT
)

file=$(mktemp)
trap "rm -f \"$file\"" EXIT
echo "Please confirm your configuration:

$machine_config" > "$file"

dialog --ok-label "Install" --extra-button --extra-label "Cancel" --textbox "$file" 0 0 || exit 0
rm -f "$file"
trap '' EXIT

# Screen 10: Installation process

{ 
  printf "%s\nXXX\n%s\n%s\nXXX\n" "0" "Generating configuration..."
  if [ ! -f secrets.yaml ]; then
    talosctl gen secrets >/dev/null 2>&1
  fi
  talosctl gen config foo --with-secrets=secrets.yaml https://192.168.100.111:6443 --config-patch="$machine_config" --force >/dev/null 2>&1
  printf "%s\nXXX\n%s\n%s\nXXX\n" "1" "Applying configuration..."
  talosctl --talosconfig=talosconfig apply -e "$node" -n "$node" -f controlplane.yaml -i >/dev/null 2>&1

  printf "%s\nXXX\n%s\n%s\nXXX\n" "10" "Installing..."

  old_is_up=1
  old_is_pingable=1
  new_is_pingable=0
  new_is_up=0
  until [ "$new_is_up" = 1 ] ; do

    if [ "$new_is_pingable" = 0 ]; then
      if [ "$old_is_up" = 1 ]; then
        timeout 1 talosctl --talosconfig=talosconfig -e "$node" -n "$node" get info -i >/dev/null 2>&1
        if [ $? = 124 ]; then
          old_is_up=0
        fi
      else
        if ! ping -W1 -c1 "$node" >/dev/null 2>&1; then
          old_is_pingable=0
        fi
      fi
    fi

    if [ "$old_is_pingable" = 0 ]; then
      if ping -W1 -c1 "$address" >/dev/null 2>&1; then
        new_is_pingable=1
      fi
    fi

    if timeout 1 talosctl --talosconfig=talosconfig -e "$address" -n "$address" get info >/dev/null 2>&1; then
      new_is_up=1
    fi

    case $old_is_up$old_is_pingable$new_is_pingable in
      110) printf "%s\nXXX\n%s\n%s\nXXX\n" "20" "Installing... (socket is up at $node)" ;;
      010) printf "%s\nXXX\n%s\n%s\nXXX\n" "50" "Rebooting... (node is pingable at $node)" ;;
      000) printf "%s\nXXX\n%s\n%s\nXXX\n" "70" "Rebooting... (node is not pingable)" ;;
      001) printf "%s\nXXX\n%s\n%s\nXXX\n" "80" "Rebooting... (node is pingable again at $address)" ;;
    esac
  done
} | dialog --gauge "Please wait" 10 70 0 3>&1 1>&2 2>&3

# Screen 11: Complete installation

dialog --msgbox "Installation finished!

You will now be directed to the dashboard" 0 0
talosctl --talosconfig=talosconfig -e "$address" -n "$address" dashboard
clear
