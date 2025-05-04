#!/usr/bin/env bash

# Repo URL: https://github.com/The-Kubernetes-Show/kubernetes.git
# v1.0.0 # 2025-05-03
# This script is using "multipass" to create a 3 node cluster with 1 master and 2 workers
# Each node is assigned wtih 10GB disk, 3GB RAM and 2 CPUs and static IP.
# Please search for "multipass launch" to update the config to fit your needs.
# We are also assuming you have kubectl installed on your system.
# ------------------------------------------------------------
# Set some colors for status OK, FAIL and titles

SETCOLOR_SUCCESS="echo -en \\033[1;32m"
SETCOLOR_FAILURE="echo -en \\033[1;31m"
SETCOLOR_NORMAL="echo -en \\033[0;39m"

SETCOLOR_TITLE="echo -en \\033[1;36m" 	# Fuscia
SETCOLOR_NUMBERS="echo -en \\033[0;34m" # BLUE

# ------------------------------------------------------------
# Pre-install stuff
# ------------------------------------------------------------
# Check if multipass is installed
# https://multipass.run/docs/installing-on-linux
# https://multipass.run/docs/installing-on-mac
# https://multipass.run/docs/installing-on-windows
mkdir out 2> /dev/null && cd out
function preinstall {

	if ! which multipass > /dev/null 2>&1; then
		$SETCOLOR_TITLE
		echo "Install multipass per Unix/Linux OS: https://multipass.run/install"
		$SETCOLOR_NORMAL
		exit -1
	fi

	# Generate SSH key for VM user, we will use it for SSH connections to our VMs
	ssh-keygen -q -N "" -t rsa -b 2048 -C "vmuser" -f ./multipass-ssh-key

	# Generate cloud-init file for VM user and give it sudo rights
	# also adding ssh key to authorized_keys for the VM user
	# https://cloudinit.readthedocs.io/en/latest/topics/examples.html
	cat << EOF > ./cloud-init.yaml
users:
  - default
  - name: vmuser
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
    - $(cat multipass-ssh-key.pub)
EOF
	
	# cat ./cloud-init.yaml
}

# ------------------------------------------------------------
# Install K8S kubemaster01
# ------------------------------------------------------------

