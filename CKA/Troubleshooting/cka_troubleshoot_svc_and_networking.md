# Troubleshoot Services and Networking (subset of 30%)

Services and networking issues are some of the most common problems you will face as a Kubernetes administrator. Pods may be running fine, but if Services, DNS, or Network Policies are misconfigured, applications will not be reachable.

This guide will walk you through how to approach troubleshooting Services and networking step by step with hands-on examples.

---

[YouTube Video Link](https://www.youtube.com/watch?v=qs0i_pxlx3Y)

---

## 1. Verify the Service Object

Let's run a pod and make it to listen on port 80

```bash
kubectl run nginx --image=nginx --port=80 --labels app=nginx
kubectl describe po nginx
```

### Example Problem
Here is a Service pointing to the wrong port:

Save yaml file to a file named `my-service-port.yaml`. it should look like this:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service-port
spec:
  selector:
    app: nginx
  ports:
  - port: 8081   # Port where your service listens
    targetPort: 8080 # Wrong! Pod is listening on 80, not 8080
```

### Test It

```bash
kubectl apply -f my-service-port.yaml
```

See your service details

```bash
kubectl describe svc my-service-port
kubectl get endpointslices
```

You should see the port number as 8080 in PORTS section for your service **my-service-port**

Run a test container to check connectivity, we connect to service v/s connecting to pod

```bash
kubectl run test --image=nginx 
kubectl exec -it test -- curl --head --connect-timeout 2  my-service-port:8081 
```


Check what port is used by your container to listen

```bash
kubectl get po -o custom-columns=CONTAINER:.spec.containers[0].name,IMAGE:.spec.containers[0].image,PORT:.spec.containers[0].ports
```

### Fix It

Correct the `port` and `targetPort` in the file and use `kubectl apply -f  my-service-port.yaml` and validate the outputs again.

```yaml
  ports:
  - port: 8081
    targetPort: 80
```

Once fixed, test it again

```bash
kubectl get endpointslices
```

With following command run again, you should see output `HTTP/1.1 200 OK`

```bash
kubectl exec -it test -- curl --head --connect-timeout 2  my-service-port:8081 
```

📖 Reference: [Kubernetes Services](https://kubernetes.io/docs/concepts/services-networking/service/)

---

## 2. Inspect the Endpoints

Notice the lables on the pods

```bash
kubectl get po nginx --show-labels
```

You can also use `kubectl describe` to see labels
```bash
kubectl describe po nginx
```


### Example Problem

A Service with a selector that matches no Pods:

Save yaml file to a file named `wrong-selector.yaml`. it should look like this:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: wrong-selector
spec:
  selector:
    app: doesnotexist   # Wrong label
  ports:
  - port: 80
    targetPort: 80
```

### Test It

```bash
kubectl apply -f wrong-selector.yaml
kubectl describe wrong-selector
kubectl get endpointslices
```

You will see **\<unset\> \<unset\>** for PORTS and ENDPOINTS for your service named **wrong-selector**.

### Fix It

Correct the `selector` to match the `labels` in the file and use `kubectl apply -f  wrong-selector.yaml` and validate the outputs again.

```yaml
  selector:
    app: nginx
```

📖 Reference: [Debug Services](https://kubernetes.io/docs/tasks/debug/debug-application/debug-service/)

---

## 3. Test Pod-to-Pod Connectivity

### Example Problem

Two Pods are deployed, but one tries to connect to the wrong port.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  containers:
  - name: nginx
    image: nginx
    ports:
    - containerPort: 80
---
apiVersion: v1
kind: Pod
metadata:
  name: busybox
spec:
  containers:
  - name: busybox
    image: busybox
    command: ["sleep", "3600"]
```

### Test It

```bash
kubectl exec -it busybox -- wget -O- http://nginx:8080
```

Fails because NGINX is not on 8080.

### Fix It

Try the correct port:

```bash
kubectl exec -it busybox -- wget -O- http://nginx:80
```

📖 Reference: [Cluster Networking](https://kubernetes.io/docs/concepts/cluster-administration/networking/)

---

## 4. Verify DNS Resolution

### Example Problem

Pod trying to resolve a non-existent Service:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: dns-test
spec:
  containers:
  - name: busybox
    image: busybox
    command: ["sleep", "3600"]
```

### Test It

```bash
kubectl exec -it dns-test -- nslookup fake-service.default
```

Fails with `server can't find`.

### Fix It

Use a real Service:

```bash
kubectl exec -it dns-test -- nslookup kubernetes.default
```

📖 Reference: [Debug DNS Resolution](https://kubernetes.io/docs/tasks/administer-cluster/dns-debugging-resolution/)

---

## 5. Check Network Policies

### Example Problem

A NetworkPolicy that blocks all traffic:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
spec:
  podSelector: {}
  policyTypes:
  - Ingress
```

### Test It

```bash
kubectl exec -it busybox -- wget -O- http://nginx
```

Connection refused.

### Fix It

Allow ingress from Pods in the same namespace:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-same-namespace
spec:
  podSelector:
    matchLabels:
      app: nginx
  ingress:
  - from:
    - podSelector: {}
```

📖 Reference: [Network Policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/)

---

## 6. Node and External Connectivity

### Example Problem

Service of type NodePort not reachable externally.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-nodeport
spec:
  selector:
    app: nginx
  type: NodePort
  ports:
  - port: 80
    targetPort: 80
    nodePort: 31080
```

### Test It

```bash
curl http://<node-ip>:31080
```

If it fails:

* Ensure the firewall allows port `31080`
* Verify the Pod is running

### Fix It

* Open the firewall rule on the node
* Or expose it via LoadBalancer in cloud environments

📖 Reference: [ServiceTypes](https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types)

---

# ✨ Homework ✨

Now it’s your turn to practice.

### Homework 1: Broken Selector

* Deploy a Pod with label `app=myapp`
* Create a Service with selector `app=wrongapp`
* Troubleshoot why the Service has no Endpoints, then fix it

### Homework 2: DNS Debugging

* Sacle down the CoreDNS Deployment temporarily to 0
    * Tip: you can use `kubectl -n kube-system scale deployment coredns --replicas=0`
    * Note: Name resolution won't work because DNS is now unavailable.
* Try `nslookup kubernetes.default` inside a Pod
    * Tip: use a pod with image **dnsutils** in it 
    e.g. `kubectl apply -f https://k8s.io/examples/admin/dns/dnsutils.yaml`
* Observe the failure, then restore CoreDNS
    *  Tip: you can use `kubectl -n kube-system scale deployment coredns --replicas=2`

### Homework 3: Network Policy

* Deploy two Pods in the same namespace
* Create a NetworkPolicy that blocks all traffic
* Confirm connectivity fails
* Update the policy to allow traffic again

### Homework 4: External Access

* Expose an NGINX Deployment as a NodePort
* Test with `curl http://<node-ip>:<nodePort>` from outside the cluster
* Validate whether it works

---

# Key Takeaways

* Always check **Services → Endpoints → Pods**
* Use `kubectl describe` liberally to inspect objects
* CoreDNS is critical for internal service discovery
* NetworkPolicies are **deny by default** when defined
* External access depends on firewall rules or cloud load balancers

---

📖 References for further reading:

* [Services](https://kubernetes.io/docs/concepts/services-networking/service/),
* [Debug Services](https://kubernetes.io/docs/tasks/debug/debug-application/debug-service/),
* [DNS Debugging](https://kubernetes.io/docs/tasks/administer-cluster/dns-debugging-resolution/),
* [Network Policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/),
* [Cluster Networking](https://kubernetes.io/docs/concepts/cluster-administration/networking/)
