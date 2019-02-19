/bin/kubectl config set-cluster kubernetes-the-hard-way \
  --certificate-authority=/home/adm_power/Terraform/tls/ca.pem \
  --embed-certs=true \
  --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
  --kubeconfig=cfg/kube-proxy.kubeconfig
/bin/kubectl config set-credentials kube-proxy \
  --client-certificate=/home/adm_power/Terraform/tls/kube-proxy.pem \
  --client-key=/home/adm_power/Terraform/tls/kube-proxy-key.pem \
  --embed-certs=true \
  --kubeconfig=cfg/kube-proxy.kubeconfig
/bin/kubectl config set-context default \
  --cluster=kubernetes-the-hard-way \
  --user=kube-proxy \
  --kubeconfig=cfg/kube-proxy.kubeconfig
/bin/kubectl config use-context default \
  --kubeconfig=cfg/kube-proxy.kubeconfig