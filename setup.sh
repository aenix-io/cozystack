#!/bin/sh
NET="192.168.100.0/24"

echo "Searching talos nodes in $NET..."

CANDIDATE_NODES=$(nmap -Pn -n -p 50000 $NET -vv | awk '/Discovered open port/ {print $NF}')

echo found:
printf "  - %s\n" $CANDIDATE_NODES

echo "Filtering nodes in maintenance mode..."
NODES=
for node in $CANDIDATE_NODES; do
  if talosctl -n "$node" get info -i >/dev/null 2>/dev/null; then
    NODES="$NODES $node"
  fi
done

echo filtered:
printf "  - %s\n" $NODES

# Screen 1: node list

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

# Screen 6: configure default gateway
default_gateway=$(talosctl -n "$node" get routes -i -o jsonpath={.spec.gateway} | grep -v '^$' -m1)
gateway=$(dialog --inputbox "Enter gateway:" 8 40 "$default_gateway" 3>&1 1>&2 2>&3) || exit 0

# Screen 7: configure dns servers
default_dns_servers=$(talosctl -n 192.168.100.127 get resolvers resolvers -i -o jsonpath='{.spec.dnsServers[*]}' | paste -d, -s)
dns_servers=$(dialog --inputbox "Enter dns servers:" 8 80 "$default_dns_servers" 3>&1 1>&2 2>&3) || exit 0

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

## TODO
#talosctl gen secrets
#talosctl gen config foo https://192.168.100.111:6443 --config-patch="$machine_config" --force
#talosctl --talosconfig=talosconfig apply -e "$node" -n "$node" -f controlplane.yaml -i
#node=$(echo "${addresses%/*}")
#talosctl --talosconfig=talosconfig -e "$node" -n "$node" dashboard
#talosctl --talosconfig=talosconfig -e "$node" -n "$node" bootstrap
