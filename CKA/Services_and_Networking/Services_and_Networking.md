# Services & Networking (20% Exam Weight)

#### [YouTube video link](https://www.youtube.com/watch?v=2YiCiTKzbkM)

Welcome back, Kubernetes learners! This session explores one of the most vital CKA domains: **Services & Networking**. We'll break down pod connectivity, network policies, Service types (including **ClusterIP**, **NodePort**, **LoadBalancer**), dive into the **Gateway API** and modern **Ingress**, deploy a gateway end to end, and wrap up with **CoreDNS** essentials.

We will use this [playground](https://killercoda.com/playgrounds/scenario/kubernetes) throughout this session.

## 1. Pod-to-Pod Connectivity

In Kubernetes, every Pod gets its own unique IP address, which means Pods can talk to each other directly in the same cluster, provided network policies don’t block them.

### Quick Connectivity Check

Start with a simple deployment of Nignx that listens on port 80. Expose it via ClusterIP service on port 8080:

```bash
kubectl create deployment nginxpod --image=nginx  --port 80
kubectl wait --for=jsonpath='{.status.phase}'=Running pod -l app=nginxpod
kubectl expose deployment nginxpod --name nginxsvc --target-port 80 --port 8080
kubectl describe svc nginxsvc # it should show POD IP and port 80 in "Endpoints"
```

Create a test pod with busybox image

```bash
kubectl run busybox --image=busybox --restart=Never -- sleep 3600
```

Connect from busybox pod to nginxpod:

```sh
kubectl exec -it busybox -- nslookup nginxsvc.default.svc.cluster.local
kubectl exec -it busybox -- wget -S -O - nginxsvc:8080
```

Find the nginxpod IP

```sh
IP_OF_NGINX_POD=$(kubectl get pods -l app=nginxpod -o jsonpath='{range .items[*]}{.status.podIP}{end}')
```

Connect to the nginxpod from busybox pod

```sh
kubectl exec -it busybox -- wget -q -O - $IP_OF_NGINX_POD
```

For details, check the [official docs on Pod networking](https://kubernetes.io/docs/concepts/cluster-administration/networking/).

***

## 2. Defining and Enforcing Network Policies

Network policy resources let you **control traffic** at the IP address or port level (think: firewalls for Pods!). Starts with allowing all-to-all traffic by default. Then, lock it down.

### Example: Deny all except from a certain app

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: only-allow-frontend
spec:
  podSelector:
    matchLabels:
      role: db
  policyTypes:
  - Ingress
  ingress:
  - from:
      - podSelector:
          matchLabels:
            role: frontend
```

This only lets Pods with label `role=frontend` access Pods labeled `role=db`. More on [Network Policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/).

***

## 3. Service Types — ClusterIP, NodePort, LoadBalancer \& Endpoints

Kubernetes Services provide stable endpoints for pod groups even as pod IPs change.


| Service Type | Use | External Exposure | Example |
| :-- | :-- | :-- | :-- |
| ClusterIP | Default. Pod-to-pod or cluster-internal | No | `kubectl expose deployment myapp --port=80 --target-port=8080 --type=ClusterIP` |
| NodePort | Exposes service on each node’s IP at a static port | Yes (nodeIP:port) | `kubectl expose deployment myapp --type=NodePort --port=80` |
| LoadBalancer | Provisions external LB (cloud) | Yes (cloud LB) | `kubectl expose deployment myapp --type=LoadBalancer --port=80` |


Endpoints are the actual IPs of the pods backing the service. See how endpoints map back with:

```sh
kubectl get endpoints <service-name>
```

See [Services Overview](https://kubernetes.io/docs/concepts/services-networking/service/).

***

## 4. Gateway API and Ingress Controllers

### Why Gateway API?

The Gateway API is the evolution of Ingress; it gives you greater flexibility and true multi-tenancy for managing north-south (in/out) traffic.

#### Example: Deploying a Gateway with API and HTTPRoute

Create a Gateway:

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: my-gateway
  namespace: default
spec:
  gatewayClassName: nginx
  listeners:
  - name: http
    protocol: HTTP
    port: 80
```

Create an HTTPRoute targeting the gateway:

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: my-route
spec:
  parentRefs:
  - name: my-gateway
  rules:
  - matches:
      - path:
          type: PathPrefix
          value: /
    backendRefs:
      - name: my-service
        port: 80
```

- Deploy any supported Gateway controller (like NGINX, Envoy, or cloud native).
- More on [Gateway API concepts](https://kubernetes.io/docs/concepts/services-networking/gateway/).

***

#### Example: Classic Ingress Resource

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: example-ingress
spec:
  rules:
  - host: myapp.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: my-service
            port:
              number: 80
```

Apply your Ingress controller (nginx-ingress, traefik, etc). See [Ingress Controllers and Resources](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/).

***

## 5. Gateway API vs. Ingress Resource — ASCII Table

Here's a quick side-by-side:

```
+---------------------------+----------------------------------------------+------------------------------------------+
|         Aspect            |            Gateway API                       |                Ingress                   |
+---------------------------+----------------------------------------------+------------------------------------------+
| Resource Model            | Gateway, HTTPRoute, etc.                     | Single Ingress object                    |
| Extensibility             | Very high (multiple controllers, listeners)  | Limited (annotations, one ingress class) |
| Multi-tenancy             | Built-in support                             | Harder to separate traffic domains       |
| CRD Based                 | Yes, extensible                              | Yes (fewer custom fields)                |
| Controller Implementations| Growing (NGINX, Envoy, etc.)                 | Wide, mature (NGINX, Traefik, etc.)      |
| Fine-grained RBAC         | Yes (delegation, granular scoping)           | Not as easy                              |
| Ecosystem Maturity        | New, evolving                                | Very mature                              |
| Spec Complexity           | More YAML, more features                     | Simpler, less control                    |
+---------------------------+----------------------------------------------+------------------------------------------+
```

**Pros & Cons:**

- **Gateway API:** Flexible, works for multi-tenant and advanced setups, more YAML.
- **Ingress:** Quick, mature, simpler but less powerful for complex use cases.

***

## 6. CoreDNS

CoreDNS is the default DNS server for Kubernetes. It automatically discovers services and Pods by name, making service discovery seamless.

**Check CoreDNS Version:**

```sh
kubectl get deployment -n kube-system coredns
```

**Test DNS from Pod:**

```sh
kubectl exec -it busybox -- nslookup kubernetes.default.svc.cluster.local
```

You can [configure stub domains, upstream servers](https://kubernetes.io/docs/tasks/administer-cluster/dns-custom-nameservers/) and customize CoreDNS as needed.

**Explore CoreDNS ConfigMap:**

```sh
kubectl -n kube-system get cm coredns -o yaml
```

**See `resolv.conf` in a contrainer**

```sh
kubectl exec -it busybox -- cat /etc/resolv.conf
```

***

## Homework

- Create a simple web app Deployment and expose it using ClusterIP, NodePort, and LoadBalancer service types. Test connectivity from inside and outside the cluster.
- Write a NetworkPolicy that only allows pods with the label `access: granted` to communicate with your web app.
- Deploy an NGINX Gateway controller, define a Gateway and HTTPRoute, and test traffic routing with `kubectl port-forward` or external testing if available.
- Build an Ingress resource for the same web app and compare the configuration with the Gateway API.
- Test CoreDNS by resolving an internal service from a pod and modifying a CoreDNS ConfigMap (for advanced users).

**Explore the [official Kubernetes documentation](https://kubernetes.io/docs/concepts/services-networking/) for detailed guides and further examples.**

***

That wraps up Services & Networking for CKA v1.34! Next, we’ll jump into persistent storage and volume lifecycles. Happy cluster networking!