# リポジトリ情報
OWNER="komination"
REPO="secured-remote-mcp-server-on-aws"

# ページング対応（最大100件ずつ）
PAGE=1
while :
do
  deployments=$(gh api -X GET \
    "/repos/$OWNER/$REPO/deployments?per_page=100&page=$PAGE")

  count=$(echo "$deployments" | jq length)
  if [ "$count" -eq 0 ]; then
    break
  fi

  echo "Deleting $count deployments on page $PAGE..."

  echo "$deployments" | jq -r '.[].id' | while read -r id; do
    echo "  Deleting deployment ID: $id"
    gh api -X DELETE "/repos/$OWNER/$REPO/deployments/$id"
  done

  PAGE=$((PAGE + 1))
done

echo "✅ 全てのDeploymentsを削除しました。"
