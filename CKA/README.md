## Certified Kubernetes Administrator (CKA) Exam Course Outline

[![cka-badge](https://training.linuxfoundation.org/wp-content/uploads/2019/03/logo_cka_whitetext-300x293.png)](https://training.linuxfoundation.org/certification/certified-kubernetes-administrator-cka/)

A set of exercises to help you prepare for the [Certified Kubernetes Administrator (CKA) Exam](https://www.cncf.io/certification/cka/)

This course outline is structured to align with the [CKA Curriculum v1.34](https://github.com/cncf/curriculum/blob/master/CKA_Curriculum_v1.34.pdf), following the recommended topic weights and a logical learning progression from foundational to advanced concepts.

---
#### Prerequisite: a list of topics already covered "before" aligning to latest CKA Curriculum
> ###### These topics are "still relevent and an excellent place to start". These topics give you deep insights into the concepts of K8S which comes handy to pass the CKA exam.

---

| Module | Topic | GitHub Links | Video Link |
| :-- | :-- | :-- | :-- |
| Introduction \& Kubernetes Basics | kubectl Basics and Configuration | ✅ [Link 1](Introduction_and_Basics/getting_started_with_docker.md) ✅ [Link 2](Introduction_and_Basics/kubectl_basics_and_conf.md) | [Video 1 - May 3, 2025](https://www.youtube.com/watch?v=kKfLotzx-Cs) |
|  | Kubernetes Architecture Overview | ✅ [Link 1](Introduction_and_Basics/Kubernetes_Architecture.md) | [Video 2 - May 18, 2025](https://www.youtube.com/watch?v=hPsKGywgxbM) |
|  | Cluster Components (Master, Node, etc.) | ✅ | ✅ |
| Core Concepts | Pods: Anatomy, Lifecycle, and Management | ✅ [Link 1](Core_Concepts/Pods_Imperative_vs_Declarative.md) ✅ [Link 2](Core_Concepts/kubernetes-core-concepts-hands-on-guide.md) | [Video 3 - June 7, 2025](https://www.youtube.com/watch?v=7c7BOV8Ra54) |
|  | Namespaces and Resource Isolation | ✅ [Link 1](Core_Concepts/What_Makes_Up_a_Kubernetes_Pod.md) ✅ [Link 2](Core_Concepts/kubernetes-core-concepts-hands-on-guide.md) | [Video 4 - June 22, 2025](https://www.youtube.com/watch?v=6sEiEIyr-Zc) |
|  | ReplicaSets and Deployments | ✅ | ✅  |
|  | Labels, Selectors, and Annotations | ✅ | ✅  |
| Scheduling | Manual Pod Scheduling | ✅ [Link 1](Scheduling/Kubernetes%20Pod%20Scheduling%20&%20Placement.md) | [Video 5 - July 13, 2025](https://youtu.be/quIx23Vq8W0) |
|  | Node Selectors, Affinity, and Taints/Tolerations | ✅ | ✅ |
|  | DaemonSets and Static Pods | ✅ | ✅ |
| Logging \& Monitoring | Cluster Logging Concepts | ✅ [Link 1](Troubleshooting/cka_4_logging_and_monitoring.md) | [Video 6 - Aug 9, 2025](https://youtu.be/9W2GQVOkCKI) |
|  | Monitoring Cluster Components | ✅ | ✅ |
|  | Application Logs and Troubleshooting | ✅ | ✅ |

---

### Latest CKA Curriculum v1.34 (as of Nov 2025)

| Module | Topic | GitHub Links | Video Link |
| :-- | :-- | :-- | :-- |
| 1. Troubleshooting (30%) | Troubleshoot clusters and nodes | ✅ [Link 1](Troubleshooting/cka_4_logging_and_monitoring.md) | ✅ [Video - Aug 9, 2025](https://youtu.be/9W2GQVOkCKI) |
|  | Troubleshoot cluster components | ✅ | ✅ |
|  | Monitor cluster and application resource usage | ✅ | ✅ |
|  | Manage and evaluate container output streams | ✅ | ✅ |
|  | Troubleshoot services and networking | ✅[Link 1](Troubleshooting/cka_troubleshoot_svc_and_networking.md) | ✅ [Video - Aug 16, 2025](https://www.youtube.com/watch?v=qs0i_pxlx3Y) |
| 2. Workloads & Scheduling (15%) | Understand deployments and how to perform rolling update and rollbacks | ✅ [Link 1](Core_Concepts/kubernetes-core-concepts-hands-on-guide.md), ✅ [Link 2](Scheduling/Workloads%20and%20Scheduling%20Part%202.md) | ✅ [Video - June 7, 2025](https://www.youtube.com/watch?v=7c7BOV8Ra54), ✅ [Video - Sept 1, 2025](https://www.youtube.com/watch?v=5GJPi1oTw8Q) |
|  | Use ConfigMaps and Secrets to configure applications | ✅ [Link 2](Scheduling/Workloads%20and%20Scheduling%20Part%202.md), ✅ [Link 3](Scheduling/Workloads%20and%20Scheduling%20Part%203.md) | ✅ [Video - Sept 21, 2025](https://youtu.be/PP-kVkpKc60) |
|  | Configure workload autoscaling | ✅ | ✅ |
|  | Understand primitives for robust, self-healing apps | ✅ | ✅ |
|  | Configure Pod admission and scheduling (limits, affinity, taints, tolerations) | ✅ [Link 1](Scheduling/Kubernetes%20Pod%20Scheduling%20&%20Placement.md) | ✅ [Video - July 13, 2025](https://youtu.be/quIx23Vq8W0) |
|  | Awareness of manifest management and templating tools | ✅ [Link 2](Scheduling/Workloads%20and%20Scheduling%20Part%202.md), ✅ [Link 3](Scheduling/Workloads%20and%20Scheduling%20Part%203.md) | ✅ [Video - Sept 21, 2025](https://youtu.be/PP-kVkpKc60) |
| 3. Cluster Architecture, Installation & Configuration (25%) | Manage role-based access control (RBAC) | ✅ [Link 1](Cluster_Architecture_Installation_Configuration/Cluster_Architecture_Installation_Configuration.md) | ✅ [Video - Oct 18, 2025](https://youtu.be/nP4OHhB5ZkA) |
|  | Prepare underlying infrastructure for installing a Kubernetes cluster | ✅ | ✅ |
|  | Create and manage Kubernetes clusters using kubeadm | ✅ | ✅ |
|  | Manage the lifecycle of Kubernetes clusters | ✅ | ✅ |
|  | Implement and configure a highly-available control plane | ✅ | ✅ |
|  | Perform version upgrades on Kubernetes clusters | ✅ | ✅ |
|  | Implement etcd backup and restore (Optional) | ✅ | ✅ |
|  | Use Helm and Kustomize to install cluster components | ✅ | ✅ |
|  | Understand extension interfaces (CNI, CSI, CRI, etc.) | ✅ | ✅ |
|  | Understand CRDs, install and configure operators | ✅ | ✅ |
| 4. Services & Networking (20%) | Understand connectivity between Pods | ✅ [Link 1](Services_and_Networking/Services_and_Networking.md) | ✅ [Video - Nov 05, 2025](TBD) |
|  | Define and enforce Network Policies | ✅ | ✅ |
|  | Use ClusterIP, NodePort, LoadBalancer service types and endpoints | ✅ | ✅ |
|  | Use the Gateway API to manage Ingress traffic | ✅ | ✅ |
|  | Use Ingress controllers and Ingress resources | ✅ | ✅ |
|  | Understand and use CoreDNS | ✅ | ✅ |
| 5. Storage (10%) | Implement storage classes and dynamic volume provisioning | ⏳ | ⏳ |
|  | Configure volume types, access modes and reclaim policies | ⏳ | ⏳ |
|  | Manage persistent volumes and persistent volume claims | ⏳ | ⏳ |

---

- Modules are ordered from foundational to advanced, matching the natural learning curve and CKA exam blueprint.
- Topic weights (percentages) reflect their emphasis in the official [CKA Curriculum v1.34](https://github.com/cncf/curriculum/blob/master/CKA_Curriculum_v1.34.pdf).
- I will be updating GitHub Readme and YouTube video links as I develop content for each topic.


External references:
* ##### [Certified Kubernetes Administrator (CKA) Exam](cka_external_reference.md)

---

> For advanced usage or troubleshooting, review the comments in the script and consult the referenced documentation.
>
> v1.0.5 : release date: 2025-11-05
