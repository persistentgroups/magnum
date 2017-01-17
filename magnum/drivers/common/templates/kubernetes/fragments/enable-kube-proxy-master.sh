#!/bin/sh

. /etc/sysconfig/heat-params

if [ -n "${INSECURE_REGISTRY_URL}" ]; then
    if [ $(uname -p) = "ppc64le" ]; then
        HYPERKUBE_IMAGE="${INSECURE_REGISTRY_URL}/google_containers/hyperkube-ppc64le:${KUBE_VERSION}"
    fi
    if [ $(uname -p) = "x86_64" ]; then
        HYPERKUBE_IMAGE="${INSECURE_REGISTRY_URL}/google_containers/hyperkube:${KUBE_VERSION}"
    fi
else
    if [ $(uname -p) = "ppc64le" ]; then
        HYPERKUBE_IMAGE="gcr.io/google_containers/hyperkube-ppc64le:${KUBE_VERSION}"
    fi
    if [ $(uname -p) = "x86_64" ]; then
        HYPERKUBE_IMAGE="gcr.io/google_containers/hyperkube:${KUBE_VERSION}"
    fi
fi

init_templates () {
    local TEMPLATE=/etc/kubernetes/manifests/kube-proxy.yaml
    [ -f ${TEMPLATE} ] || {
        echo "TEMPLATE: $TEMPLATE"
        mkdir -p $(dirname ${TEMPLATE})
        cat << EOF > ${TEMPLATE}
apiVersion: v1
kind: Pod
metadata:
  name: kube-proxy
  namespace: kube-system
spec:
  hostNetwork: true
  containers:
  - name: kube-proxy
    image: ${HYPERKUBE_IMAGE}
    command:
    - /hyperkube
    - proxy
    - --master=http://127.0.0.1:8080
    - --logtostderr=true
    - --v=0
    securityContext:
      privileged: true
EOF
    }
}

init_templates
