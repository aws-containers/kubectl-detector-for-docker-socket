# Docker Sock Detector (DSD)

A `kubectl` plugin to detect if active Kubernetes workloads are mounting the docker socket

![](img/dsd-demo.gif)

## Install

Install the plugin with

```
krew install dsd
```

## Run

You can run the plugin with no arguments and it will inspect all pods in all namespaces that the current Kubernetes user has access to.

```
kubectl dsd
```

[WIP] You can also specify a namespace to limit the scope of what will be scanned.

```
kubectl dsd --namespace kube-system
```

[WIP] Use `help` to see all command options.

## How it works

DSD look for every pod in your Kubernetes cluster.
If pods are part of a workload (eg Deployment, StatefulSet) then it inspects the workload type instead of pods directly.

It then inspects all of the volumes in the containers and looks for any volume with the name `docker.sock`

Supported workload types:

* Pods
* Deployments
* StatefulSets
* DaemonSets
* Jobs
* CronJobs

## Build

To build the binary you can use `make` or `go build -o kubectl-dsd main.go`

Install the `kubectl-dsd` binary somewhere in your path to use it with `kubectl` or use it by itself without kubectl.
The same kubectl authentication should still work with or without `kubectl`.

## Test

There are different test workloads in the `/tests` folder.
You can deploy these workloads to verify the plugin is working as intended.

```
kubectl apply -f tests/
daemonset.apps/ds-docker-volume created
namespace/test1 created
deployment.apps/deploy-docker-volume created
deployment.apps/deploy-docker-volume created
job.batch/job-docker-volume created
pod/pod-docker-volume created
statefulset.apps/ss-docker-volume created
pod/empty-volume created
deployment.apps/no-volume created
```

and then run

```
kubectl dsd
NAMESPACE       TYPE            NAME                    STATUS
default         deployment      deploy-docker-volume    mounted
default         daemonset       ds-docker-volume        mounted
default         statefulset     ss-docker-volume        mounted
default         job             job-docker-volume       mounted
default         cron            cron-docker-volume      mounted
kube-system     pod             pod-docker-volume       mounted
test1           deployment      deploy-docker-volume    mounted
```