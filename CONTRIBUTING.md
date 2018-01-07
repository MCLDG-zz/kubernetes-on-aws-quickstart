# Contributing to the Kubernetes on AWS Quick Start

Contributions are most welcome.

## Readme
Check out the README for details on what the quick-start does and how to use it

## Contributing a resolution to an issue
* Pick an issue
* Assign it to yourself
* Update the issue as you make progress
* Once the issue is fully resolved, submit a pull request linked to the issue

## Contributing a new feature
If you have an idea for a new feature, let's discuss it on a call. Once we've achieved consensus on the idea, go ahead
and create an issue so we can track progress and further discussion on the issue in an open and transparent manner.

If your new feature requires a design, write this up in a separate doc and include in the repo. This will help
others who want to understand how your feature works.

## Test cases for everything you contribute
If you contribute a new feature, write the corresponding test case. If you update a feature or fix a bug, update the
corresponding test case. We want testing of the quick start to be fully automated.

If your feature deploys Pods, checking the Pods are running (and continue running for more than a few seconds) is a good
start, but not sufficient. Tests should be deep. If you are testing logging, for instance, a test would deploy an
app that outputs a unique log string and ensure the expected logs appear in ElasticSearch & Kibana. 

## Use Pull Requests
To contribute to the repo use pull requests. The process is as follows:

* Fork this repo
* Create a new branch for your changes
* Develop your feature or submit your fix
* Test it
* Update the README
* Push your code and submit your pull request

If you're not familiar with using pull requests, a useful tutorial is here: https://www.digitalocean.com/community/tutorials/how-to-create-a-pull-request-on-github

## Refer to
Some of the new features can be implemented by referring to our Kubernetes workshop: https://github.com/aws-samples/aws-workshop-for-kubernetes.
The code/scripts from the workshop repo can be copied here, then refactored to ensure an integrated environment.
