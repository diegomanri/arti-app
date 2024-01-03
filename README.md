# arti-app

## Local Dev Deployment

Use

```
docker-compose up --build --remove-orphans --abort-on-container-exit
```

## Production Deployment

In the repository there are three Github Actions used to complete the deployment to production `Deploy to GHCR`, `Terraform State Setup`, and `Terraform Plan and Apply`. To initiate the deployment follow this order:

* If the repository has undergone changes, use the `Deploy to GHCR` workflow to create Django and Nginx images and push the to Github's GHCR image repository.
* If the application does not have a Terraform state infrastructure up and running then use the `Terraform State Setup` workflow to create the S3 bucket and DynamoDB table to store state and state lock information relatd to the application. Keep note of the S3 bucket name that comes out of this workflow as that would need to be added to Actions Secrets and Variables as a variable with name `TF_STATE_S3_BUCKET`.
* Finally, to complete the deployment of the infrastructure use `Terraform Plan and Apply`. This workflow will pull the Django and Nginx images and use them in AWS ECS, it would also deploy all other infrastructure components (RDS, ALB, SG, etc.)