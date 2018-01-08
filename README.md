# Kubernetes on AWS - Quick Start
The goal of this quick start is to build a complete Kubernetes ecosystem on AWS so developers don't have to. This allows
developers to focus on what they're good at - writing code - and removes the need for them to do R&D to determine
which components to install to build a Kubernetes stack.

The quick start takes an opinionated view on selecting the appropriate components to provision a non-production
Kubernetes environment, and allows this environment to be created by running a script. 

This quick start will build a Kubernetes ecosystem complete with the following components:

## For MVP
* Kubernetes cluster (provisioned using Kops)
* Consolidated logging using EFK
* Monitoring using Prometheus
* Auto-scaling (Pods and Cluster worker nodes)
* Git repository using AWS CodeCommit
* CI/CD Pipeline using AWS CodePipeline

## Post MVP
* Secrets management. Probably integrating Hashicorp Vault
* ALB Ingress
* Distributed tracing. Need to decide which framework. Jaeger, X-Ray, etc. Or is the Istio tracing OK for now?
* Service mesh - probably Istio
* Network Policy using plugin - probably Calico

## Post-post MVP
While MVP will take an opinionated view of the components to install, post-MVP should allow selection of options for 
the various components. For example, allow selection of either Istio or Linkerd for the service mesh

## Making life easier
The goal of the quick start is to make life easier for Developers starting to use Kubernetes. The quick start
provisions all the services necessary for building and deploying an application to Kubernetes, as well as logging and 
monitoring and other services.

Developers should not have to:
* decide which services to use for common features such as logging & monitoring
* spend their time deploying and maintaining those services
* spend their time connecting those services together

This repo takes an opinionated view of which services are most commonly used in building a Kubernetes ecosystem, and 
provides a script to deploy and connect those services. This repo is successful if a developer only needs to:
* clone the repo
* run the quick-start script after making a few configuration selections
* add their code to the repo created by the script
* push their code

## Pre-requisites
### MacOS only

Initial version of this quick start runs on MacOS only. Volunteers are more than welcome to submit a pull request to add Windows support. 

### sudo access

The install script requires sudo access and will prompt for your password at times

### Install AWS cli

Make sure the latest version of the http://docs.aws.amazon.com/cli/latest/userguide/installing.html[AWS CLI]
is installed. 

   $ pip install --upgrade awscli

The AWS CLI should be configured to point to the account where you want to install Kubernetes.

### Create an S3 bucket

Create an S3 bucket, or reuse an existing one. The state of your Kubernetes cluster will be stored in this bucket.

   $ aws s3 mb <unique bucket name>

### IAM user permissions

The AWS user profile must have these http://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies.html[IAM policies] attached.

    AmazonEC2FullAccess
    AmazonS3FullAccess
    IAMFullAccess
    AmazonVPCFullAccess


Please review these links for additional info on IAM permissions:
https://github.com/kubernetes/kops/blob/master/docs/aws.md#setup-iam-user. https://github.com/kubernetes/kops/blob/master/docs/iam_roles.md

### Configure your preferences before running the script

Preferences are stored in ./quick-start.properties. Open this file and configure your settings before running ./quick-start.sh

## Run quick-start.sh
Run the following:

    $ ./quick-start.sh
    
The script is mostly automatic. Input will be required in the following places:

* Press RETURN to continue...
* You'll need to enter your password for SUDO to run
* HEAD is now at... - no need to do anything here, it may just take a while to complete the download

## Once the quick start script is complete
### Grafana
You can use port forwarding to open the Grafana dashboard in your browser. Run this command 

```bash
kubectl port-forward $(kubectl get pod -l app=grafana -o jsonpath={.items[0].metadata.name} -n monitoring) 3000 -n monitoring
```

Then open the following URL in your browser: `http://localhost:3000/`