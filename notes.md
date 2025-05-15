phase 0:

next you need to set up the infrastructure modules.

think about whether the intra module for each deployment type should be a sub-module of the deployment type, or whether the deployment should inherit 
from broader infra definitions or what - learn about that.

phase 1:

✅ I've captured where you’re leaving off:

    Next steps for you:

        Sketch a real terraform sequence (init → plan → apply)

        Set up a remote backend (S3 + DynamoDB locking)

        Start on a real deployment module, wiring together resource roles

✅ Context:

    You have a working module structure for roles.

    You're clear on how to scale to multi-repo architecture later.

    Naming and trust policies are aligned with best practices.

phase 2:

- Bootstrap and meta-roles completed (infrastructure-manager)
- Deployment-type IAM roles completed (kubernetes-ec2 creator/manager/reader)
- Local AWS CLI profiles configured
- Dynamic tagging (ManagedBy) implemented
- Full Terraform lifecycle (apply/destroy) verified
- Operational model (assume-role separation) working
- Ready to build first real environment (e.g., dev-k8s-ec2)


Tagging on the networking module needs some attention - same on the deployment it feeds. ManagedBy enough??
Might want to split out roles per infra type after all. Kubernetes-ec2 should be a networking, ec2, ecr.....actors putting together an env and then plopping k8s into it.

Left off:
moving permissions to infrastructure modules, link back to deployment-type module
- deployment-type -> create one policy for each role (creator, manager...) which has the permissions for all the infra that 
deployment will deal with
- add boundaries
- add conditions
- add explicial denials
- remove current permissions policies - AWS has a limit of 10 policies per role