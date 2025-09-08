#!/bin/bash

# OpenWebUI VM Setup Script for macOS with Multipass
# This script creates a new VM, copies installation files, and runs OpenWebUI setup
# 
# Prerequisites: 
# - Multipass installed on macOS (brew install multipass)
# - Files: openwui-no-caddy-version.md and openwebui-no-caddy-install.sh in current directory

set -e  # Exit on any error

# Configuration
VM_NAME="owui-vm-nc-test-1"
VM_CPUS="2"
VM_MEMORY="4G"
VM_DISK="20G"
UBUNTU_VERSION="22.04"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Check if multipass is installed
check_multipass() {
    if ! command -v multipass &> /dev/null; then
        print_error "Multipass is not installed. Please install it first:"
        echo "  brew install multipass"
        exit 1
    fi
    print_status "Multipass is installed"
}

# Check if required files exist
check_files() {
    if [[ ! -f "openwebui-no-caddy-install.sh" ]]; then
        print_error "openwebui-no-caddy-install.sh not found in current directory"
        exit 1
    fi
    
    if [[ ! -f "openwui-no-caddy-version.md" ]]; then
        print_error "openwui-no-caddy-version.md not found in current directory"
        exit 1
    fi
    
    print_status "Required files found"
}

# Clean up existing VM if it exists
cleanup_existing_vm() {
    if multipass list | grep -q "^$VM_NAME"; then
        print_warning "VM '$VM_NAME' already exists. Removing it..."
        multipass stop $VM_NAME 2>/dev/null || true
        multipass delete $VM_NAME
        multipass purge
        print_status "Existing VM removed"
    fi
}

# Create and launch VM
create_vm() {
    print_step "Creating new Ubuntu VM: $VM_NAME"
    print_status "Specifications: $VM_CPUS CPUs, $VM_MEMORY RAM, $VM_DISK disk"
    
    multipass launch $UBUNTU_VERSION \
        --name $VM_NAME \
        --cpus $VM_CPUS \
        --memory $VM_MEMORY \
        --disk $VM_DISK
    
    print_status "VM created successfully"
}

# Вспомогательная функция: выполняет команду с таймаутом, если доступен (gtimeout/timeout)
run_with_timeout() {
    local seconds="$1"; shift
    if command -v gtimeout >/dev/null 2>&1; then
        gtimeout "$seconds" "$@"
    elif command -v timeout >/dev/null 2>&1; then
        timeout "$seconds" "$@"
    else
        "$@"
    fi
}

# Ожидание готовности ВМ (IPv4 + завершение cloud-init), с защитой от зависания multipass exec
wait_for_vm() {
    print_status "Waiting for VM to be ready..."

    # ВАЖНО: флаги перед именем (исправление)
    multipass start --timeout 600 "$VM_NAME"

    # 1) Ждём, пока появится IPv4
    local max_attempts=60
    local attempt=1
    while [ "$attempt" -le "$max_attempts" ]; do
        if multipass info "$VM_NAME" | awk '/^IPv4/ && $2 != "" {found=1} END{exit !found}'; then
            print_status "VM has an IPv4 address"
            break
        fi
        print_status "Waiting for IPv4... (attempt $attempt/$max_attempts)"
        sleep 5
        attempt=$((attempt+1))
    done
    if [ "$attempt" -gt "$max_attempts" ]; then
        print_error "VM did not obtain an IPv4 address in time"
        exit 1
    fi

    # 2) Ждём завершение cloud-init (файл boot-finished),
    #    multipass exec обёрнут в таймаут, чтобы попытка не зависла навсегда
    attempt=1
    while [ "$attempt" -le "$max_attempts" ]; do
        if run_with_timeout 10 multipass exec "$VM_NAME" -- bash -lc 'test -f /var/lib/cloud/instance/boot-finished'; then
            print_status "VM is ready (cloud-init finished)"
            return 0
        fi
        print_status "Waiting for cloud-init... (attempt $attempt/$max_attempts)"
        sleep 5
        attempt=$((attempt+1))
    done

    print_error "VM failed to become ready within expected time"
    exit 1
}

# Copy files to VM
copy_files() {
    print_step "Copying installation files to VM"
    
    # Copy the installation script
    multipass transfer openwebui-no-caddy-install.sh $VM_NAME:/home/ubuntu/
    print_status "Copied openwebui-no-caddy-install.sh"
    
    
    # Make installation script executable
    multipass exec $VM_NAME -- chmod +x /home/ubuntu/openwebui-no-caddy-install.sh
    print_status "Made installation script executable"
}

# Run installation
run_installation() {
    print_step "Running OpenWebUI installation on VM"
    print_status "This may take 10-15 minutes..."
    
    # Run the installation script
    multipass exec $VM_NAME -- /home/ubuntu/openwebui-no-caddy-install.sh
    
    print_status "Installation completed!"
}

# Get VM information
get_vm_info() {
    print_step "VM Information"
    
    # Get VM IP address
    VM_IP=$(multipass info $VM_NAME | grep IPv4 | awk '{print $2}')
    
    echo ""
    echo "=========================================="
    echo "OpenWebUI VM Setup Complete!"
    echo "=========================================="
    echo ""
    echo "VM Details:"
    echo "  Name: $VM_NAME"
    echo "  IP Address: $VM_IP"
    echo "  CPUs: $VM_CPUS"
    echo "  Memory: $VM_MEMORY"
    echo "  Disk: $VM_DISK"
    echo ""
    echo "Access OpenWebUI:"
    echo "  URL: http://$VM_IP:8080"
    echo ""
    echo "VM Management Commands:"
    echo "  Connect to VM:     multipass shell $VM_NAME"
    echo "  Stop VM:          multipass stop $VM_NAME"
    echo "  Start VM:         multipass start $VM_NAME"
    echo "  Delete VM:        multipass delete $VM_NAME && multipass purge"
    echo "  VM Status:        multipass list"
    echo ""
    echo "Next Steps:"
    echo "1. Open http://$VM_IP:8080 in your browser"
    echo "2. Register the first user (becomes admin)"
    echo "3. Follow the post-installation steps from the script output"
    echo ""
    print_warning "Note: Make sure your firewall allows access to port 8080"
    echo ""
}

# Main execution
main() {
    echo "=========================================="
    echo "OpenWebUI VM Setup for macOS"
    echo "=========================================="
    echo ""
    
    print_step "Pre-flight checks"
    check_multipass
    check_files
    
    cleanup_existing_vm
    create_vm
    wait_for_vm
    copy_files
    run_installation
    get_vm_info
    
    print_status "Setup completed successfully!"
}

# Handle script interruption
trap 'print_error "Script interrupted. VM may be in incomplete state."; exit 1' INT TERM

# Run main function
main "$@"
