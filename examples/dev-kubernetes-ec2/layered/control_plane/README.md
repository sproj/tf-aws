- apply external-secrets namespace
- add eso-reader secrets to external-secrets namespace: 
  ```
  kubectl create secret generic eso-reader-aws-credentials \
    --namespace external-secrets \
    --from-literal=access-key-id=$(aws ssm get-parameter --name /dev/dev-k8s/eso-reader-ssm-access-key-id --with-decryption --query Parameter.Value --output text --profile super-user) \
    --from-literal=secret-access-key=$(aws ssm get-parameter --name /dev/dev-k8s/eso-reader-ssm-secret-access-key --with-decryption --query Parameter.Value --output text --profile super-user)
  ```
- helm install external-secrets external-secrets/external-secrets --namespace external-secrets
- apply cluster-secret-store
- add ebs-csi-user secrets to kube-system namespace:
  ```
  kubectl create secret generic aws-secret \
    --namespace kube-system \
    --from-literal=key_id=$(aws ssm get-parameter --name /dev/dev-k8s/ebs-csi-ec2-access-key-id --with-decryption --query Parameter.Value --output text --profile super-user) \
    --from-literal=access_key=$(aws ssm get-parameter --name /dev/dev-k8s/ebs-csi-ec2-secret-access-key --with-decryption --query Parameter.Value --output text --profile super-user)
  ```
- helm install aws-ebs-csi-driver
```
helm repo add aws-ebs-csi-driver https://kubernetes-sigs.github.io/aws-ebs-csi-driver
```
```
helm install aws-ebs-csi-driver aws-ebs-csi-driver/aws-ebs-csi-driver \
  --namespace kube-system \
  -f ./ebs-csi/ebs-csi-values.yaml
```
- apply storage-class
- apply block-imds