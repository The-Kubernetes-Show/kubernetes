# Workloads & Scheduling Hands-On Guide

This guide covers the following important Kubernetes topics to complement previous material:

1. Understand Deployments and How to Perform Rolling Updates and Rollbacks  
2. Understand Primitives for Robust, Self-Healing Applications  
3. Configure Workload Autoscaling  
4. Use ConfigMaps and Secrets to Configure Applications
5. Awareness of Manifest Management and Templating Tools

---

## Understand Deployments and Rolling Updates & Rollbacks

A **Deployment** provides declarative updates for Pods and ReplicaSets. You define the desired state, and the Deployment controller manages changing the actual state to the desired state at a controlled rate.

### Key Features

- Create or update ReplicaSets in the background.
- Perform controlled rolling updates by updating the `.spec.template` of Pods.
- Supports pausing, resuming, and rollback of rollouts.
- Ensures a certain number of Pods are available during updates (rolling update strategy).

### Example Deployment Manifest

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
        image: nginx:1.14.2
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"
```

Apply it with:

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/website/main/content/en/examples/controllers/nginx-deployment.yaml
kubectl get deployments
kubectl rollout status deployment/nginx-deployment

```

### Rolling Update Example

Update the image version:

```bash
kubectl set image deployment/nginx-deployment nginx=nginx:1.16.1
kubectl rollout status deployment/nginx-deployment
```

### Rollback Example

If the rollout fails or is unstable, roll back to the previous stable version:

```bash
kubectl rollout undo deployment/nginx-deployment
```

Rollback to a specific revision:

```bash
kubectl rollout undo deployment/nginx-deployment --to-revision=2
```

### Additional Commands

- Pause rollout:  

```bash
kubectl rollout pause deployment/nginx-deployment
```

- Resume rollout:

```bash
kubectl rollout resume deployment/nginx-deployment
```

- Rollout history:

```bash
kubectl rollout history deployment/nginx-deployment

```

### Official Documentation Links for Deployments and rollouts:-