function install_kubemaster01 {

	host_name="kubemaster01"

	# To get images:
	# multipass aliases

	# get_host_status=$(multipass info ${host_name} | grep -Ei "Name" | awk '{print $2}' 2>&1 >/dev/null)
	get_host_status=$(multipass list | grep -Ei "${host_name}" 2>&1 >/dev/null)
	get_host_state=$(multipass list | grep -Ei "${host_name}" | awk '{print $2}')

	if [[ $? == 0 ]] && [[ ${#get_host_status} == 0 ]] && [[ $get_host_state != "Running" ]]; then

		# Install a kubemaster01 host wtih 10GB disk, 3GB RAM and 2 CPUs and static IP. 
		# Use cloud-init.yaml file
		multipass launch \
			--name ${host_name} \
			--disk 10G \
			--memory 3G \
			--cpus 2 \
			--network name=en0,mode=manual,mac="52:54:00:4b:ab:cd" \
			--cloud-init cloud-init.yaml \
			noble
	fi
	
	get_host_name=$(multipass info ${host_name} | grep -Ei "Name" | awk '{print $2}')
	get_host_ip=$(multipass info ${host_name} | grep IPv4 | awk '{print $2}')

	$SETCOLOR_SUCCESS
	echo "${get_host_name} - ${get_host_ip}"
	$SETCOLOR_NORMAL
	
# How to configure static IPs for multipass instances:
# https://github.com/canonical/multipass/blob/f0647878645ad4271c23aafbc638f88a33eab15f/docs/how-to-guides/manage-instances/configure-static-ips.md

	multipass exec -n ${host_name} -- sudo bash -c 'cat << EOF > /etc/netplan/10-custom.yaml
network:
  version: 2
  ethernets:
    extra0:
      dhcp4: no
      match:
        macaddress: "52:54:00:4b:ab:cd"
      addresses: [192.168.73.101/24]
EOF'

	multipass exec -n ${host_name} -- sudo bash -c 'netplan apply 2> /dev/null'
	multipass info ${host_name} | grep IPv4 -A1

}

# ------------------------------------------------------------
# Install kubeworker01
# ------------------------------------------------------------
function install_kubeworker01 {

	host_name="kubeworker01"

	# To get images:
	# multipass aliases

	# get_host_status=$(multipass info ${host_name} | grep -Ei "Name" | awk '{print $2}' 2>&1 >/dev/null)
	get_host_status=$(multipass list | grep -Ei "${host_name}" 2>&1 >/dev/null)
	get_host_state=$(multipass list | grep -Ei "${host_name}" | awk '{print $2}')

	if [[ $? == 0 ]] && [[ ${#get_host_status} == 0 ]] && [[ $get_host_state != "Running" ]]; then

		# Install the kubeworker01 node wtih 10GB disk, 3GB RAM and 2 CPUs and static IP.
		# Use cloud-init.yaml file
		multipass launch \
			--name ${host_name} \
			--disk 10G \
			--memory 3G \
			--cpus 2 \
			--network name=en0,mode=manual,mac="52:54:00:4b:ba:dc" \
			--cloud-init cloud-init.yaml \
			noble
	fi
	
	get_host_name=$(multipass info ${host_name} | grep -Ei "Name" | awk '{print $2}')
	get_host_ip=$(multipass info ${host_name} | grep IPv4 | awk '{print $2}')

	$SETCOLOR_SUCCESS
	echo "${get_host_name} - ${get_host_ip}"
	$SETCOLOR_NORMAL
	
	# How to configure static IPs for multipass instances:
	# https://github.com/canonical/multipass/blob/f0647878645ad4271c23aafbc638f88a33eab15f/docs/how-to-guides/manage-instances/configure-static-ips.md

	multipass exec -n ${host_name} -- sudo bash -c 'cat << EOF > /etc/netplan/10-custom.yaml
network:
  version: 2
  ethernets:
    extra0:
      dhcp4: no
      match:
        macaddress: "52:54:00:4b:ba:dc"
      addresses: [192.168.73.102/24]
EOF'

	multipass exec -n ${host_name} -- sudo bash -c 'netplan apply 2> /dev/null'
	multipass info ${host_name} | grep IPv4 -A1
	
}

# ------------------------------------------------------------
# Install kubeworker02
# ------------------------------------------------------------
function install_kubeworker02 {

	host_name="kubeworker02"

	# To get images:
	# multipass aliases

	# get_host_status=$(multipass info ${host_name} | grep -Ei "Name" | awk '{print $2}' 2>&1 >/dev/null)
	get_host_status=$(multipass list | grep -Ei "${host_name}" 2>&1 >/dev/null)
	get_host_state=$(multipass list | grep -Ei "${host_name}" | awk '{print $2}')

	if [[ $? == 0 ]] && [[ ${#get_host_status} == 0 ]] && [[ $get_host_state != "Running" ]]; then
		
		# Install the kubeworker01 node wtih 10GB disk, 3GB RAM and 2 CPUs and static IP.
		# Use cloud-init.yaml file
		multipass launch \
			--name ${host_name} \
			--disk 10G \
			--memory 3G \
			--cpus 2 \
			--network name=en0,mode=manual,mac="52:54:00:4b:cd:ab" \
			--cloud-init cloud-init.yaml \
			noble
	fi
	
	get_host_name=$(multipass info ${host_name} | grep -Ei "Name" | awk '{print $2}')
	get_host_ip=$(multipass info ${host_name} | grep IPv4 | awk '{print $2}')

	$SETCOLOR_SUCCESS
	echo "${get_host_name} - ${get_host_ip}"
	$SETCOLOR_NORMAL
	
	# How to configure static IPs for multipass instances:
	# https://github.com/canonical/multipass/blob/f0647878645ad4271c23aafbc638f88a33eab15f/docs/how-to-guides/manage-instances/configure-static-ips.md

	multipass exec -n ${host_name} -- sudo bash -c 'cat << EOF > /etc/netplan/10-custom.yaml
network:
  version: 2
  ethernets:
    extra0:
      dhcp4: no
      match:
        macaddress: "52:54:00:4b:cd:ab"
      addresses: [192.168.73.103/24]
EOF'

	multipass exec -n ${host_name} -- sudo bash -c 'netplan apply 2> /dev/null'
	multipass info ${host_name} | grep IPv4 -A1
}

function install_k8s_cluster {
	preinstall
	install_kubemaster01
	install_kubeworker01
	install_kubeworker02
	postinstall
}
# ------------------------------------------------------------
# Configure K8S cluster
# ------------------------------------------------------------
function configure_k8s_cluster {

	# host_ip_master="192.168.73.101"
	# host_ip_worker1="192.168.73.102"
	# host_ip_worker2="192.168.73.103"

	declare -a StringArray=(
	  "kubemaster01"
	  "kubeworker01"
	  "kubeworker02"
	)

	# Configure hosts
	# update /etc/hosts file on all VMs
	# confifigure modules
	# configure networking and netfiltering
	# install containerd # trying to run bleeding edge version
	# install runc  # trying to run bleeding edge version
	# install CNI plugin  # trying to run bleeding edge version
	# install kubeadm, kubelet and kubectl
	# configure crictl to work with containerd
	for host in ${StringArray[@]}; do
		multipass exec -n ${host} -- sudo bash -c 'echo "192.168.73.101 kubemaster01" >> /etc/hosts'
		multipass exec -n ${host} -- sudo bash -c 'echo "192.168.73.102 kubeworker01" >> /etc/hosts'
		multipass exec -n ${host} -- sudo bash -c 'echo "192.168.73.103 kubeworker02" >> /etc/hosts'

		multipass exec -n ${host} -- sudo bash -c 'echo "overlay" >> /etc/modules-load.d/k8s.conf'
		multipass exec -n ${host} -- sudo bash -c 'echo "br_netfilter" >> /etc/modules-load.d/k8s.conf'
		multipass exec -n ${host} -- sudo bash -c 'modprobe overlay 2> /dev/null'
		multipass exec -n ${host} -- sudo bash -c 'modprobe br_netfilter 2> /dev/null'

		multipass exec -n ${host} -- sudo bash -c 'cat << EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF'

		multipass exec -n ${host} -- sudo bash -c 'echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf'
		multipass exec -n ${host} -- sudo bash -c 'sysctl -p'

		multipass exec -n ${host} -- sudo bash -c 'lsmod | grep br_netfilter 2> /dev/null'
		multipass exec -n ${host} -- sudo bash -c 'lsmod | grep overlay 2> /dev/null'
		multipass exec -n ${host} -- sudo bash -c 'sysctl net.bridge.bridge-nf-call-iptables net.bridge.bridge-nf-call-ip6tables net.ipv4.ip_forward 2> /dev/null'
        multipass exec -n ${host} -- sudo bash -c 'arch=`uname -m`; if [ $arch == 'x86_64' ]; then echo 'amd64' >~/.arch; else echo 'arm64' >~/.arch; fi'

		# Install containerd  # trying to run bleeding edge version
		multipass exec -n ${host} -- sudo bash -c 'curl -LOs https://github.com/containerd/containerd/releases/download/v2.0.5/containerd-2.0.5-linux-`cat ~/.arch`.tar.gz'
		multipass exec -n ${host} -- sudo bash -c 'curl -LOs https://raw.githubusercontent.com/containerd/containerd/main/containerd.service'
		multipass exec -n ${host} -- sudo bash -c 'tar Cxzvf /usr/local containerd-2.0.5-linux-`cat ~/.arch`.tar.gz'
		multipass exec -n ${host} -- sudo bash -c 'mkdir -p /usr/local/lib/systemd/system/'
		multipass exec -n ${host} -- sudo bash -c 'mv containerd.service /usr/local/lib/systemd/system/'
		multipass exec -n ${host} -- sudo bash -c 'mkdir -p /etc/containerd/'
		multipass exec -n ${host} -- sudo bash -c 'containerd config default | tee /etc/containerd/config.toml > /dev/null'
		multipass exec -n ${host} -- sudo bash -c "sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml"
		multipass exec -n ${host} -- sudo bash -c 'systemctl daemon-reload'
		multipass exec -n ${host} -- sudo bash -c 'systemctl enable --now containerd'
		#multipass exec -n ${host} -- sudo bash -c 'systemctl status containerd'
		
		# Install runc  # trying to run bleeding edge version
		multipass exec -n ${host} -- sudo bash -c 'curl -LOs https://github.com/opencontainers/runc/releases/download/v1.3.0/runc.`cat ~/.arch`'
		multipass exec -n ${host} -- sudo bash -c 'install -m 755 runc.`cat ~/.arch` /usr/local/sbin/runc 2> /dev/null'

		# Install CNI plugins
		multipass exec -n ${host} -- sudo bash -c 'curl -LOs https://github.com/containernetworking/plugins/releases/download/v1.7.1/cni-plugins-linux-`cat ~/.arch`-v1.7.1.tgz'
		multipass exec -n ${host} -- sudo bash -c 'mkdir -p /opt/cni/bin'
		multipass exec -n ${host} -- sudo bash -c 'tar Cxzvf /opt/cni/bin cni-plugins-linux-`cat ~/.arch`-v1.7.1.tgz'

		# Install kubeadm, kubelet and kubectl
		multipass exec -n ${host} -- sudo bash -c 'apt-get update > /dev/null'
		multipass exec -n ${host} -- sudo bash -c 'apt-get install -y apt-transport-https ca-certificates curl gpg > /dev/null'
		multipass exec -n ${host} -- sudo bash -c 'curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg'
		multipass exec -n ${host} -- sudo bash -c "echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list"
		multipass exec -n ${host} -- sudo bash -c 'apt-get update > /dev/null'
		multipass exec -n ${host} -- sudo bash -c 'apt-get install -y kubelet kubeadm kubectl socat bash-completion 2> /dev/null'
		multipass exec -n ${host} -- sudo bash -c 'apt-mark hold kubelet kubeadm kubectl 2> /dev/null'  
		multipass exec -n ${host} -- sudo bash -c 'kubectl completion bash | tee /etc/bash_completion.d/kubectl > /dev/null'
		multipass exec -n ${host} -- sudo bash -c "echo 'alias k=kubectl' >> ~/.bashrc"
		multipass exec -n ${host} -- sudo bash -c "echo 'complete -o default -F __start_kubectl k' >> ~/.bashrc"

		# Configure crictl to work with containerd
		multipass exec -n ${host} -- sudo bash -c 'crictl config runtime-endpoint unix:///var/run/containerd/containerd.sock'
	done;

	# Configure controlplane node
	multipass exec -n kubemaster01 -- sudo bash -c 'kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=192.168.73.101' 
	multipass exec -n kubemaster01 -- sudo bash -c 'mkdir -p $HOME/.kube'
	multipass exec -n kubemaster01 -- sudo bash -c 'cp -i /etc/kubernetes/admin.conf $HOME/.kube/config'
	multipass exec -n kubemaster01 -- sudo bash -c 'chown $(id -u):$(id -g) $HOME/.kube/config'
	multipass exec -n kubemaster01 -- sudo bash -c 'kubectl -n kube-system get pods'
	
	# Install CNI network plugin cilium
	# https://docs.cilium.io/en/stable/gettingstarted/k8s-install-default/
	# https://docs.cilium.io/en/stable/gettingstarted/k8s-install-helm/#installing-cilium
	multipass exec -n kubemaster01 -- sudo bash -c 'curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash'
	multipass exec -n kubemaster01 -- sudo bash -c 'helm repo add cilium https://helm.cilium.io/'
	multipass exec -n kubemaster01 -- sudo bash -c 'helm install cilium cilium/cilium --version 1.17.3  --namespace kube-system'

	# Install Cilium CLI on master node
	# https://docs.cilium.io/en/stable/gettingstarted/k8s-install-helm/#installing-cilium-cli
	multipass exec -n kubemaster01 -- sudo bash -c 'CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
CLI_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}'

	multipass exec -n kubemaster01 -- sudo bash -c 'kubectl -n kube-system get pods && cilium status'

	# create join command for workers
	multipass exec -n kubemaster01 -- sudo bash -c 'kubeadm token create --print-join-command' > worker_join_command.sh
	# create a copy of admin.conf as kubeconfig for workers
	multipass exec -n kubemaster01 -- sudo bash -c 'cat /etc/kubernetes/admin.conf' > kubeconfig


	# Configure workers, copy join command and kubeconfig to workers and run join command
	multipass transfer worker_join_command.sh kubeworker01:
	multipass transfer worker_join_command.sh kubeworker02:
	multipass exec -n kubeworker01 -- sudo bash -c 'bash ./worker_join_command.sh'
	multipass exec -n kubeworker02 -- sudo bash -c 'bash ./worker_join_command.sh'
	multipass transfer kubeconfig kubeworker01:
	multipass transfer kubeconfig kubeworker02:

	# optional but we are doing it anyway. this is not a recommended way to do it
	multipass exec -n kubeworker01 -- sudo bash -c 'rm -rf ~/.kube && mkdir ~/.kube && mv ./kubeconfig ~/.kube/config'
	multipass exec -n kubeworker02 -- sudo bash -c 'rm -rf ~/.kube && mkdir ~/.kube && mv ./kubeconfig ~/.kube/config'

	# Check nodes and maybe do the cleanup too?
	# rm -f worker_join_command.sh
	# rm -f kubeconfig
	multipass exec -n kubemaster01 -- sudo bash -c 'kubectl get nodes'
}
# ------------------------------------------------------------
# Post-install stuff - mostly for TODOs / future improvements.
# ------------------------------------------------------------
function postinstall {
	
	declare -a StringArray=(
	  "kubemaster01"
	  "kubeworker01"
	  "kubeworker02"
	)

	$SETCOLOR_SUCCESS
	echo "Tune SSH"
	$SETCOLOR_NORMAL

	# Future improvements update /etc/ssh/sshd_config: 
		# https://www.digitalocean.com/community/tutorials/how-to-harden-openssh-on-ubuntu-20-04
		# https://hostman.com/tutorials/how-to-install-and-configure-ssh-on-an-ubuntu-server/

	# apt install openssh-server -y
	# Edit /etc/ssh/sshd_config
	# #PubkeyAuthentication yes

	# systemctl restart ssh

}

# ------------------------------------------------------------
# Generate kube-context for local usages
# ------------------------------------------------------------

function generate_context {
	$SETCOLOR_SUCCESS
	echo "Generate kube-context for local usages"
	$SETCOLOR_NORMAL

 	multipass exec -n kubemaster01 -- sudo bash -c "kubectl create clusterrolebinding cluster-admin-vmuser@kubernetes.local --user=vmuser@kubernetes.local --clusterrole='cluster-admin' --group='admins'"

	openssl genrsa -out vmuser.key 2048
	openssl req -new -key vmuser.key -out vmuser.csr -subj "/CN=vmuser@kubernetes.local"

# Create a CSR for the user
# https://kubernetes.io/docs/reference/access-authn-authz/certificate-signing-requests/#creating-a-csr-for-a-user
# expirationSeconds: 2592000 (30 days)
	cat << EOF > ./vmuser-csr.yaml
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: vmuser@kubernetes.local
spec:
  request: $(cat ./vmuser.csr | base64)
  signerName: kubernetes.io/kube-apiserver-client
  expirationSeconds: 2592000
  usages:
  - client auth
EOF
# copy the CSR to the master node and sign it, get the certificate to use it in kubeconfig.
	multipass transfer vmuser-csr.yaml kubemaster01:
	multipass exec -n kubemaster01 -- sudo bash -c 'kubectl create -f vmuser-csr.yaml'
	multipass exec -n kubemaster01 -- sudo bash -c 'kubectl certificate approve vmuser@kubernetes.local'
 	multipass exec -n kubemaster01 -- sudo bash -c 'kubectl get csr vmuser@kubernetes.local -ojsonpath="{.status.certificate}" | base64 -d > vmuser.crt'
	multipass transfer kubemaster01:vmuser.crt ./vmuser.crt

	get_host_ip=$(multipass info kubemaster01 | grep IPv4 | awk '{print $2}')

	kubectl config set-cluster kubernetes.local --server=https://${get_host_ip}:6443 --insecure-skip-tls-verify=true
	kubectl config set-credentials vmuser@kubernetes.local --client-key=vmuser.key --client-certificate=vmuser.crt --username='vmuser@kubernetes.local'
 	kubectl config set-context vmuser@kubernetes.local --cluster=kubernetes.local --user=vmuser@kubernetes.local
 	kubectl config use-context vmuser@kubernetes.local
 	kubectl get ns && kubectl get po
}

# ------------------------------------------------------------
# Get status of K8S cluster node status
# ------------------------------------------------------------
function status_all {
	declare -a StringArray=(
	  "kubemaster01"
	  "kubeworker01"
	  "kubeworker02"
	)

	for host in ${StringArray[@]}; do
		get_host_state=$(multipass list | grep -Ei "${host}" | awk '{print $2}')

		$SETCOLOR_SUCCESS
		echo "The ${host} has ${get_host_state} at this moment"
		$SETCOLOR_NORMAL
	done

	echo -e "\nTo connect to host use SSH, for example: \n"
	echo "ssh vmuser@192.168.73.101 -i ./multipass-ssh-key -o StrictHostKeyChecking=no"
	echo "ssh vmuser@192.168.73.102 -i ./multipass-ssh-key -o StrictHostKeyChecking=no"
	echo "ssh vmuser@192.168.73.103 -i ./multipass-ssh-key -o StrictHostKeyChecking=no"
}

# ------------------------------------------------------------
# Get status of K8S cluster components status
# ------------------------------------------------------------
function k8s_status_all {
	# check if nodes are running
	declare -a StringArray=(
	  "kubemaster01"
	  "kubeworker01"
	  "kubeworker02"
	)
		for host in ${StringArray[@]}; do
			get_host_state=$(multipass list | grep -Ei "${host}" | awk '{print $2}')

			if [[ -z "$get_host_state" ]]; then
				echo "The ${host} was not found. pleaes run '$0 install' to build the cluster."
				$SETCOLOR_NORMAL
				exit -1
			elif [[ "$get_host_state" =~ ^(Stopped|Suspended)$ ]]; then
					echo "The ${host} has ${get_host_state} at this moment, please run '$0 start' to start the cluster."
					$SETCOLOR_NORMAL
					exit -1
			else
				multipass exec -n kubemaster01 -- sudo bash -c 'kubectl -n kube-system get pods && kubectl create ns cilium-test'
				echo -e "\n-------------------------------------------------"
				echo -e "\nCreating resources for 'connectivity-check' in cilium-test namespace"
				echo -e "\n-------------------------------------------------"
				multipass exec -n kubemaster01 -- sudo bash -c 'kubectl apply -n cilium-test -f https://raw.githubusercontent.com/cilium/cilium/1.17.3/examples/kubernetes/connectivity-check/connectivity-check.yaml'
				echo -e "\n-------------------------------------------------"
				echo -e "\nWaiting for pods to be ready in cilium-test namespace"
				echo -e "\n-------------------------------------------------"
				multipass exec -n kubemaster01 -- sudo bash -c 'kubectl wait pod --all --for=condition=Ready --namespace=cilium-test && kubectl -n cilium-test get pods -o wide'
				echo -e "\n-------------------------------------------------"
				echo -e "\nPods are ready in cilium-test namespace, doing cleanup now"
				echo -e "\n-------------------------------------------------"
				multipass exec -n kubemaster01 -- sudo bash -c 'kubectl delete ns cilium-test --wait=0 --now'
				echo -e "\n-------------------------------------------------"
				echo -e "\nWaiting for pods to be deleted along with cilium-test namespace. timeout is 120s"
				echo -e "\n-------------------------------------------------"
				multipass exec -n kubemaster01 -- sudo bash -c 'kubectl -n cilium-test wait  pods --for=delete  --timeout=120s --all && kubectl get pods -A'
				echo -e "\n-------------------------------------------------"
				echo -e "\nNext test will check the connectivity between pods in different nodes and it takes around 15 minutes to complete"
				echo -e "\nWould you like to run command 'cilium connectivity test' (y/n)"
				read -r run_cilium_connectivity_test
				if [[ $run_cilium_connectivity_test =~ ^[Yy]$ ]]; then
					multipass exec -n kubemaster01 -- sudo bash -c 'cilium connectivity test'
				else
					echo -e "\n-------------------------------------------------"
					echo -e "\nSkipping 'cilium connectivity test'"
					echo -e "\n-------------------------------------------------"
				fi
				echo -e "\n-------------------------------------------------"
			fi
		$SETCOLOR_NORMAL
		done
}
# ------------------------------------------------------------
# Start all VMs
# ------------------------------------------------------------
function start_all {
	declare -a StringArray=(
		"kubemaster01"
	  "kubeworker01"
	  "kubeworker02"
	)

	for host in ${StringArray[@]}; do
		get_host_state=$(multipass list | grep -Ei "${host}" | awk '{print $2}')

		if [[ "$get_host_state" =~ ^(Stopped|Suspended)$ ]]; then
			multipass start ${host}
		else
			echo "The ${host} has ${get_host_state} at this moment"
		fi
	done

	multipass list
}
# ------------------------------------------------------------
# Stop all VMs
# ------------------------------------------------------------
function stop_all {
	declare -a StringArray=(
	  "kubeworker02"
	  "kubeworker01"
	  "kubemaster01"
	)

	for host in ${StringArray[@]}; do
		get_host_state=$(multipass list | grep -Ei "${host}" | awk '{print $2}')

		if [[ "$get_host_state" =~ ^(Running)$ ]]; then
			multipass stop ${host}
		else
			echo "The ${host} has ${get_host_state} at this moment"
		fi
	done

	multipass list
}

# ------------------------------------------------------------
# Create snapshots for all VMs #good to take backup before upgrade or making changes
# help to save time and resources 
# ------------------------------------------------------------
function snapshot_all {
	declare -a StringArray=(
	  "kubeworker02"
	  "kubeworker01"
	  "kubemaster01"
	)

	for host in ${StringArray[@]}; do
		get_host_state=$(multipass list | grep -Ei "${host}" | awk '{print $2}')

		if [[ "$get_host_state" =~ ^(Running)$ ]]; then
			multipass snapshot ${host}
		else
			echo "The ${host} has ${get_host_state} at this moment"
		fi
	done

	multipass list --snapshots
}

# ------------------------------------------------------------
# Uninstall or delete all VMs
# ------------------------------------------------------------	
function uninstall_all {
	declare -a StringArray=(
	  "kubeworker02"
	  "kubeworker01"
	  "kubemaster01"
	)

	for host in ${StringArray[@]}; do
		get_host_state=$(multipass list | grep -Ei "${host}" | awk '{print $2}')
		if [[ "$get_host_state" =~ ^(Running)$ ]]; then
			multipass stop ${host}
			multipass delete ${host}
			if [[ $? == 0 ]]; then
				echo "The ${host} has been deleted"
			else
				echo "There was an error while deleting ${host}. ${host} has not been deleted"
				echo "please try to delete it manually"
				echo "multipass delete ${host}"
				echo "multipass purge"
				exit -1
			fi
		elif [[ "$get_host_state" =~ ^(Stopped|Suspended)$ ]]; then
			multipass delete ${host}
			if [[ $? == 0 ]]; then
				echo "The ${host} has been deleted"
			else
				echo "There was an error while deleting ${host}. ${host} has not been deleted"
				echo "please try to delete it manually"
				echo "multipass delete ${host}"
				echo "multipass purge"
				exit -1
			fi			
			# elseif vm is not found
		elif [[ -z "$get_host_state" ]]; then
			echo "The ${host} was not found"
		fi
	done
	multipass purge
}

# ------------------------------------------------------------
case "$1" in
	preinstall)
    preinstall
    ;;
	install_k8s_cluster|install_k8s|install)
    install_k8s_cluster
	configure_k8s_cluster
	generate_context
    ;;
  postinstall)
    postinstall
    ;;
  generate_context|get_context|context)
    generate_context
    ;;
  status_all|status)
    status_all
    ;;
  k8s_status_all|k8s_status)
	k8s_status_all
	;;
  start_all|start)
    start_all
    ;;
  stop_all|stop)
    stop_all
	;;
  uninstall_all|uninstall)
    uninstall_all	
    ;;
  help|h|-h)
	$SETCOLOR_NUMBERS
	echo "Set 'preinstall' as ARG to pre-install some stuff for K8S cluster"
    echo "Set 'install' as ARG to install K8S cluster"
    echo "Set 'postinstall' as ARG to postinstall something else, mostly left out for TODOs / future improvements"
    echo "Set 'context' as ARG to re-generate kube-context for local usages"
    echo "Set 'status' as ARG to get status of K8S cluster nodes"
	echo "Set 'k8s_status' as ARG to get status of K8S cluster components and test cilium connectivity"
    echo "Set 'start' as ARG to start K8S cluster"
    echo "Set 'stop' as ARG to stop K8S cluster"
	echo "Set 'uninstall_all' as ARG to uninstall all VMs"
    echo "Set 'snapshot_all' as ARG to create snapshots"
    $SETCOLOR_NORMAL
    ;;
  *)
		$SETCOLOR_TITLE
    echo "Use 'help' to get help!"
    $SETCOLOR_NORMAL
    ;;
esac

$SETCOLOR_SUCCESS
echo "# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "#                              Finish!								 "
echo "# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
$SETCOLOR_NORMAL
