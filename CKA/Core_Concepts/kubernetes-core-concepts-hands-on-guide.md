# Kubernetes Core Concepts: Hands-On Guide to ReplicaSets, Deployments, Namespaces, and Labels

This guide introduces key Kubernetes concepts with hands-on examples and practical exercises. By the end, you'll be able to:

- Define and deploy ReplicaSets and Deployments
- Use Namespaces for resource isolation
- Apply Labels, Selectors, and Annotations

---

## Table of Contents

- [What Makes Up a Kubernetes Pod?](#what-makes-up-a-kubernetes-pod)
- [ReplicaSets and Deployments](#replicasets-and-deployments)
  - [Hands-On: Creating a ReplicaSet](#hands-on-creating-a-replicaset)
  - [Hands-On: Creating a Deployment](#hands-on-creating-a-deployment)
- [Namespaces and Resource Isolation](#namespaces-and-resource-isolation)
  - [Hands-On: Working with Namespaces](#hands-on-working-with-namespaces)
- [Labels, Selectors, and Annotations](#labels-selectors-and-annotations)
  - [Hands-On: Using Labels and Annotations](#hands-on-using-labels-and-annotations)
- [Homework](#homework)

---

## What Makes Up a Kubernetes Pod?

A Pod is the smallest deployable unit in Kubernetes. It can contain one or more containers, storage resources, a unique network IP, and options that govern how the container(s) should run. Pods are ephemeral and are managed by higher-level controllers like ReplicaSets and Deployments.

---

## ReplicaSets and Deployments

**ReplicaSets** ensure that a specified number of identical Pods are running at all times. If a Pod fails, the ReplicaSet automatically creates a new one to maintain the desired state.

**Deployments** provide declarative updates for Pods and ReplicaSets. They manage the rollout and rollback of application versions, making them ideal for production workloads.

---

| Feature                | ReplicaSet (Replicates)                                                                                     | Deployment                                                                                                         |
|------------------------|-------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------|
| Purpose                | Ensures a specified number of identical pods are running at all times.                                      | Manages ReplicaSets and provides higher-level features for application lifecycle management.                       |
| Level                  | Lower-level Kubernetes object.                                                                              | Higher-level Kubernetes object.                                                                                    |
| Updates                | Does not support rolling updates or rollbacks directly.                                                     | Supports declarative updates, rolling updates, and rollbacks for zero-downtime deployments.                        |
| Lifecycle Management   | Limited to maintaining pod replicas and scaling.                                                            | Manages full application lifecycle: scaling, updates, rollbacks, and history tracking.                             |
| Usage                  | Can be used directly, but typically managed by a Deployment.                                                | Preferred method for managing stateless applications, automatically creates and manages ReplicaSets.               |
| Self-healing           | Replaces failed pods to maintain desired replica count.                                                     | Ensures desired state is maintained and replaces failed pods, with additional management features.                  |
| Typical Workflow       | Define ReplicaSet, specify pod template and replica count.                                                  | Define Deployment, which creates and manages ReplicaSets and pods based on desired state.                          |
| Rolling Updates        | Not supported directly; requires manual intervention.                                                       | Supported natively, enabling seamless updates to application versions.                                             |
| Rollbacks              | Not supported directly.                                                                                     | Supported, allowing easy rollback to previous versions if issues occur.                                            |


### Hands-On: Creating a ReplicaSet

1. Save the following YAML as `frontend-replicaset.yaml`:

    ```yaml
    apiVersion: apps/v1
    kind: ReplicaSet
    metadata:
      name: frontend
      labels:
        app: guestbook
        tier: frontend
    spec:
      replicas: 3
      selector:
        matchLabels:
          tier: frontend
      template:
        metadata:
          labels:
            tier: frontend
        spec:
          containers:
          - name: php-redis
            image: us-docker.pkg.dev/google-samples/containers/gke/gb-frontend:v5
    ```

2. Apply the ReplicaSet:

    ```bash
    kubectl apply -f frontend-replicaset.yaml
    ```

3. Check the ReplicaSet and Pods:

    ```bash
    kubectl get rs
    kubectl get pods
    kubectl describe rs/frontend
    ```

### Hands-On: Creating a Deployment

1. Save the following YAML as `nginx-deployment.yaml`:

    ```yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: nginx-deployment
      labels:
        app: nginx
    spec:
      replicas: 3
      selector:
        matchLabels:
          app: nginx
      template:
        metadata:
          labels:
            app: nginx
        spec:
          containers:
          - name: nginx
            image: nginx:1.20.2
            ports:
            - containerPort: 80
    ```

2. Apply the Deployment:

    ```bash
    kubectl apply -f nginx-deployment.yaml
    ```

3. Check Deployment, ReplicaSet, and Pods:

    ```bash
    kubectl get deployments
    kubectl get rs
    kubectl get pods --show-labels
    ```

4. Describe the Deployment and use label selectors:

```bash
    kubectl describe deployment nginx-deployment
    # label selector example
    kubectl get pods -l app=nginx
```

5. Scale the Deployment:

```bash
    kubectl scale deployment nginx-deployment --replicas=5
    kubectl get pods
    kubectl get deployment nginx-deployment
    kubectl describe deployment nginx-deployment
    kubectl get rs
    kubectl describe rs/nginx-deployment-xxxxx

```

---

## Namespaces and Resource Isolation

Namespaces allow you to partition cluster resources between multiple users or teams. They provide a scope for names and are commonly used for:

- Environment separation (dev, test, prod)
- Resource quotas and limits
- Access control

### Hands-On: Working with Namespaces

1. Create a new namespace:

    ```bash
    kubectl create namespace dev
    ```

2. Deploy a Pod in the `dev` namespace:

    ```yaml
    # Save as pod-in-dev.yaml
    apiVersion: v1
    kind: Pod
    metadata:
      name: nginx
      namespace: dev
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
    ```

    ```bash
    kubectl apply -f pod-in-dev.yaml
    ```

3. View resources in the `dev` namespace:

    ```bash
    kubectl get pods -n dev
    ```

4. Set a resource quota in the namespace:

    ```yaml
    # Save as quota.yaml
    apiVersion: v1
    kind: ResourceQuota
    metadata:
      name: dev-quota
      namespace: dev
    spec:
      hard:
        pods: "2"
        requests.cpu: "1"
        requests.memory: 1Gi
        limits.cpu: "2"
        limits.memory: 2Gi
    ```

    ```bash
    kubectl apply -f quota.yaml
    kubectl describe quota dev-quota -n dev
    ```

---

## Labels, Selectors, and Annotations

- **Labels** are key/value pairs attached to objects for identification and selection.
- **Selectors** are queries against labels, used by controllers to manage sets of objects.
- **Annotations** store non-identifying metadata, such as build info or monitoring configs.

### Hands-On: Using Labels and Annotations

1. Apply labels and annotations to a Pod:

    ```yaml
    # Save as labeled-pod.yaml
    apiVersion: v1
    kind: Pod
    metadata:
      name: labeled-pod
      labels:
        app: demo
        environment: test
      annotations:
        description: "This pod is for demonstrating labels and annotations"
        maintainer: "student@example.com"
    spec:
      containers:
      - name: nginx
        image: nginx
    ```

    ```bash
    kubectl apply -f labeled-pod.yaml
    ```

2. List Pods with a label selector:

```bash
    kubectl get pods -l app=demo
```

3. Label a pod

```bash
    kubectl label pod <pod-name> env=production
    kubectl get pods --show-labels
    kubectl describe pod <pod-name>
```

4. View annotations:

```bash
    kubectl get pod labeled-pod -o yaml
```

5. Create annotation on existing pod

```bash
    kubectl annotate pod labeled-pod version=1.0.0
    kubectl get pod labeled-pod -o yaml
    kubectl describe pod labeled-pod
```

---

## Homework

1. **Create a Namespace called `team-a` and deploy a Deployment with 2 replicas of the `nginx` image in it.**
2. **Add a ResourceQuota to `team-a` to limit the number of Pods to 3.**
3. **Label your Deployment with `team=alpha` and `project=website`.**
4. **Use a label selector to list all Pods in `team-a` with the label `project=website`.**
5. **Add an annotation to your Deployment with your name and the current date.**
6. **Experiment: Scale your Deployment to 4 replicas. What happens? Why?**
7. **Extra Credit:** Write a YAML manifest for a Pod with at least 2 containers, each with different labels and annotations.

---

Happy learning! 🚀

References:

- [kubernetes.io Replicaset](https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/)
- [kubernetes.io deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- [kubernetes.io namespaces](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)
- [kubernetes.io labels](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/)
- [kubernetes.io annotations](https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/)
