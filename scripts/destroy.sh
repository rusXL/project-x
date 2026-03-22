#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/.."

# platform first, then infra
cd terraform/platform
terraform destroy
cd ../infra
terraform destroy
