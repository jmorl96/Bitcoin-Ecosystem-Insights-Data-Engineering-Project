# BTC Analytics dbt Project

Welcome to the BTC Analytics dbt project! This project is designed to transform and analyze Bitcoin trade and blockchain data using dbt (data build tool).

## Introduction

The BTC Analytics dbt project is a data engineering project that transforms raw Bitcoin/USD trade data and blockchain data into a structured, queryable format. The project uses dbt to transform the data and create a data model that can be used to analyze the Bitcoin ecosystem. 

## Data Sources

The BTC Analytics dbt project uses the following two data sources:

1. **Bitcoin/USD Trade Data**: Extracted from Kraken's Public API, this data source contains information about Bitcoin/USD trades. The data includes information such as the trade price, trade volume, and trade timestamp.

2. **Bitcoin Blockchain Data**: Extracted from the Bitcoin blockchain blocks public dataset on Google BigQuery, this data source contains information about Bitcoin blockchain blocks. The data includes information such as the block hash, block height, and block timestamp.

## Data Model

The BTC Analytics dbt project creates a data model that combines the Bitcoin/USD trade data and the Bitcoin blockchain data. The data model is designed to enable analysis of the Bitcoin ecosystem, including trade volume, trade frequency, and blockchain activity.

The data model is designed following a medalion like structure, with the following layers and tables:


1. **Bronze**: Raw data tables that are extracted from the data sources.
    1. `t_xbtusd_trade_data_b` - Raw Bitcoin/USD trade data table extracted from Kraken's Public API.
    2. `blocks` - Raw Bitcoin blockchain blocks data table from Google BigQuery Pubic Dataset.

2. **Silver**: Intermediate data tables that are transformed and cleaned from the raw data. Using an incremental model, the silver tables are updated with new data from the raw tables.
    1. `t_xbtusd_trade_data_s` - Cleaned and transformed Bitcoin/USD trade data table.
    2. `t_bitcoin_blockchain_blocks_s` - Cleaned and transformed Bitcoin blockchain blocks data table.

3. **Gold**: Enriched data tables that are aggregated from silver layer tables. The gold tables could be used directly for analysis and reporting.
    1. `t_agg_daily_xbtusd_trade_data_g` - Daily aggegated Bitcoin/USD trade data table.
    2. `t_agg_daily_bitcoin_blockchain_blocks_g` - Daily aggregated Bitcoin blockchain blocks data table. 

4. **Platinum**: Exposition data tables combining gold layer tables. This layer provide a specific designed table for reporting. For columnar databases like BigQuery and direct query connected BI tools like Looker Studio this layer improves the performance and usability of the data and speed up the reporting development process.
    1. `t_agg_daily_btc_trade_block_data_p` - Daily aggregated Bitcoin/USD trade and blockchain blocks data table.

## Usage

Designed to be used as containerized dbt project, build and deploy the image using the provided Dockerfile and the provider of your choice. On first run you should use the `dbt run-operation stage_external_sources` to stage the external sources data. After that, you can use the `dbt run` command to run the dbt project.

**_Note:_**  For the Bitcoin Ecosystem Insights project, we are deploying the dbt project on top a Google Cloud Run Job, using the Google Cloud Build service to build and deploy the image.






