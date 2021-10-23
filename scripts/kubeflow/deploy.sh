#Updaed from https://www.kubeflow.org/docs/distributions/gke/deploy/deploy-cli/
# must set CLOUD, LOCATION, NAME, PROJECT, USER

# https://www.kubeflow.org/docs/gke/deploy/deploy-cli/

## Environment Variables 
export KF_NAME=${NAME}
export KF_PROJECT=${PROJECT}
export MLCLI_DIR=${PWD}/.mlcli
export KF_DIR=${MLCLI_DIR}/gcp_${PROJECT}_${NAME}/configuration
export MGMT_NAME=mgmt-${NAME}
export MGMTCTXT=${MGMT_NAME}
export MANAGEMENT_CTXT=$MGMTCTXT

echo $(env)

rm -rf ${KF_DIR}

## Fetch packages using kpt 
kpt pkg get https://github.com/kubeflow/gcp-blueprints.git/kubeflow@v1.4.0 "${KF_DIR}"
cd "${KF_DIR}"
make get-pkg

sed -i '' "s/<YOUR_MANAGEMENT_CTXT>/${MGMTCTXT}/" Makefile 
sed -i '' "s/<YOUR_KF_NAME>/${KF_NAME}/" Makefile
sed -i '' "s/<PROJECT_TO_DEPLOY_IN>/${KF_PROJECT}/" Makefile
sed -i '' "s/<YOUR PROJECT>/${KF_PROJECT}/" Makefile
sed -i '' "s/<ZONE>/${LOCATION}/" Makefile
sed -i '' "s/<REGION OR ZONE>/${LOCATION}/" Makefile
sed -i '' "s/<YOUR_REGION OR ZONE>/${LOCATION}/" Makefile
sed -i '' "s/<YOUR_REGION or ZONE>/${LOCATION}/" Makefile
sed -i '' "s/<YOUR_EMAIL_ADDRESS>/${USER}/" Makefile

kubectl config use-context "${MGMTCTXT}"
kubectl create namespace "${KF_PROJECT}"
kubectl config set-context --current --namespace "${KF_PROJECT}"

# cd ${MLCLI_DIR}
# curl -LO https://storage.googleapis.com/gke-release/asm/istio-1.4.10-asm.18-osx.tar.gz
# curl -LO https://storage.googleapis.com/gke-release/asm/istio-1.4.10-asm.18-osx.tar.gz.1.sig
# openssl dgst -sha256 -verify /dev/stdin -signature istio-1.4.10-asm.18-osx.tar.gz.1.sig istio-1.4.10-asm.18-osx.tar.gz <<'EOF'
# -----BEGIN PUBLIC KEY-----
# MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEWZrGCUaJJr1H8a36sG4UUoXvlXvZ
# wQfk16sxprI2gOJ2vFFggdq3ixF2h4qNBt0kI7ciDhgpwS8t+/960IsIgw==
# -----END PUBLIC KEY-----
# EOF
# tar xzf istio-1.4.10-asm.18-osx.tar.gz
# cd istio-1.4.10-asm.18

# old code updated to

cd ${MLCLI_DIR} && { \
	curl https://storage.googleapis.com/csm-artifacts/asm/install_asm_1.9 > install_asm; \
	curl https://storage.googleapis.com/csm-artifacts/asm/install_asm_1.9.sha256 > install_asm.sha256; \
	sha256sum -c --ignore-missing install_asm.sha256; \
	chmod +x install_asm; \
	cd -;}
# Source of the code https://github.com/kubeflow/gcp-blueprints/blob/master/kubeflow/asm/Makefile
# Official documentation of downloading install_asm: https://cloud.google.com/service-mesh/docs/scripted-install/asm-onboarding#downloading_the_script
# It cannot control the patch version so we won't use this approach for now.
# cd ./asm && { \
# 	curl https://storage.googleapis.com/csm-artifacts/asm/install_asm_1.9 > install_asm; \
# 	curl https://storage.googleapis.com/csm-artifacts/asm/install_asm_1.9.sha256 > install_asm.sha256; \
# 	sha256sum -c --ignore-missing install_asm.sha256; \
# 	chmod +x install_asm; \
# 	cd -;}

export PATH=${PWD}/bin:${PATH}
