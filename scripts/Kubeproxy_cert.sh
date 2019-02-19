cat > /home/adm_power/Terraform/tls/kube-proxy-csr.json <<EOF
{
  "CN": "system:kube-proxy",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "system:node-proxier",
      "OU": "Kubernetes The Hard Way",
      "ST": "Oregon"
    }
  ]
}
EOF

cfssl gencert \
  -ca=/home/adm_power/Terraform/tls/ca.pem \
  -ca-key=/home/adm_power/Terraform/tls/ca-key.pem \
  -config=/home/adm_power/Terraform/tls/ca-config.json \
  -profile=kubernetes \
  ~/Terraform/tls/kube-proxy-csr.json | cfssljson -bare ~/Terraform/tls/kube-proxy