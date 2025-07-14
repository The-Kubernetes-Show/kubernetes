# Kubernetes Pod Scheduling and Placement

#### [YouTube video link](https://youtu.be/quIx23Vq8W0)

This document covers Kubernetes Pod Scheduling and Placement, which is part of the Certified Kubernetes Administrator (CKA) exam curriculum. It explores key concepts, practical examples, and hands-on exercises for mastering Pod scheduling techniques, focusing on manual scheduling, node selection strategies, and specialized Pod deployments. The content aligns with the CKA exam's scheduling section (15%), covering manual Pod scheduling, Node Selectors, Affinity, and Taints/Tolerations, as well as DaemonSets and Static Pods.

## Overview

Kubernetes scheduling is the process of assigning Pods to nodes in a cluster based on resource availability, constraints, and policies. Understanding how to effectively schedule Pods is crucial for optimizing resource utilization and ensuring application performance.

---

## Key Concepts

- **Manual Pod Scheduling**: Directly assigning a Pod to a specific node using the `nodeName` field.
- **Node Selectors**: Using labels to constrain Pods to specific nodes.
- **Affinity and Anti-Affinity**: Defining rules for Pod placement based on node or Pod labels.
- **Taints and Tolerations**: Mechanisms to control which Pods can be scheduled on nodes with specific taints.
- **DaemonSets**: Ensuring a Pod runs on all or specific nodes in the cluster.
- **Static Pods**: Pods managed directly by the kubelet, defined in manifest files on the node.

---

## 1. Manual Pod Scheduling

Manual Pod Scheduling involves directly assigning a Pod to a specific node by specifying the `nodeName` field in the Pod spec. This bypasses the default Kubernetes scheduler, giving you full control over Pod placement for special cases or troubleshooting.

**Example YAML:**

Save yaml file to a file named `manual-scheduled-pod.yaml`. it should look like this:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: manual-scheduled-pod
spec:
  nodeName: kubeworker01
  containers:
  - name: nginx
    image: nginx
```

**Command to create:**

```sh
kubectl apply -f manual-scheduled-pod.yaml
```

Check the Pod placement:

```bash
kubectl get pods -o wide
```

---

## 2. Node Selectors, Affinity, and Taints/Tolerations

### Node Selectors

Node Selectors allow you to constrain a Pod to run only on nodes with specific labels. It’s the simplest form of node selection.

**Definition:**
A Node Selector uses the `nodeSelector` field in the Pod spec to match node labels, ensuring Pods run only on nodes meeting specified criteria.

**Example YAML:**

Save yaml file to a file named `pod-with-selector.yaml`. it should look like this:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-with-selector
spec:
  nodeSelector:
    disktype: ssd
  containers:
  - name: nginx
    image: nginx
```

Create the node label and apply the YAML:

```sh
kubectl label nodes kubeworker02 disktype=ssd
kubectl apply -f pod-with-selector.yaml
```

Check the Pod placement:

```bash
kubectl get pods -o wide
```

### Affinity and Anti-Affinity

Affinity rules provide more expressive ways to influence Pod placement, supporting both required and preferred scheduling constraints based on node or Pod labels.

**Definition:**
Affinity and anti-affinity allow fine-grained control over Pod placement, using rules based on node or Pod labels, such as co-locating or separating Pods.

**Example YAML (Node Affinity):**

Save yaml file to a file named `pod-with-affinity.yaml`. it should look like this:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-with-affinity
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: disktype
            operator: In
            values:
            - ssd
  containers:
  - name: nginx
    image: nginx
```

Create apply the YAML:

```bash
kubectl apply -f pod-with-affinity.yaml
```

### Taints and Tolerations

Taints and Tolerations work together to prevent Pods from being scheduled onto inappropriate nodes unless they tolerate the taints applied.

**Definition:**
Taints are applied to nodes to repel Pods, while tolerations are set on Pods to allow them to be scheduled onto tainted nodes.

**Example YAML (Toleration):**

save yaml file to a file named `pod-with-toleration.yaml`. it should look like this:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-with-toleration
spec:
  tolerations:
  - key: "dedicated"
    operator: "Equal"
    value: "special"
    effect: "NoSchedule"
  containers:
  - name: nginx
    image: nginx
```

---

## 3. DaemonSets and Static Pods

### DaemonSets

A DaemonSet ensures that a copy of a Pod runs on all (or some) nodes in the cluster. It is commonly used for cluster-wide services such as log collection or monitoring.

**Definition:**
DaemonSets automatically deploy a Pod to every node, making them ideal for running background or system-level tasks across the cluster.

**Example YAML:**

Save yaml file to a file named `daemonset-fluentd.yaml`. it should look like this:

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: fluentd
spec:
  selector:
    matchLabels:
      name: fluentd
  template:
    metadata:
      labels:
        name: fluentd
    spec:
      containers:
      - name: fluentd
        image: fluent/fluentd
```

### Static Pods

Static Pods are managed directly by the kubelet on a node, not by the Kubernetes API server. They are defined in manifest files placed in a specific directory on the node.

**Definition:**
Static Pods are automatically started by the kubelet if a manifest file exists on the node, ideal for critical system components.

**Example YAML:**

Save yaml file to a file named `static-nginx.yaml`. it should look like this:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: static-nginx
spec:
  containers:
  - name: nginx
    image: nginx
```

**NOTE:** *Save this file to the kubelet manifest directory on the `kubemaster01` node, e.g., `/etc/kubernetes/manifests/`.*

---

## CKA Exam Practice Questions

**Q1:** Schedule a Pod named `nginx-manual` on node `kubeworker02` using manual scheduling.

**Solution:**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-manual
spec:
  nodeName: kubeworker02
  containers:
  - name: nginx
    image: nginx
```

```sh
kubectl apply -f nginx-manual.yaml
```

**Q2:** Create a Pod that only runs on nodes labeled `zone=us-east1`.

**Solution:**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-east
spec:
  nodeSelector:
    zone: us-east1
  containers:
  - name: nginx
    image: nginx
```

```sh
kubectl label node <node-name> zone=us-east1
kubectl apply -f nginx-east.yaml
```

**Q3:** Deploy a DaemonSet to run `busybox` on all nodes.

**Solution:**

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: busybox-ds
spec:
  selector:
    matchLabels:
      app: busybox
  template:
    metadata:
      labels:
        app: busybox
    spec:
      containers:
      - name: busybox
        image: busybox
        command: ["sleep", "3600"]
```

```sh
kubectl apply -f busybox-ds.yaml
```

---

## Homework for Hands-On Practice

- Manually schedule a Pod on a specific node and verify its placement.
- Label nodes and use node selectors to control Pod scheduling.
- Create a Pod using node affinity and another using anti-affinity.
- Apply taints to a node and create a Pod that tolerates it.
- Deploy a DaemonSet and confirm Pods are running on all nodes.
- Create a Static Pod by placing a manifest in the kubelet manifest directory and observe its lifecycle.

## Conclusion

Mastering Kubernetes Pod Scheduling and Placement is essential for effective cluster management and resource optimization. By understanding the various scheduling techniques, including manual scheduling, node selectors, affinity rules, and DaemonSets, you can ensure that your applications run efficiently and reliably across the cluster. Regular practice with hands-on exercises and real-world scenarios will help solidify your understanding and prepare you for the CKA exam.

---

Happy learning! 🚀

## References

- [Manual Scheduling](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/)
- [Node Selectors](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector)
- [Affinity and Anti-Affinity](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity)
- [Taints and Tolerations](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/)
- [DaemonSets](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/)
- [Static Pods](https://kubernetes.io/docs/tasks/configure-pod-container/static-pod/)