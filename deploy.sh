#!/bin/bash

# Function to display help
show_help() {
    echo "Usage: deploy_free5gc.sh [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --ovs           Install Open vSwitch (OVS) bridges on nodes"
    echo "  --mongodb       Deploy MongoDB"
    echo "  --gtp5g         Install gtp5g kernel module"
    echo "  --free5gc       Deploy Free5GC core services"
    echo "  --webui         Deploy Free5GC Web UI"
    echo "  --ueransim      Deploy UERANSIM (gNB and UE simulator)"
    echo "  --all           Deploy all components (Default)"
    echo "  --help          Display this help and exit"
}

# Parse arguments
INSTALL_OVS=false
INSTALL_MONGODB=false
INSTALL_GTP5G=false
INSTALL_FREE5GC=false
INSTALL_WEBUI=false
INSTALL_UERANSIM=false

if [[ $# -eq 0 ]]; then
    INSTALL_OVS=true
    INSTALL_MONGODB=true
    INSTALL_GTP5G=true
    INSTALL_FREE5GC=true
    INSTALL_WEBUI=true
    INSTALL_UERANSIM=true
else
    while [[ $# -gt 0 ]]; do
        case $1 in
            --ovs)
                INSTALL_OVS=true
                ;;
            --mongodb)
                INSTALL_MONGODB=true
                ;;
            --gtp5g)
                INSTALL_GTP5G=true
                ;;
            --free5gc)
                INSTALL_FREE5GC=true
                ;;
            --webui)
                INSTALL_WEBUI=true
                ;;
            --ueransim)
                INSTALL_UERANSIM=true
                ;;
            --all)
                INSTALL_OVS=true
                INSTALL_MONGODB=true
                INSTALL_GTP5G=true
                INSTALL_FREE5GC=true
                INSTALL_WEBUI=true
                INSTALL_UERANSIM=true
                ;;
            --help)
                show_help
                exit 0
                ;;
            *)
                echo "Unknown option $1"
                show_help
                exit 1
                ;;
        esac
        shift
    done
fi

# Create namespace for Free5GC
kubectl create namespace free5gc || echo "Namespace already exists"

# Step 1: Set up Open vSwitch (OVS) Bridges on nodes
if [ "$INSTALL_OVS" = true ]; then
    echo "Setting up OVS Bridges..."
    for node in $(kubectl get nodes -o name); do
        ssh root@$node 'ovs-vsctl add-br br1'
    done
    echo "OVS Bridges set up."
fi

# Step 2: Deploy MongoDB
if [ "$INSTALL_MONGODB" = true ]; then
    echo "Deploying MongoDB..."
    kubectl apply -k mongodb -n free5gc
    kubectl wait --for=condition=ready pod -l app=mongodb -n free5gc
    echo "MongoDB deployed."
fi

# Step 3: Install the gtp5g kernel module
if [ "$INSTALL_GTP5G" = true ]; then
    echo "Installing gtp5g kernel module..."
    for node in $(kubectl get nodes -o name); do
        ssh root@$node 'git clone https://github.com/free5gc/gtp5g.git && cd gtp5g && make && sudo make install'
    done
    echo "gtp5g kernel module installed."
fi

# Step 4: Deploy Free5GC components
if [ "$INSTALL_FREE5GC" = true ]; then
    echo "Deploying Free5GC core services..."
    kubectl apply -k free5gc -n free5gc
    echo "Free5GC core services deployed."
fi

# Step 5: Deploy Free5GC Web UI
if [ "$INSTALL_WEBUI" = true ]; then
    echo "Deploying Free5GC Web UI..."
    kubectl apply -k webui -n free5gc
    echo "Free5GC Web UI deployed."
fi

# Step 6: (Optional) Deploy UERANSIM for gNB and UE simulation
if [ "$INSTALL_UERANSIM" = true ]; then
    echo "Deploying UERANSIM..."
    kubectl apply -k ueransim -n free5gc
    echo "UERANSIM deployed."
fi

echo "Deployment script finished."
