# aws-vpc-private-lambda-for-mcp

認証付きのAPI Gateway (HTTP) をエントリポイントとし、VPC内に配置されたプライベートなLambdaを経由してS3にアクセスすることで、安全にMCP Serverを公開するソリューションです。</br>
</br>
本リポジトリでは、S3のファイルリストを返す簡易的な例を示していますが、Lambdaに様々なリソースにアクセスするMCP Serverを実装することで多様な用途に対応できます。

![アーキテクチャ図](./architecture.png)

## セットアップ

```bash
cp .env.sample .env
```
