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

moving permissions to infrastructure modules, link back to deployment-type module
- deployment-type -> create one policy for each role (creator, manager...) which has the permissions for all the infra that 
deployment will deal with
- add boundaries
- add conditions
- add explicial denials
- remove current permissions policies - AWS has a limit of 10 policies per role

Left off:
- nearly able to deploy a working k8s cluster to ec2
- It’s a common point of confusion!  
The **EC2 key pair** must be created in AWS (either via the AWS Console, CLI, or API), not just generated locally. When you create a key pair in AWS:

- AWS stores the public key and gives you the private key (`.pem` file) to download.
- You use the key pair’s **name** in your Terraform (`key_name = "my-keypair"`).
- The private key is used locally to SSH into your EC2 instance.

**If you already have an SSH key pair locally**, you can import the public key into AWS as a new EC2 key pair:

```sh
aws ec2 import-key-pair --key-name my-keypair --public-key-material fileb://~/.ssh/id_rsa.pub
```

Then use `my-keypair` as your `key_name` in Terraform.

**Summary:**  
- The key pair must exist in AWS.
- You use the private key locally to connect.
- You can import your existing public key if you prefer.