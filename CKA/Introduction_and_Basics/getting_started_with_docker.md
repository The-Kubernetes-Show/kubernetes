# Projects Folder Overview

This folder contains projects related to Docker and containerized applications. Below is a summary of the contents:

## 1. [Docker Project](docker_project.md)

#### [YouTube video link](https://youtu.be/kKfLotzx-Cs)

---

# Topics Covered in "The Kubernetes Show" (May 4, 2025)

## 1. Introduction
- Overview of the episode and target audience
- Reference to previous episodes (Linux basics)
- Focus on advanced users

## 2. History of Virtualization
- Early days: IBM mainframes and the 1960s
- Motivation for virtualization (hardware utilization, environment segregation)
- Concept of running multiple operating systems on a single machine

## 3. Types of Virtualization
- Hardware virtualization
- Operating system virtualization
- Network and storage virtualization (brief mention)

## 4. Hypervisors
- Definition and role of a hypervisor
- Type 1 (bare metal) hypervisors
- Type 2 (hosted) hypervisors
- Performance considerations (layering and speed)
- Examples of each type

## 5. Transition to Containers
- Limitations of VMs (resource usage, maintenance, attack surface)
- Introduction of Docker (2013)
- Concept of containers (analogy with physical containers/boxes)
- Benefits of containers over VMs (speed, simplicity, isolation)
- Linux features enabling containers (namespaces, cgroups, `unshare` command)

## 6. Containerization in Practice
- Running processes in containers vs. VMs
- Packaging dependencies with the application
- Live demonstration (running a web server in a container)

## 7. Container Orchestration Challenges
- Scaling containers across multiple hosts
- Managing large numbers of containers
- The need for orchestration tools

## 8. Introduction to Kubernetes
- Kubernetes as a container orchestration platform
- Analogy: Docker whale and Kubernetes helm/wheel
- Managing thousands of containers and nodes

## 9. Kubernetes Architecture
- Two main components: Control Plane and Worker Nodes
- Control Plane components:
    - kube-apiserver (API server, the brain)
    - kube-scheduler (scheduling pods)
    - kube-controller-manager (control loops, health checks)
    - etcd (key-value store for configuration)
    - cloud-controller-manager (cloud provider integration)
- Worker Node components:
    - kubelet (manages pods on the node)
    - kube-proxy (networking/proxy, uses iptables/eBPF)
    - Container Runtime Interface (CRI)
- Additional interfaces:
    - Container Network Interface (CNI)
    - Container Storage Interface (CSI)

## 10. Hands-On: Building and Running a Containerized Web Server
- Overview of provided GitHub repository and files
- Application structure (Python app, index.html, /hostname endpoint)
- Prerequisites and tools needed
- Running the sample container

## 11. References and Further Learning
- Links to GitHub repository
- Mention of future episodes (e.g., deeper dive into etcd)

---

**Note:**  
- For code samples, scripts, and further hands-on instructions, refer to the [GitHub repository](https://github.com/The-Kubernetes-Show/kubernetes/).
- The video is a mix of theory, history, and practical demonstration, suitable for both intermediate and advanced users.

---
> For advanced usage or troubleshooting, review the comments in the scripts and consult the referenced documentation.
>
> v1.0.0 : release date: 2025-05-03
