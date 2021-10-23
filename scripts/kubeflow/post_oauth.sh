# Documentation needs to be updated https://www.kubeflow.org/docs/distributions/gke/customizing-gke/
# must set CLOUD, LOCATION, NAME, PROJECT, USER

## Environment Variables
export KF_NAME=${NAME}
export KF_PROJECT=${PROJECT}
export KF_DIR=.mlcli/${CLOUD}_${PROJECT}_${KF_NAME}/configuration

echo $(env)

cd "${KF_DIR}"

make set-values
make apply

# Add user to Kubeflow (https://www.kubeflow.org/docs/gke/customizing-gke/)
gcloud projects add-iam-policy-binding ${PROJECT} --member=user:${USER} --role=roles/container.clusterViewer
gcloud projects add-iam-policy-binding ${PROJECT} --member=user:${USER} --role=roles/iap.httpsResourceAccessor
gcloud projects add-iam-policy-binding ${PROJECT} --member=user:${USER} --role=roles/viewer
