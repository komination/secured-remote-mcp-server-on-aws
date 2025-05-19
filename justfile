tf-init:
    cd /app/terraform/env/dev && \
    terraform init

tf-plan:
    cd /app/terraform/env/dev && \
    terraform plan

build-lambda-zip:
    cd /app/src && \
    zip -r /app/sam/lambda.zip . -x "requirements.txt" "pyproject.toml" "deps/*"

build-layer-zip:
    cd /app/src && \
    python -m pip install --upgrade -r "requirements.txt" --target "./deps" && \
    cd ./deps && \
    zip -r /app/sam/layer.zip .

pr-create head_branch base_branch title:
    gh pr create \
        --base {{base_branch}} \
        --head {{head_branch}} \
        --title "{{title}}" \
        --body "" \
        --label ""
