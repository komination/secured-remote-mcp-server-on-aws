tf-init:
    cd /app/terraform/env/dev && \
    terraform init

tf-plan:
    cd /app/terraform/env/dev && \
    terraform plan