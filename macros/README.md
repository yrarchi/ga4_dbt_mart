# Macros: GA4 データプロファイリング用マクロ集

このディレクトリには、GA4の構造化データを分析・整備するためのマクロを格納しています。  
特に `profiling/` は `events_*` テーブル内の以下の型ごとの処理に対応するために整備しました。

## 型別マクロ対応一覧

| マクロ名                 | 対応型              | 用途概要                                 |
|--------------------------|---------------------|------------------------------------------|
| `inspect_scalar_columns` | スカラー型          | カラムごとの NULL率 / ユニーク数 を集計  |
| `inspect_array_field`    | ARRAY<STRUCT> 型    | keyごとにvalueを集計（event_paramsなど） |
| `inspect_record_field`   | STRUCT 型           | 任意のフィールドリストを渡して構造体を調査（device, traffic_sourceなど） |

## マクロ詳細と使用方法

1. inspect_scalar_columns

- 対象型: スカラー型（STRING, INT64 など）  

- 以下を出力：件数, NULL件数, ユニーク件数

```bash
dbt run-operation inspect_scalar_columns --args '{
  "source_table": "project.dataset.events_yyyymmdd"
}'
```

2. inspect_array_field

- 対象型: ARRAY<STRUCT> 型（例：event_params）

- 各keyごとに string_value, int_value, float_value, double_value に分けて集計します。

- 以下を出力：型, 件数, NULL件数, ユニーク件数, サンプル値（最大3件）

```bash
dbt run-operation inspect_array_field --args '{
  "source_table": "project.dataset.events_yyyymmdd",
  "column_name": "event_params"
}'
```

3. inspect_record_field

- 対象型: STRUCT 型（例：device）

- fields には調査対象とするフィールド名の配列を渡します。

- 以下を出力：件数, NULL件数, ユニーク件数, サンプル値（最大3件）

```bash
dbt run-operation inspect_record_field --args '{
  "source_table": "project.dataset.events_yyyymmdd",
  "struct_column": "device",
  "fields": ["category", "operating_system", "browser"]
}'
```

## 備考
すべてのマクロは標準出力に JSON 形式で出力されます
