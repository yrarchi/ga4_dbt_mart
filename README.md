# ga4_dbt_mart

> 🚧 **このリポジトリは現在開発中です。**  
> 一部未整備・構成変更中の箇所があります

GA4 → BigQuery にエクスポートされたデータをもとに、セッション単位のKPI可視化を可能にする dbt プロジェクトです。

---

## 🔧 開発環境

- Python 3.11
- Poetry
- dbt-bigquery
- BigQuery（location: `asia-northeast1`）

---

## 🚀 セットアップ手順

```bash
# 仮想環境に入る
poetry install
poetry shell

# 接続確認
dbt debug

# モデル実行
dbt run
```
