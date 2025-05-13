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

create-pull-request source_branch dist_branch title:
    gh pr create \
        --base {{source_branch}} \
        --head {{dist_branch}} \
        --title {{title}} \
        --body "" \
        --label "" \
        --assignee ""