# Detector for Docker Socket (DDS)

A `kubectl` plugin to detect if active Kubernetes workloads are mounting the docker socket (`dock.sock`) volume.

![](img/dds-demo.gif)

## Install

Install the plugin with

```
krew install dds
```

## Run

You can run the plugin with no arguments and it will inspect all pods in all namespaces that the current Kubernetes user has access to.

```
kubectl dds
```

You can also specify a namespace to limit the scope of what will be scanned.

```
kubectl dds --namespace kube-system
```

Use `help` to see all command options.

## How it works

`dds` looks for every pod in your Kubernetes cluster.
If pods are part of a workload (eg Deployment, StatefulSet) it inspects the workload type instead of pods directly.

It then inspects all of the volumes in the containers and looks for any volume with the name `docker.sock`

Supported workload types:

* Pods
* Deployments
* StatefulSets
* DaemonSets
* Jobs
* CronJobs

## Build

To build the binary you can use `make` or `go build -o kubectl dds main.go`

Install the `kubectl dds` binary somewhere in your path to use it with `kubectl` or use it by itself without kubectl.
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
kubectl dds
NAMESPACE       TYPE            NAME                    STATUS
default         deployment      deploy-docker-volume    mounted
default         daemonset       ds-docker-volume        mounted
default         statefulset     ss-docker-volume        mounted
default         job             job-docker-volume       mounted
default         cron            cron-docker-volume      mounted
kube-system     pod             pod-docker-volume       mounted
test1           deployment      deploy-docker-volume    mounted
```
