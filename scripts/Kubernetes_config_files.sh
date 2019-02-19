for i in 0 1 2; do
  instance="worker-${i}"
  instance_hostname="ip-10-240-0-1${i}"
  /bin/kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=/home/adm_power/Terraform/tls/ca.pem \
    --embed-certs=true \
    --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
    --kubeconfig=cfg/${instance}.kubeconfig

  /bin/kubectl config set-credentials system:node:${instance_hostname} \
    --client-certificate=/home/adm_power/Terraform/tls/${instance}.pem \
    --client-key=/home/adm_power/Terraform/tls/${instance}-key.pem \
    --embed-certs=true \
    --kubeconfig=cfg/${instance}.kubeconfig

  /bin/kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:node:${instance_hostname} \
    --kubeconfig=cfg/${instance}.kubeconfig

  /bin/kubectl config use-context default \
    --kubeconfig=cfg/${instance}.kubeconfig
done