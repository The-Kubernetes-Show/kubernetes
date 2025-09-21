# Workloads & Scheduling: ConfigMaps, Secrets, and Manifest Management

Welcome back Kubernetes Explorers! Today's session digs deeper into managing application configuration with ConfigMaps and Secrets, then levels up with hands-on approaches for manifest templating using Kustomize and Helm. Mastering these tools is essential for the CKA, especially for real teams shipping real software.

---

#### [YouTube video link](TBD)

---

## Using ConfigMaps and Secrets to Configure Applications

Kubernetes wants you to keep your config and secrets out of your container images. Instead, you use ConfigMaps and Secrets for things like environment variables, config files, and API keys. This keeps images reusable and makes credentials easy to rotate.

### Example: Using ConfigMap

Create a ConfigMap from the CLI and inject it as environment variables:

```sh
kubectl create configmap greeter-config --from-literal=GREETING=Hello --from-literal=AUDIENCE=Kubernetes
```

Attach the ConfigMap to your Pod:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: greeter
spec:
  containers:
    - name: greeter
      image: busybox
      command: ["sh", "-c", "echo $GREETING $AUDIENCE"]
      envFrom:
        - configMapRef:
            name: greeter-config
```

See more: [ConfigMaps](https://kubernetes.io/docs/concepts/configuration/configmap/)

---

### Example: Using Secret

Create a Secret (base64-encoded, not encrypted!) for your DB credentials:

```sh
kubectl create secret generic db-login --from-literal=DB_USER=admin --from-literal=DB_PASS=supersecret
```

Consume the Secret as environment variables in your deployment:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: db-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: db-app
  template:
    metadata:
      labels:
        app: db-app
    spec:
      containers:
        - name: db-app
          image: busybox
          command: ["sh", "-c", "echo $DB_USER $DB_PASS"]
          env:
            - name: DB_USER
              valueFrom:
                secretKeyRef:
                  name: db-login
                  key: DB_USER
            - name: DB_PASS
              valueFrom:
                secretKeyRef:
                  name: db-login
                  key: DB_PASS
```

Docs: [Secrets](https://kubernetes.io/docs/concepts/configuration/secret/)

---

## Manifest Management and Templating Tools

Manual copy-pasting YAML for each environment is a pain. Kubernetes lets you manage resources declaratively (YAML/JSON files)—but templating tools help you stay DRY.

### Imperative vs Declarative Patterns

- Quick & dirty: `kubectl run nginx --image=nginx`
(good for learning, bad for teamwork!)
- Repeatable & collaborative:
Store YAML manifests in Git, apply with `kubectl apply -f <file>`

Get a manifest skeleton anytime:

`kubectl create deployment nginx --image=nginx --dry-run=client -o yaml > deployment.yaml`

Cheat sheet: [kubectl Quick Reference](https://kubernetes.io/docs/reference/kubectl/quick-reference/)

---

## Kustomize: Native Overlay Management

Kustomize comes built into kubectl (`kubectl apply -k`). It’s a template-free way to create base manifests and environment-specific overlays.

### Example: Kustomize Directory Structure

```
.
├── base
│   ├── deployment.yaml
│   ├── service.yaml
│   └── kustomization.yaml
└── overlays
    ├── dev
    │   └── kustomization.yaml
    └── prod
        └── kustomization.yaml
```

- **base/kustomization.yaml** lists the resources

```yaml
resources:
  - deployment.yaml
  - service.yaml
```

- **overlays/dev/kustomization.yaml** overlays and patches for dev

```yaml
resources:
  - ../../base
patchesStrategicMerge:
  - deployment-patch.yaml
```

A patch file (ex: deployment-patch.yaml) in overlays/dev might change the image tag or set replicas to 1 for dev:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: db-app
spec:
  replicas: 1
```

Apply your overlay with:

`kubectl apply -k overlays/dev`

Learn more here: [Kustomize Docs](https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/)

Additional: You can even generate Secrets from files using [Managing Secrets using Kustomize](https://kubernetes.io/docs/tasks/configmap-secret/managing-secret-using-kustomize/).

---

## Helm: Powerful Chart-Based Templating

Helm is the package manager for Kubernetes. You write “charts” that templatize manifests using Go templating and variables, making it easy to deploy and upgrade apps across clusters.

### Example: Helm Chart Structure

Suppose you want a parameterized deployment. Your manifest (deployment.yaml) might look like:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Values.name }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: {{ .Values.name }}
  template:
    metadata:
      labels:
        app: {{ .Values.name }}
    spec:
      containers:
        - name: {{ .Chart.Name }}
          image: "nginx:{{ .Values.image.tag }}"
```

Values come from values.yaml:

```yaml
replicaCount: 2
name: my-app
image:
  tag: "1.21"
```

When you install your chart with
`helm install hello ./hello-chart --values values.yaml`,
the placeholders are filled with your values.

Learn more: [Helm Docs](https://helm.sh/docs/)

---

Hands on tools:

- [Kustomize on Killercoda](https://killercoda.com/online-marathon/course/K8s/K8_Lab)
- [Helm Tutorial on Killercoda](https://killercoda.com/helm-scenarios)

---

## Hands-on Practice

- Build a Kustomize base + two overlays for "dev" and "prod". Patch the replica count and image tag in each overlay.
- Make a Helm chart for an nginx deployment, letting the image tag and replica count be set in values.yaml. Install your chart locally!
- Generate a Secret using Kustomize, and mount it in a Deployment.
- Compare: How does templating with Helm differ from overlaying with Kustomize? What are the pros and cons in team settings?

---

## Homework

- Write a full deployment manifest that uses both a ConfigMap and a Secret.
- Mount the Secret as a file, the ConfigMap as environment variables.
- Create a basic Kustomize structure and overlay that patches the image tag.
- Create a Helm chart for a Pod that lets the container name be set via values.yaml.
- Reflect: Which templating style feels more maintainable in teams—Kustomize overlays, or Helm charts? Try explaining your answer.

---

That’s it for today! Next up, we’ll keep working on scheduling and real-world workload strategies. Happy templating!

---

## References

https://kustomize.io
https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/
https://github.com/kubernetes-sigs/kustomize
https://helm.sh/docs/
