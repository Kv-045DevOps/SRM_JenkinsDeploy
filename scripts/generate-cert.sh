#!/bin/bash
INSTANCE_NAME=$1

cat > ${INSTANCE_NAME}-csr.json <<EOF
{
  "CN": "system:node:${instance}",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "system:nodes",
      "OU": "Kubernetes The Hard Way",
      "ST": "Oregon"
    }
  ]
}
EOF

INTERNAL_IP=$(aws ec2 describe-instances --filter "Name=tag:Name,Values=$INSTANCE_NAME" --query "Reservations[0].Instances[0].PrivateIpAddress")
EXTERNAL_IP=$(aws ec2 describe-instances --filter "Name=tag:Name,Values=$INSTANCE_NAME" --query "Reservations[0].Instances[0].PublicIpAddress")

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=${INSTANCE_NAME},${EXTERNAL_IP},${INTERNAL_IP} \
  -profile=kubernetes \
  ${INSTANCE_NAME}-csr.json | cfssljson -bare ${INSTANCE_NAME}