- [Deployments Concept](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- [kubectl rollout](https://kubernetes.io/docs/reference/kubectl/cheatsheet/#managing-deployments)

---

## Primitives for Robust, Self-Healing Applications

Kubernetes provides primitives to build self-healing applications:

- **Pods** are ephemeral and can be automatically recreated by higher level controllers (e.g., Deployment, ReplicaSet) on failure.
- **Restart Policies** determine Pod container restart behavior (`Always`, `OnFailure`, `Never`).
- **Liveness, Readiness, and Startup Probes** enable Kubernetes to detect unhealthy containers and restart/remove them accordingly.

### Example: Using Probes in Pod Spec

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: goproxy
  labels:
    app: goproxy
spec:
  containers:
  - name: goproxy
    image: registry.k8s.io/goproxy:0.1
    ports:
    - containerPort: 8080
    readinessProbe:
      tcpSocket:
        port: 8080
      initialDelaySeconds: 15
      periodSeconds: 10
    livenessProbe:
      tcpSocket:
        port: 8080
      initialDelaySeconds: 15
      periodSeconds: 10
    startupProbe:
      tcpSocket:
        port: 8080
      failureThreshold: 30
      periodSeconds: 10
```

### Handling Container Failures

- Kubernetes restarts containers based on the Pod's `restartPolicy`.
- Containers can fail and cause a CrashLoopBackOff state. Diagnosing using logs and describe commands is critical.

### Official Documentation Links for Probes:-

- [Pod Lifecycle](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/)
- [Configure Liveness, Readiness, and Startup Probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)

---

## Configure Workload Autoscaling

Kubernetes supports **automatic scaling** of workloads in two ways:

- **Horizontal Pod Autoscaler (HPA):** Scales the number of pod replicas based on observed CPU/memory or custom metrics.
- **Vertical Pod Autoscaler (VPA):** Adjusts the resource requests of the containers (experimental outside core Kubernetes).

### Example: Create Horizontal Pod Autoscaler

```bash
kubectl autoscale deployment nginx-deployment --min=1 --max=5 --cpu-percent=80
```

This creates an HPA that scales Pods between 1 and 5 replicas to maintain about 80% CPU utilization.

### Notes

- The Metrics Server must be installed in your cluster for HPA to work.
- You can also scale workloads manually with `kubectl scale`.

### Official Documentation Links for Pod Autoscaling:-

- [Autoscaling Workloads](https://kubernetes.io/docs/concepts/workloads/autoscaling/)
- [Horizontal Pod Autoscaling Walkthrough](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/)
- [Event driven Autoscaling (KEDA)](https://keda.sh/)
- [Resize CPU and Memory Resources assigned to Containers](https://kubernetes.io/docs/tasks/configure-pod-container/resize-container-resources/)

---

## Use ConfigMaps and Secrets to Configure Applications

### ConfigMaps

- Store **non-confidential** configuration as key-value pairs.
- Inject configuration into Pods as environment variables, command-line arguments, or files in volumes.
- Allows decoupling configuration from container image.
- A ConfigMap is not designed to hold large chunks of data. The data stored in a ConfigMap cannot exceed 1 MiB. If you need to store settings that are larger than this limit, you may want to consider mounting a volume or use a separate database or file service.

### Example ConfigMap

```bash

apiVersion: v1
kind: ConfigMap
metadata:
  name: my-config
data:
  DATABASE_HOST: db.example.local
  LOG_LEVEL: "DEBUG"
```

Use in Pod environment variables:

```yaml
      env:        # Define the environment variable
        - name: DATABASE_HOST # Notice that the case is different here
          valueFrom: # from the key name in the ConfigMap.
            configMapKeyRef:
              name: my-config           # The ConfigMap this value comes from.
              key: DATABASE_HOST # The key to fetch.
        - name: LOG_LEVEL
          valueFrom:
            configMapKeyRef:
              name: my-config
              key: LOG_LEVEL
```

### Official Documentation Links for configmaps

- [ConfigMaps](https://kubernetes.io/docs/concepts/configuration/configmap/)
- [Using ConfigMaps as Environment Variables](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/#define-container-environment-variables-using-configmap-data)
- [kubectl create configmap](https://kubernetes.io/docs/reference/kubectl/generated/kubectl_create/kubectl_create_configmap/)

---

### Secrets

- Store **sensitive data** like passwords, tokens, or keys.
- Similar to ConfigMaps but designed for confidentiality.
- Can be mounted as volumes or exposed through environment variables.
- Should use encryption at rest and RBAC to limit access.
- Secrets are encoded in base64, which is not encryption. For true security, consider using tools like HashiCorp Vault or AWS Secrets Manager.
- Note: Individual Secrets are limited to 1MiB in size. This is to discourage creation of very large Secrets that could exhaust the API server and kubelet memory. However, creation of many smaller Secrets could also exhaust memory. You can use a resource quota to limit the number of Secrets (or other resources) in a namespace.
- You cannot use ConfigMaps or Secrets with static Pods (Static Pods are managed directly by the kubelet daemon on a specific node, without the API server observing them.)
- Depending on how you created the Secret, as well as how the Secret is used in your Pods, updates to existing Secret objects are propagated automatically to Pods that use the data. e.g. Secrets used as "environment variables" are not automatically updated in running Pods. If a Secret is updated, the new value will not be reflected in the Pod until it is restarted, but Secrets used as files in a volume are eventually updated. The kubelet checks the mounted Secret volume for updates. This update is "eventually consistent," meaning there will be a delay, typically from a few seconds to a minute or more, before the changes are propagated. Your application must be coded to detect and react to these file changes.
- Kubernetes lets you mark specific Secrets (and ConfigMaps) as `immutable`. Preventing changes to the data (use RBAC) of an existing Secret (or ConfigMap) can help avoid accidental updates that could cause application failures.

### Example Secret Manifest

```yaml
apiVersion: v1
kind: Secret
metadata:
    name: my-secret
type: Opaque
data:
    username: bXktdXNlcg==  \# base64 encoded 'my-user'
    password: bXktcGFzc3dvcmQ=  \# base64 encoded 'my-password'

```

Use Secret in Pod environment variables:

```yaml
env:
  - name: SECRET_USERNAME
    valueFrom:
        secretKeyRef:
        name: my-secret
        key: username
  - name: SECRET_PASSWORD
    valueFrom:
        secretKeyRef:
        name: my-secret
        key: password
```

### Official Documentation Links for Secrets

- [Secrets](https://kubernetes.io/docs/concepts/configuration/secret/)
- [Using Secrets as Environment Variables](https://kubernetes.io/docs/tasks/inject-data-application/distribute-credentials-secure/#define-container-environment-variables-using-secret-data)
- [kubectl create secret](https://kubernetes.io/docs/reference/kubectl/generated/kubectl_create/kubectl_create_secret/)

---

## Awareness of Manifest Management and Templating Tools

While Kubernetes manifests are traditionally YAML files directly applied with `kubectl`, managing them at scale benefits from tools and templating systems to:

- Maintain DRY (Don't Repeat Yourself) configurations.
- Manage environments and overlays.
- Facilitate complex templating.
- Integrate with CI/CD pipelines.
- Version control and collaboration.
- Automate deployments using GitOps principles.


### Common Approaches Include

- **Kustomize:** Built into `kubectl` for customizing manifests via overlays and patches.  
- **Helm:** A package manager for Kubernetes, uses templates with variables and charts for reusable manifests.  
- **Other tools:** Operators, Jsonnet, and scripting to generate manifests.

### Example Manifest Structure

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-nginx-svc
  labels:
    app: nginx
spec:
  type: LoadBalancer
  ports:
  - port: 80
  selector:
    app: nginx
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-nginx
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
        image: nginx:1.14.2
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"
```

These files are applied via:

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/website/main/content/en/examples/application/nginx-app.yaml
```

Advanced manifest management helps in multi-environment deployments, version control, and automation.

### Official Documentation Links for Manifest Management tools:-

- [Managing Workloads](https://kubernetes.io/docs/concepts/workloads/management/)
- [Kustomize](https://kubectl.docs.kubernetes.io/guides/introduction/kustomize/)
- [Helm](https://helm.sh/docs/)
- [GitOps with ArgoCD](https://argo-cd.readthedocs.io/en/stable/)
- [GitOps with Flux](https://fluxcd.io/docs/)
- [Operators](https://kubernetes.io/docs/concepts/extend-kubernetes/operator/)
- [Jsonnet](https://jsonnet.org/)

Hands on tools:

- [Kustomize on Killercoda](https://killercoda.com/online-marathon/course/K8s/K8_Lab)
- [Helm Tutorial on Killercoda](https://killercoda.com/helm-scenarios)

---

## Homework Assignments

1. Create a Deployment manifest for a simple web application (e.g., nginx) with 3 replicas.  
2. Perform a rolling update by changing the container image version and observe the rollout status using `kubectl rollout status`.  
3. Experiment with rolling back to a previous Deployment revision with `kubectl rollout undo`.  
4. Create a ConfigMap and a Secret with custom configuration data. Use them in a Pod manifest both as environment variables and mounted volumes.  
5. Set up a HorizontalPodAutoscaler for the Deployment you created and simulate load to see autoscaling in action (using a tool like `stress` container).  
6. Explore `kubectl` plugins or tools like Kustomize or Helm to template your manifests and customize Deployment for two different environments (e.g., dev and prod).  

---

## Additional Resources

- [Kubernetes Official Documentation](https://kubernetes.io/docs/home/)
- [Kubernetes GitHub Repository](github.com/kubernetes/kubernetes)
- [Kubernetes Tutorials](https://kubernetes.io/docs/tutorials/)
- [Killer.sh - Kubernetes Playground](https://killercoda.com)
