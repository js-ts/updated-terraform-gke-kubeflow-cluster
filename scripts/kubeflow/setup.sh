#update link https://www.kubeflow.org/docs/distributions/gke/deploy/management-setup/
# must set LOCATION, NAME, PROJECT

# https://www.kubeflow.org/docs/gke/deploy/management-setup/

## Environment Variables
export MGMT_PROJECT=${PROJECT}
export MANAGED_PROJECT=$PROJECT
export NAME=kf-cluster
export MGMT_DIR=.mlcli/gcp_${PROJECT}_${NAME}/management/
export MGMT_NAME=mgmt-${NAME}
export LOCATION=us-west1-a

## Setting up a management cluster
kpt pkg get https://github.com/kubeflow/gcp-blueprints.git/management@v1.4.0 "${MGMT_DIR}"
cd "${MGMT_DIR}"
make get-pkg
kpt cfg set -R . name "${MGMT_NAME}"
kpt cfg set -R . gcloud.core.project "${MGMT_PROJECT}"
kpt cfg set -R . location "${LOCATION}"
git add ./instance/Kptfile
git add ./upstream/management/Kptfile
make apply-cluster
make create-context
make apply-kcc

## Authorize Cloud Config Connector for each managed project
pushd "../management"
kpt fn eval --image gcr.io/kpt-fn/apply-setters:v0.1 ./managed-project --\
     name="${MGMT_NAME}" \
     gcloud.core.project="${MGMT_PROJECT}" \
     managed-project="${KF_PROJECT}"
gcloud beta anthos apply ./instance/managed-project/iam.yaml

echo "post setup env:"
echo $(env)
