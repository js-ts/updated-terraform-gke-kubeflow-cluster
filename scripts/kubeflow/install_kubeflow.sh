# must set CLOUD, LOCATION, NAME, PROJECT

## Environment Variables
export MGMT_PROJECT=${PROJECT}
export MANAGED_PROJECT=${MGMT_PROJECT}
export MGMT_DIR=.mlcli/${CLOUD}_${MGMT_PROJECT}_${NAME}/management/

export KF_NAME=${NAME}
export KF_PROJECT=${PROJECT}
export KF_DIR=.mlcli/${CLOUD}_${KF_PROJECT}_${NAME}/configuration
export MGMT_NAME=mgmt-${NAME}
export MGMTCTXT=${MGMT_NAME}
export MANAGEMENT_CTXT=${MGMTCTXT}
export USER=$(gcloud config get-value account)

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

n=0
retries=2
setup_status=1
until (( n >= retries ))
do
  ${DIR}/setup.sh && setup_status=0 && break
  n=$((n+1))
  if (( n < retries ))
  then
    echo "Retrying in 60s..." 
    sleep 60
  fi
done

if (( setup_status != 0 ))
then
  echo "Kubeflow setup failed"
  exit 1
fi

${DIR}/deploy.sh
${DIR}/post_oauth.sh
