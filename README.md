Store application (Create Dockerfile, setup up 2 stages in your pipeline: 1. Docker image creation/push to ACR; 2 stage - deploy App Service from Docker image.).
Use Azure DevOps repo from step 3.
As Docker store image, deploy Azure container registry with minimal price tier.
Do a default integration between App service and container registry. Create a service connection to Azure from the Azure DevOps
