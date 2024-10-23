#!/bin/bash

# Node IPs (primary IPs for each node)
NODE1_IP="192.168.188.231"
NODE2_IP="192.168.188.232"
NODE3_IP="192.168.188.233"

# Extract the primary IP (first IP) from the output of hostname -I
PRIMARY_IP=$(hostname -I | awk '{print $1}')

# Function to add VXLAN ports between two bridges and display the command being executed
add_vxlan_port() {
    local local_bridge=$1
    local remote_ip=$2
    local vxlan_interface=$3
    local key=$4

    # Command to add the VXLAN port
    local cmd="sudo ovs-vsctl add-port $local_bridge $vxlan_interface -- set Interface $vxlan_interface type=vxlan options:remote_ip=$remote_ip options:key=$key"

    # Display the command for visibility
    echo "Executing: $cmd"
    
    # Run the command
    eval $cmd
}

# Node 1 (192.168.188.231) VXLAN setup
if [ "$PRIMARY_IP" == "$NODE1_IP" ]; then
    echo "Configuring Node 1 ($NODE1_IP)"
    # n2br connections
    add_vxlan_port n2br $NODE2_IP vxlan_nuc1_n2_2 1002
    add_vxlan_port n2br $NODE3_IP vxlan_nuc1_n2_3 1003
    # n3br connections
    add_vxlan_port n3br $NODE2_IP vxlan_nuc1_n3_2 2002
    add_vxlan_port n3br $NODE3_IP vxlan_nuc1_n3_3 2003
    # n4br connections
    add_vxlan_port n4br $NODE2_IP vxlan_nuc1_n4_2 3002
    add_vxlan_port n4br $NODE3_IP vxlan_nuc1_n4_3 3003
fi

# Node 2 (192.168.188.232) VXLAN setup
if [ "$PRIMARY_IP" == "$NODE2_IP" ]; then
    echo "Configuring Node 2 ($NODE2_IP)"
    # n2br connections
    add_vxlan_port n2br $NODE1_IP vxlan_nuc2_n2_1 1001
    add_vxlan_port n2br $NODE3_IP vxlan_nuc2_n2_3 1003
    # n3br connections
    add_vxlan_port n3br $NODE1_IP vxlan_nuc2_n3_1 2001
    add_vxlan_port n3br $NODE3_IP vxlan_nuc2_n3_3 2003
    # n4br connections
    add_vxlan_port n4br $NODE1_IP vxlan_nuc2_n4_1 3001
    add_vxlan_port n4br $NODE3_IP vxlan_nuc2_n4_3 3003
fi

# Node 3 (192.168.188.233) VXLAN setup
if [ "$PRIMARY_IP" == "$NODE3_IP" ]; then
    echo "Configuring Node 3 ($NODE3_IP)"
    # n2br connections
    add_vxlan_port n2br $NODE1_IP vxlan_nuc3_n2_1 1001
    add_vxlan_port n2br $NODE2_IP vxlan_nuc3_n2_2 1002
    # n3br connections
    add_vxlan_port n3br $NODE1_IP vxlan_nuc3_n3_1 2001
    add_vxlan_port n3br $NODE2_IP vxlan_nuc3_n3_2 2002
    # n4br connections
    add_vxlan_port n4br $NODE1_IP vxlan_nuc3_n4_1 3001
    add_vxlan_port n4br $NODE2_IP vxlan_nuc3_n4_2 3002
fi

echo "VXLAN full mesh setup completed."
