## Certified Kubernetes Administrator (CKA) Exam Course Outline

[![cka-badge](https://training.linuxfoundation.org/wp-content/uploads/2019/03/logo_cka_whitetext-300x293.png)](https://training.linuxfoundation.org/certification/certified-kubernetes-administrator-cka/)

A set of exercises to help you prepare for the [Certified Kubernetes Administrator (CKA) Exam](https://www.cncf.io/certification/cka/)

This course outline is structured to align with the [CKA Curriculum v1.32](https://github.com/cncf/curriculum/blob/master/CKA_Curriculum_v1.32.pdf), following the recommended topic weights and a logical learning progression from foundational to advanced concepts.

---

| Module | Topic | GitHub Links | Video Link |
| :-- | :-- | :-- | :-- |
| 1. Introduction \& Kubernetes Basics | kubectl Basics and Configuration | [Link 1](Introduction_and_Basics/getting_started_with_docker.md),[Link 2](Introduction_and_Basics/kubectl_basics_and_conf.md) | [Video 1 - May 3, 2025](https://www.youtube.com/watch?v=kKfLotzx-Cs) |
|  | Kubernetes Architecture Overview | [Link 1](Introduction_and_Basics/Kubernetes_Architecture.md) | [Video 2 - May 18, 2025](https://www.youtube.com/watch?v=hPsKGywgxbM) |
|  | Cluster Components (Master, Node, etc.) | [Link 1](Introduction_and_Basics/Kubernetes_Architecture.md) | [Video 2 - May 18, 2025](https://www.youtube.com/watch?v=hPsKGywgxbM) |
| 2. Core Concepts (19%) | Pods: Anatomy, Lifecycle, and Management | [Link 1](Core_Concepts/Pods_Imperative_vs_Declarative.md) | [Video 3 - June 7, 2025](https://www.youtube.com/watch?v=7c7BOV8Ra54) |
|  | ReplicaSets and Deployments |  |  |
|  | Namespaces and Resource Isolation | [Link 1](Core_Concepts/What_Makes_Up_a_Kubernetes_Pod.md) |  |
|  | Labels, Selectors, and Annotations |  |  |
| 3. Scheduling (15%) | Manual Pod Scheduling |  |  |
|  | Node Selectors, Affinity, and Taints/Tolerations |  |  |
|  | DaemonSets and Static Pods |  |  |
| 4. Logging \& Monitoring (10%) | Cluster Logging Concepts |  |  |
|  | Monitoring Cluster Components |  |  |
|  | Application Logs and Troubleshooting |  |  |
| 5. Cluster Maintenance (11%) | Upgrading Kubernetes Components |  |  |
|  | Backup and Restore (etcd, resources) |  |  |
|  | Managing Certificates and Kubernetes Versions |  |  |
| 6. Networking (20%) | Cluster Networking Model |  |  |
|  | Services (ClusterIP, NodePort, LoadBalancer) |  |  |
|  | Network Policies |  |  |
|  | Ingress Controllers and Resources |  |  |
| 7. Storage (10%) | Volumes and Persistent Volumes |  |  |
|  | Persistent Volume Claims |  |  |
|  | Storage Classes and Dynamic Provisioning |  |  |
| 8. Security (12%) | Kubernetes Authentication and Authorization |  |  |
|  | RBAC and Service Accounts |  |  |
|  | Security Contexts and Pod Security Policies |  |  |
|  | Network Policies for Security |  |  |
| 9. Troubleshooting (13%) | Troubleshooting Pods and Nodes |  |  |
|  | Troubleshooting Networking |  |  |
|  | Troubleshooting Cluster Components |  |  |


---

- Modules are ordered from foundational to advanced, matching the natural learning curve and CKA exam blueprint.
- Topic weights (percentages) reflect their emphasis in the official [CKA Curriculum v1.32](https://github.com/cncf/curriculum/blob/master/CKA_Curriculum_v1.32.pdf).
- I will be updating GitHub Readme and YouTube video links as I develop content for each topic.

---

External references:
* ##### [Certified Kubernetes Administrator (CKA) Exam](cka_external_reference.md)

---

> For advanced usage or troubleshooting, review the comments in the script and consult the referenced documentation.
>
> v1.0.3 : release date: 2025-06-07
