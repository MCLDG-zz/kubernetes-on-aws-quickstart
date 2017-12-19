# Kubernetes on AWS - Quick Start
This quick start will build a Kubernetes ecosystem complete with the following components:

* Kubernetes cluster
* Consolidated logging using EFK
* Monitoring using Prometheus
* Auto-scaling (Pods and Cluster worker nodes)
* Git repository using AWS CodeCommit
* CI/CD Pipeline using AWS CodePipeline

The goal of the quick start is to allow developers simply to develop and push code to a repo. Building and deploying the applicaiton to Kubernetes is taken care of, as is logging and monitoring.
Developers should not have to:
* decide which services to use for common features such as logging & monitoring
* spend their time deploying and maintaining those services
* spend their time connecting those services together

This repo takes an opinionated view of which services are most commonly used in building a Kubernetes ecosystem, and provides a script to deploy and connect those services. This repo is successful if a developer only needs to:
* clone the repo
* run the quick-start script after making a few configuration selections
* add their code to the repo created by the script
* push their code

The Kubernetes ecosystem built by this repo will take care of:
* building and deploying the code
* collecting all logs and pushing to a central ElasticSearch stack
* monitoring the Kubernetes cluster
* scaling the Pods and Kubernetes worker nodes

In future this repo could be extended to provide more than one option per service. For example, at the moment it assumes Prometheus for monitoring, but in future it may provide an option to use a HIG stack (Heapster, InfluxDB, Grafana).

## Pre-requisites
### MacOS only

Initial version of this quick start runs on MacOS only. Volunteers are more than welcome to submit a pull request to add Windows support. 

### sudo access

The install script requires sudo access and will prompt for your password

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

## Run quick-start.sh
Run the following:

    $ ./quick-start.sh
    
The script is mostly automatic. Input will be required in the following places:

* Press RETURN to continue...
* You'll need to enter your password for SUDO to run
* HEAD is now at... - no need to do anything here, it may just take a while to complete the download
* 