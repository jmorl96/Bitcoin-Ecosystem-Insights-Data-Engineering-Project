# Bitcoin Ecosystem Insights Data Engineering Project


## Table of Contents

<img style="float: right;" src="./media/btc.png" width="200" >

- [Project Overview](#project-overview)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Data Sources](#data-sources)
- [Data Collection](#data-collection)
- [Data Warehousing](#data-warehousing)
- [Orchestration](#orchestration)
- [Visualization](#visualization)
- [Reproducibility](#reproducibility)
- [Future Improvements](#future-improvements)

## Project Overview

Bitcoin is a decentralized digital currency, without a central bank or single administrator, that can be sent from user to user on the peer-to-peer bitcoin network without the need for intermediaries. The Bitcoin Ecosystem Insights Data Engineering Project aims to provide insights into the Bitcoin ecosystem by collecting, processing, and analyzing data from both the Bitcoin blockchain and Kraken cryptocurrency exchange. Combining data from these two sources allows for a more comprehensive view of the Bitcoin ecosystem, including on-chain transactions and market activity.

## Tech Stack

- **Infrastructure**: Google Cloud Platform (GCP)
- **Infrastructure as Code**: Terraform
- **Data Collection**: Python, Kraken API, Google Cloud Storage
- **Data Processing and Warehousing**: DBT, BigQuery, SQL
- **Containerization**: Docker, Cloud Run, Artifact Registry, Cloud Build
- **Orchestration**: Airflow on Google Cloud Composer
- **Visualization**: Looker Studio

## Architecture

The project architecture is based on a modern cloud-native data engineering stack. Data from the Bitcoin blockchain and Kraken API is collected, processed, and stored in Google BigQuery. The data is transformed and modeled using DBT to create a set of tables that are optimized for analysis and visualization. Apache Airflow is used to orchestrate the data pipeline, ensuring that the data is collected, processed, and loaded into the data warehouse on a daily basis. Looker Studio is used to visualize the data and provide insights into the Bitcoin ecosystem.

![Architecture](./media/architecture.png)

## Data Sources

The project uses two main data sources:

1. **Bitcoin Blockchain**: We use the Bitcoin blockchain as a source of on-chain transaction data. We collect this data from Google BigQuery's public dataset `bigquery-public-data.crypto_bitcoin`.

2. **Kraken API**: We use the Kraken REST API (public "Trades" endpoint) to collect market data from the Kraken cryptocurrency exchange. This data includes information on Bitcoin price, volume, and other market metrics.

## Data Collection

Data from the Bitcoin blockchain is collected directly from Google BigQuery's public dataset using SQL queries. The data is stored on a staging BigQuery table where new data is merged with existing data on a daily basis. DBT is used for this data collection process.

Data from the Kraken API is collected using a command-line like Python script that makes requests to the Kraken REST API. Data is collected and stored in Google Cloud Storage as Parquet files that are later read from BigQuery with a external table defined with DBT.

## Data Warehousing

Data from both the Bitcoin blockchain and Kraken API is stored in Google BigQuery. The data is transformed and modeled using DBT to create a set of tables that are optimized for analysis and visualization. A medallion like schema is used to organize the data in a way that is easy to query and understand.

The data warehouse is updated daily with new data from both sources. DBT is used to manage the data transformation process and ensure that the data is clean, consistent, and up-to-date. The data warehouse is designed to be scalable and flexible, allowing for easy integration of new data sources and analysis tools. 

![DBT Lineage](./media/dbt_lineage.png)


## Orchestration

The data collection, processing, and warehousing tasks are orchestrated using Apache Airflow on Google Cloud Composer. Airflow DAGs are used to schedule and run the various tasks in the pipeline, ensuring that the data is collected, processed, and loaded into the data warehouse on a daily basis. DBT Jobs on Cloud Run are only executed if the dag execution is on normal daily schedule.

![Airflow DAG](./media/airflow.png)

![Airflow DAG Schedule](./media/airflow_schedule.png)

## Visualization

The data on the platinum last layer table is visualized using Looker Studio. Looker Studio is connected only to the Platinum table on BigQuery used as exposition layer.
Two pages are created on Looker Studio. The first page is divided into two sections, one for the Bitcoin blockchain data and the other for the Kraken API data. The second page is a dashboard that combines data from both sources to provide a comprehensive view of the correlation between on-chain transactions and market activity.

![Dashboard Page 1](./media/dashboard_1.png)

![Dashboard Page 2](./media/dashboard_2.png)

## Reproducibility

The project is designed to be reproducible and scalable. The infrastructure is defined as code using Terraform, allowing for easy deployment and management of resources on Google Cloud Platform. The data collection, processing, and warehousing tasks are automated using Airflow and DBT, ensuring the pipeline runs smoothly and consistently. 

You can reproduce the project easily by following the steps below:

1. Create a Google Cloud Platform account.
2. Create a Google Cloud Project.
3. Enable the necessary APIs on Google Cloud Project and enable billing.
4. Install Terraform, Docker, and the Google Cloud SDK on your local machine.
5. Configure Google Cloud Application Default Credentials.
6. Clone the project repository from GitHub.
7. Configure the project settings in the `terraform.tfvars` file. You can find an example file in the `terraform` directory.
8. Run `terraform init`, `terraform plan`, and `terraform apply` to deploy the infrastructure inside the `terraform` directory.
9. **That's it!** The pipeline will now backfill the data and run automatically on a daily basis.
10. **OPTIONAL**: Make a copy of the Looker Studio dashboard from the link located in the `looker` section of the repository and change the data source to your platinum table on BigQuery for exploring the data.

> **_NOTE:_**  For the project to run properly, you need to have a Google Cloud Platform account and enable billing. The project uses Google Cloud services that may incur costs. Make sure to review the pricing of each service before deploying the infrastructure.

## Future Improvements

The project can be improved in several ways:

- Data extraction from the Bitcoin blockchain can be performed with a new ingestion process exporting data to files on Google Cloud Storage so you don't need to deploy the project on US region.
- Add more tests to the project to DBT and the rest of the pipeline in general.
- Add more data sources to the project. For example, social media data for sentiment analysis.
- Compatibility with other cryptocurrencies and exchanges.
