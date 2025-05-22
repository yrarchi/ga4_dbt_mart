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

### 1. 仮想環境に入る
```bash
poetry install
poetry shell
```

### 2. pre-commit フックを有効化する（初回のみ）
```bash
pre-commit install
```

### 3. 接続確認
```bash
dbt debug
```

### 4. モデルを実行
```bash
dbt run
```
