apt update && apt install -y ansible-core git wget curl jq openssl podman python3-pip skopeo podman-docker qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virt-manager
pip install jinjanator --break-system-packages
cd /tmp
wget https://go.dev/dl/go1.25.0.linux-amd64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.25.0.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
export VERSION=$(curl https://storage.googleapis.com/kubevirt-prow/release/kubevirt/kubevirt/stable.txt)
wget https://github.com/kubevirt/kubevirt/releases/download/${VERSION}/virtctl-${VERSION}-linux-amd64
sudo install -o root -g root -m 0755 virtctl-${VERSION}-linux-amd64 /usr/local/bin/virtctl
# For AMD64 / x86_64
[ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.30.0/kind-linux-amd64
# For ARM64
[ $(uname -m) = aarch64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.30.0/kind-linux-arm64
OCI_BIN=podman
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
git clone https://github.com/ovn-kubernetes/ovn-kubernetes.git
pushd ovn-kubernetes/contrib/ && ./kind.sh -ds -ic -mne -nse -gm local -ikv && popd
kind export kubeconfig --name ovn
## Add the following for nested virt only
kubectl -n kubevirt patch kubevirt kubevirt --type=merge --patch '{"spec":{"configuration":{"developerConfiguration":{"useEmulation":true}}}}'
git clone https://github.com/tssurya/kubecon-eu-2025-london-udn-workshop.git
kubectl apply -f kubecon-eu-2025-london-udn-workshop/manifests/virt/01-udn.yaml
kubectl apply -f kubecon-eu-2025-london-udn-workshop/manifests/virt/02-workloads.yaml
kubectl wait vmi -nred-namespace red --for=jsonpath='{.status.phase}'=Running --timeout 15m
kubectl wait vmi -nblue-namespace blue --for=jsonpath='{.status.phase}'=Running --timeout 2m
