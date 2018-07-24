# Gardener Setup Scripts

This is the installation manual for a simple Gardener setup. It is part of the [landscape-setup-template](https://github.com/gardener/landscape-setup-template) project. You can find further information there.


# Prerequisites

Before getting started make sure you have the following at hand:

* You need a cloud account with sufficient quota to set up a Kubernetes cluster
with a couple of VMs. **This project currently supports AWS and Openstack.**
* A Linux machine (virtual machine is fine) or a Mac with basic tools such as a
git client and the Docker runtime installed.


# Gardener Installation

Follow these steps to install Gardener. Do not proceed to the next
step in case of errors.


## TL;DR
If you are already familiar with the installation procedure and just want a short 
summary of the commands you have to use, here it is:

```
# setup
git clone  --recursive https://github.com/gardener/landscape-setup-template.git landscape
cd landscape/setup
./docker_run.sh
./deploy_kubify.sh
./deploy_gardener.sh

# optional: certmanager
cd components
./deploy.sh certmanager

# -------------------------------------------------------------------

# teardown
cd /landscape
k8s/bin/tf destroy -force
setup/cleanup.sh
```

### Kubectl Aliases

The following aliases can be used within the docker container:
```
k => kubectl
ks => kubectl -n kube-system
kg => kubectl -n garden
kn => kubectl -n
ka => kubectl get --all-namespaces
```

Bash completion works for all of them except for `ka`. 

## Step 1: Clone the Repositories and get Dependencies

Get the `landscape-setup-template` from GitHub and initialize the
submodules:

```
git clone  --recursive https://github.com/gardener/landscape-setup-template.git landscape
cd landscape
```

This repository will contain all passwords and keys for your landscape.
You will be in trouble if you loose them so we recommend that you store
this landscape configuration in a private repository. It might be a good idea to change the
origin so you do not accidentally publish your secrets to the public template repository.

## Step 2: Configure the Landscape

There is a `landscape_config.yaml` file in the landscape project. This is the only
file that you need to modify - all other configuration files will be
derived from this and the `landscape_base.yaml` file. The latter one contains the merging instructions
as well as technical configurations and it shouldn't be touched unless you know what you are doing. 

## Step 3: Build and Run Docker Container

First, you need to change into the setup folder:
```
cd setup
```

Then run the container:

```
./docker_run.sh
```

After this,

* you will be connected to the container via an interactive shell
* the landscape folder will be mounted in that container
* your current working directory will be `setup` folder
* `setup/init.sh` is sourced, meaning
  * the environment variables will be set
  * kubectl will be configured to communicate with your cluster

The `docker_run.sh` script searches for the image locally and pulls it from an image repository, if it isn't found. 
If pulling the image doesn't work - which will probably be the case if the version in the `setup/VERSION` file 
doesn't match a release version of the setup submodule - you can use the `docker_build.sh` script to build the image locally. 

Most of the scripts need a `landscape.yaml` file, that can be generated from a merge of `landscape_base.yaml` and `landscape_config.yaml`. 
The `init.sh` script (which is sourced in the `docker_run.sh` script, see above) 
will do that automatically, if it doesn't already exist. 
In case you want to overwrite an existing `landscape.yaml` file or generate it manually, you can use this script:

```
./build_landscape_yaml.sh
```

## Step 4: Create a Kubernetes Cluster via Kubify

You can use this script to run the cluster setup:

```
./deploy_kubify.sh
```

The script will wait some time for the cluster to come up and then partly
validate that the cluster is ready.

If you get errors during the cluster setup, just try to run the script again.

Once completed the following command should show all deployed pods:

```
root@c41327633d6d:/landscape# kubectl get pods --all-namespaces
NAMESPACE       NAME                                                                  READY     STATUS    RESTARTS   AGE
kube-system     etcd-operator-75dcfcf4f7-xkm4h                                        1/1       Running   0          6m
kube-system     heapster-c8fb4f746-tvts6                                              2/2       Running   0          2m
kube-system     kube-apiserver-hcdnc                                                  1/1       Running   0          6m
[...]
```

## <a name="workaround"></a>Step 4.5: Workaround (Automated)

There is currently an issue with session affinities in Kubernetes, which can break your cluster. 
While the problem has been fixed (see https://github.com/kubernetes/kubernetes/commit/f2405cf2942739996af2bb76347c2cb0641153aa), 
the corresponding Kubernetes version is not yet included in this project.

Until that happens, the workaround is to remove the following lines from the `kubernetes` service:

```
  sessionAffinity: ClientIP
  sessionAffinityConfig:
    clientIP:
      timeoutSeconds: 10800
```

Kubernetes will add `sessionAffinity: None` on itself.

This will happen automatically at the end of the `deploy_kubify.sh` script.

## Step 5-9: Gardener Setup (Automated)

Steps 5-9 are automated. In case you need more control follow
the instructions below for manually running them.

```
./deploy_gardener.sh
```

After successful completion, you can either continue with [step 10 (optional)](#step10), or start using 
the Gardener (see *[Accessing the Dashboard](#access_dashboard)*).


## <a name="access_dashboard"></a>Accessing the Dashboard

After step 9 you will be able to access the Gardener dashboard. This example assumes that 
your cluster is located at `mycluster.example.org` - just replace that part with 
whatever you put in the `clusters.dns.domain_name` entry in the `landscape_config.yaml` file.

The `print_dashboard_urls.sh` script constructs both URLs from the domain name given in 
the `landscape.yaml` file and prints them. It is called automatically at the end of 
the Gardener deploy script.

First, open `https://identity.ingress.mycluster.example.org`. Your browser will show a warning 
regarding untrusted self-signed certificates, you need to ignore that warning. 
You will then see a nearly blank page with some 404 message. 
If you skip this step, you will still be able to see the dashboard in the next step, 
but the login button probably won't work. 

Now you can open the dashboard at `https://dashboard.ingress.mycluster.example.org`. Here you 
need to ignore a similar warning again, then you should see the dashboard. You can login 
using the options you have specified in the identity chart part of the `landscape_config.yaml`.



## Step 5-9: Gardener Setup (Manual)

The commands shown below need to be run from within the components 
directory of the setup folder:

```
cd /landscape/setup/components
```

### Step 5: Generate Certificates

These are the self-signed certificates used for the dashboard and
identity ingresses (if you are on the internet you can later get
letsencrypt issued certificates).

```
./deploy.sh cert
```

### Step 6: Deploy tiller

Tiller is needed to deploy Helm charts in order to deploy Gardener and other needed components

```
./deploy.sh helm-tiller
```

### Step 7: Deploy Gardener

Now we can deploy Gardener. If the previous steps were executed successfully
this should be completed in a couple of seconds.

```
./deploy.sh gardener
```

You might see a couple of messages like these:

```
Gardener API server not yet reachable. Waiting...
```

while the script waits for the Gardener to start. Once Gardener is up
when the deployment script finished you can verify the correct setup by
running the following command:

```
kubectl get shoots
No resources found. 
```

As we do not have a seed cluster yet we cannot create any shoot clusters.
The Gardener itself is installed in the `garden` namespace:

```
kubectl get po -n garden
NAME                                          READY     STATUS    RESTARTS   AGE
gardener-apiserver-56cc665667-nvrjl           1/1       Running   0          6m
gardener-controller-manager-5c9f8db55-hfcts   1/1       Running   0          6m
```

### Step 8: Register Garden Cluster as Seed Cluster

In heterogeneous productive environments one would run Gardener and seed in
separate clusters but for simplicity and resource consumption
reasons we will register the Gardener cluster that we have just created also as the seed
cluster. Make sure that the `seed_config` in the landscape file is correct
and matches the region that you are using. Keep in mind that image ids differ
between regions as well.

```
./deploy.sh seed-config
```

#### Configuring Additional Seeds

By default, this step will create a seed for the cloud provider the Gardener has 
been deployed on and thus creating shoots on this provider will be possible. 
If you want to create shoots on other cloud providers, you will have to configure 
additional seeds. There are two options for that:

If the seed-config deploy script is called without any arguments (as shown above), 
it will create seeds for all providers specified in the `seed_config.seeds` section 
in the `landscape_config.yaml` file. By default, the only entry in that list is 
the cloud provider chosen for the Gardener cluster, but you can extend the list.

It is also possible to provide the seed-config deploy script with additional arguments 
specifying which seeds should be created. Multiple arguments can be given and 
the script will ignore the list in the `landscape_config.yaml` file when called with 
arguments. Only the specified seeds will be created, already existing seeds are not 
affected. If a given seed already exists, it will be updated to the current configuration. 

In both cases, the corresponding variant nodes in `authentication` and `seed_config` 
have to be filled out in the config file. The provided credentials won't be used for shoot 
cluster creation, but for storing the etcd backups of the shoot clusters.

Valid values for seeds are `aws`, `az` (for Azure), `gcp`, and `openstack`. Please note, 
that while it is possible to create seeds for any cloud provider on any cloud provider, 
shoot creation may not work across cloud providers for every combination. It should 
always work if seed (Gardener cluster in this setup) and shoot are on the same provider, 
though. 

#### Creating a Shoot

That's it! If everything went fine you should now be able to create shoot clusters.
You can start with a sample
[manifest](https://github.com/gardener/gardener/blob/master/example/shoot-aws.yaml)
and create a shoot cluster by standard Kubernetes means:

```
kubectl apply -f shoot-aws.yaml
```

### Step 9: Install Identity and Dashboard

Creating clusters based on a shoot manifest is quite nice but also a little
complex. While almost all aspects of a shoot cluster can be configured it can
be quite difficult for beginners, so go on and install the dashboard:

```
./deploy.sh identity
[...]
./deploy.sh dashboard
[...]
```

Now you should be able to open the "Gardener" dashboard and start creating
shoot clusters. 


## Step 10: Apply Valid Certificates (optional)

Ensure that you are in the components directory for installing the certmanager:

```
cd /landscape/setup/components
```

Using the Gardener Dashboard with self-signed certificates is awkward and
some browsers even prevent you from accessing it altogether.

The following command will install the 
[cert-manager](https://github.com/jetstack/cert-manager) and request valid
letsencrypt certificates for both the identity and dashboard ingresses:

```
./deploy.sh certmanager
```

After one to two minutes valid certificates should be installed.

Letsencrypt [limits](https://letsencrypt.org/docs/rate-limits/) how many certificates you can get 
for the same host within a short time. To avoid hitting these limits, you can use the letsencrypt 
staging server for testing, which has a significantly higher rate limit but produces untrusted 
certificates.  
To use the staging server, change the URL in `components/certmanager/cert-manager-issuer.yaml.tmpl` 
to `https://acme-staging-v02.api.letsencrypt.org/directory`.

# Tearing Down the Landscape

Make sure that you delete all shoot clusters prior to tearing down the
cluster created by Kubify (either by deleting them in the Gardener dashboard 
or by using the kubectl command). The following command should 
not return any shoot clusters:

```
kubectl get shoots --all-namespaces
No resources found.
```

There is a [delete-shoot](https://github.com/gardener/gardener/blob/master/hack/delete-shoot)
script in order to delete shoot clusters.

Next run terraform in order to delete the cluster:

```
cd /landscape
k8s/bin/tf destroy
[...]
Plan: 0 to add, 0 to change, 170 to destroy.

Do you really want to destroy?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value:
```

Enter `yes` when you are sure that you want to delete the cluster.


# Cleanup

If you have created and destroyed a cluster and want to restart it, there are some files you 
have to delete to clean up the directory. 

**ATTENTION: Only do this if you are sure the cluster has been completely destroyed!**
Since this removes the terraform state, an automated deletion of resources won't be possible anymore - 
you will have to clean up any leftovers manually.

```
setup/cleanup.sh
```

This will reset your landscape folder to its initial state.

The script takes an optional "-y" argument to skip the confirmation.