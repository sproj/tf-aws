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

- install cert-manager:
  - helm repo add jetstack https://charts.jetstack.io 
  - helm install cert-manager jetstack/cert-manager \
    --namespace cert-manager \
    --create-namespace \
    --set crds.enabled=true
- apply cert-manager/cert-manager-external-secrets
- apply cert-manager/cluster-issuer

- apply aws-lbc/aws-lbc-external-secrets.yaml
- helm install eks/aws-load-balancer-controller
```
helm repo add eks https://aws.github.io/eks-charts

helm install aws-load-balancer-controller eks/aws-load-balancer-controller --namespace kube-system -f ./aws-lbc/aws-lbc-values.yaml
```


- helm add ingres-nginx: 
```
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
```
- helm install ingress-nginx
```
helm install ingress-nginx ingress-nginx/ingress-nginx --namespace ingress-nginx --create-namespace \
  -f ./ingress-nginx/ingress-nginx-values.yaml
```

run tf-aws/bootstrap/dns-records to create route53 ALIAS record for the domain
