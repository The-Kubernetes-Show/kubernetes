# Local Kubernetes Cluster: 3 node install using Multipass

#### [YouTube video link](https://youtu.be/kKfLotzx-Cs)
This repository provides a Bash script to automate the creation of a local Kubernetes cluster using [Multipass](https://multipass.run/). The cluster consists of one master node and two worker nodes, each provisioned with static IPs, dedicated resources, and the latest Kubernetes components.

## What is Multipass?
Get an instant Ubuntu VM with a single command. Multipass can launch and run virtual machines and configure them with cloud-init like a public cloud. Prototype your cloud launches locally for free. To install and read more about it, please visit [install page](https://canonical.com/multipass/install)

## Why was it created?
- For local learning, no depdency on clouds.
- A disposable kubernetes cluster for hands-on learning.
- Could be used as a tool to prepare for [CNCF exams](https://www.cncf.io/training/).

## Features

- **Kubernetes version 1.33**
- **Automated provisioning** of 3 Ubuntu VMs (1 master, 2 workers) via Multipass
- **Static IP assignment** for all nodes
- **Cloud-init** user configuration with SSH key generation
- **Automated installation** of containerd, runc, CNI plugins, kubeadm, kubelet, and kubectl
- **Cilium CNI** installed via Helm for advanced networking
- **Automated cluster initialization** and worker node joining
- **Post-install configuration** for ease of use
- **Easy Rollback** use of snapshots to easily rollback, no need to reinstall everything. 

## Prerequisites

- **macOS or Linux** with [Multipass](https://multipass.run/install) installed
- **kubectl** installed locally
- **curl**, **ssh-keygen**, and **bash** available in your environment
- **Laptop/Desktop** with enough resources (see **Resources per VM** section for details)

## Usage

```bash
chmod +x install_k8s_cluster_v33.sh
./install_k8s_cluster_v33.sh
```

> **Note:** You may need to run the script with `sudo` depending on your environment and Multipass configuration.

## What the Script Does

### 1. Pre-Installation

- **Checks for Multipass:** Verifies that Multipass is installed; exits with instructions if not.
- **Generates SSH Keys:** Creates an SSH key pair for VM access.
- **Creates Cloud-Init Config:** Prepares a `cloud-init.yaml` file to set up a `vmuser` with passwordless sudo and the generated SSH key.

### 2. VM Provisioning

- **Creates 3 VMs:**
  - **Master:** `kubemaster01` (`192.168.73.101`)
  - **Worker 1:** `kubeworker01` (`192.168.73.102`)
  - **Worker 2:** `kubeworker02` (`192.168.73.103`)
- **Resources per VM:** 10GB disk, 3GB RAM, 2 CPUs
- **Configures Static IPs:** Uses custom netplan configuration for each VM

### 3. Kubernetes Component Installation

On all nodes:
- Updates `/etc/hosts` with cluster node mappings
- Loads required kernel modules and sysctl settings
- Installs:
  - **containerd** (container runtime)
  - **runc** (low-level container runtime)
  - **CNI plugins** (networking)
  - **kubeadm, kubelet, kubectl** (Kubernetes core components)
- Configures `crictl` to use containerd

### 4. Cluster Initialization

- **Initializes master node** with `kubeadm init` (using Flannel pod network CIDR)
- **Sets up kubectl config** for the master
- **Installs Cilium CNI** via Helm
- **Installs Cilium CLI** for cluster networking status

### 5. Worker Node Joining

- **Generates join command** on master and transfers it to workers
- **Runs join command** on each worker to join the cluster
- **Transfers kubeconfig** to workers for kubectl access

### 6. Post-Installation

- **Verifies cluster status** by running `kubectl get nodes` on the master

## Customization

- **Resource Allocation:** Adjust `--disk`, `--memory`, and `--cpus` flags in the script for each VM to fit your needs.
- **Static IPs:** Update the netplan YAML sections for different IPs as needed.
- **Kubernetes/CNI Versions:** Modify the version numbers in the download URLs for containerd, runc, CNI plugins, and Cilium as required.

## Troubleshooting

- **Multipass Network Issues:** Ensure your network interface (`en0` by default) matches your Mac's primary interface.
- **Static IP Assignment:** Refer to [Multipass documentation](https://github.com/canonical/multipass/blob/main/docs/how-to-guides/manage-instances/configure-static-ips.md) for static IP troubleshooting.
- **Resource Constraints:** Ensure your Mac has sufficient resources to run three VMs simultaneously.

## References

- [Multipass Documentation](https://multipass.run/docs)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Cilium Documentation](https://docs.cilium.io/en/stable/)
- [Cloud-init Documentation](https://cloudinit.readthedocs.io/en/latest/topics/examples.html)

---
## Other Tools / Options to Run Kubernetes locally.

For running Kubernetes locally and quickly, consider using tools like **[Minikube](https://minikube.sigs.k8s.io/docs/)**, **[Kind](https://kind.sigs.k8s.io/)**, **[K3s](https://k3s.io/)**, or **[MicroK8s](https://microk8s.io/)**. These tools provide single-node or multi-node local Kubernetes clusters on your machine, making them ideal for development and testing.

### **[Minikube](https://minikube.sigs.k8s.io/docs/)**

- **Pros:** Easy to install and use, great for beginners.
- **Cons:** Single-node cluster, may not be suitable for complex deployments.
- **Good for:** Getting started with Kubernetes, testing basic applications.

### **[Kind](https://kind.sigs.k8s.io/)**

- **Pros:** Multi-node cluster, more flexible for testing complex scenarios.
- **Cons:** Requires more configuration than Minikube.
- **Good for:** Testing multi-node applications, more advanced deployments.

### **[K3s](https://k3s.io/)**

- **Pros:** Lightweight, designed for constrained environments, suitable for CI/CD.
- **Cons:** Fewer features than Minikube or Kind.
- **Good for:** Local development in CI/CD pipelines, resource-constrained environments.

### **[MicroK8s](https://microk8s.io/)**

- **Pros:** Similar to K3s, lightweight, easy to manage.
- **Cons:** Fewer features than Minikube or Kind.
- **Good for:** Local development in CI/CD pipelines, resource-constrained environments.


---

> For advanced usage or troubleshooting, review the comments in the script and consult the referenced documentation.
>
> v1.0.0 : release date: 2025-05-03
