# secured-remote-mcp-server-on-aws

認証付きのAPI Gateway (HTTP) をエントリポイントとし、VPC内に配置されたプライベートなLambdaを経由してS3にアクセスすることで、安全にMCP Serverを公開するソリューションです</br>
</br>
本リポジトリでは、S3のファイルリストを返す簡易的な例を示していますが、Lambdaに様々なリソースにアクセスするMCP Serverを実装することで多様な用途に対応できます</br>
</br>
※TerraformやMCPのキャッチアップを目的に、プロダクション環境へのデプロイを想定したユースケースでポートフォリオ開発を進めています。なお、CloudTrailのようにコストが高くなるサービスの構築は一旦対象外としています。

![アーキテクチャ図](./architecture.png)

## ディレクトリ構成

```bash

├── /.devcontainer
├── /.vscode
│   ├── mcp.json                        # GitHub Copilot Agentモードで使用する際の設定
│   └── settings.json                   # DevContainer内のVSCode設定
├── /.github
│   ├── /workflows                      
│   └── copilot-instructions.md         # GitHub Copilotのカスタム指示 
├── /terraform
│   ├── /env                 # 環境ごとの設定
│   │   ├── /dev             # dev環境向け
│   │   └── /prod            # prod環境向け
│   └── /modules             # 再利用可能モジュール定義
│       ├── /vpc             
│       ├── /lambda
│       └── ...
├── /sam                     # aws sam cli版 (未完成)
├── /src                     # mcp serverのソースコード
├── /src                     # mcp serverのソースコード
└── README.md                # このファイル
```

## 環境構築

前提条件:

1. devcontainer実行環境
1. GitHubアカウント連携が済んでいるHCP Terraform アカウント
1. AWSアカウントと紐づいたIAM Identity Centerユーザー

.env作成:

```bash
cp .env.sample .env
cp .auto.tfvars.sample .auto.tfvars
```

HCP Terraform bootstrap:

1. 「TFE_TOKEN」は「<https://app.terraform.io/app/settings/tokens>」で発行
1. 「TFE_ORGANIZATION」は「<https://app.terraform.io/app/organizations/new>」で作成
1. HCP Terraformワークスペースの作成

```bash
# devcontainerに入って以下のコマンドを実行
/app$ terraform init
/app$ terraform plan
/app$ terraform apply

# 🛠️ bootstrap.tf`を使用してHCP Terraformに以下の構造が作成されます
YOUR_ORGANIZATION/
├── projects/
    └── secured-remote-mcp-server-on-aws/
        └── workspaces/
            ├── dev-secured-remote-mcp-server-on-aws
            └── prod-secured-remote-mcp-server-on-aws
```

## 使用方法

### 1. OAuthアクセストークンの取得

API Gatewayへのアクセスに必要なOAuthアクセストークンを取得します：

```bash
# devcontainer内

# トークンのみ取得（AWS Secrets Managerから認証情報を取得して生成）
# 特定のAWSプロファイルを使用してトークン取得
just get-token "my-api-secret" "profile-name"

# API接続テスト（トークン取得からAPI呼び出しまでの全体テスト）
just test-api "my-api-secret" "https://{apiエンドポイント名}.execute-api.ap-northeast-1.amazonaws.com/mcp/"
```

### 2. MCP Clientからの利用

取得したトークンを使用してMCP Clientを設定します。</br>

例: VSCode拡張機能のGitHub Copilot Agentの設定例(mcp.json)

```json
{
    "servers": {
        "aws-private-lambda-for-mcp": {
            "type": "http",
            "url":  "https://{apiエンドポイント名}.execute-api.ap-northeast-1.amazonaws.com/mcp/",
            "headers": {
                "Authorization": "Bearer {上記で取得したトークン}",
                "Accept": "application/json"
            }
        }
    }
}
```
