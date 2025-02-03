from datetime import datetime, timedelta

from airflow.models.dag import DAG
from airflow.models import Variable
from airflow.providers.google.cloud.operators.cloud_run import CloudRunExecuteJobOperator
from airflow.operators.latest_only import LatestOnlyOperator

import pendulum

# Read environment variables

project_id = Variable.get("custom_project_id")
region = Variable.get("custom_region")
data_bucket = Variable.get("custom_data_bucket")
extract_job_name = Variable.get("custom_extract_job_name")
dbt_job_name = Variable.get("custom_dbt_job_name")

# Define the default_args dictionary

with DAG(

    dag_id="btc_de_project_dag",

    dag_display_name="BTC Data Engineering Project DAG",

    default_args={

        "depends_on_past": False,

        "email_on_failure": False,

        "email_on_retry": False,

        "retries": 0,

        "retry_delay": timedelta(minutes=5)

    },

    max_active_runs=5,

    concurrency=5,

    # Define the schedule interval

    description="A DAG to run the btc_de_project",

    schedule="@daily",

    start_date=datetime(2024, 11, 1),

) as dag:
    
    # Run data extraction job on Cloud Run
    
    overrides_extraction = {
        "container_overrides": [
            {
                "name": "job",
                "args": ["XBTUSD", "{{ data_interval_start.int_timestamp }}", "-s", "gcs", "-d", data_bucket, "-u", "{{ data_interval_end.int_timestamp }}"],
                "clear_args": False,
            }
        ],
        "task_count": 1,
        "timeout": "600s",
    }

    cloud_run_job_extract = CloudRunExecuteJobOperator(
        task_id='cloud_run_job_extract',
        project_id=project_id,
        region=region,
        overrides=overrides_extraction,
        job_name=extract_job_name,
        dag=dag,
        deferrable=False,
    )

    # Run dbt job on Cloud Run to create external tables

    overrides_dbt_external_tables = {
        "container_overrides": [
            {
                "name": "job-external-tables",
                "args": ["run-operation","stage_external_sources"],
                "clear_args": False,
            }
        ],
        "task_count": 1,
        "timeout": "600s",
    }

    cloud_run_job_dbt_external_tables = CloudRunExecuteJobOperator(
        task_id='cloud_run_job_dbt_external_tables',
        project_id=project_id,
        region=region,
        overrides=overrides_dbt_external_tables,
        job_name=dbt_job_name,
        dag=dag,
        deferrable=False,
    )

    # Run dbt job on Cloud Run to execute the dbt models

    overrides_dbt_models = {
        "container_overrides": [
            {
                "name": "job-models",
                "args": ["run"],
                "clear_args": False,
            }
        ],
        "task_count": 1,
        "timeout": "600s",
    }

    cloud_run_job_dbt_models = CloudRunExecuteJobOperator(
        task_id='cloud_run_job_dbt_models',
        project_id=project_id,
        region=region,
        overrides=overrides_dbt_models,
        job_name=dbt_job_name,
        dag=dag,
        deferrable=False,
    )

    # This operator allows the dag running next tasks only if the current dag run is the latest dag run.

    only_latest_dag_run = LatestOnlyOperator(task_id="only_latest_dag_run", dag=dag)

    # Define the task dependencies

    cloud_run_job_extract >> only_latest_dag_run >> cloud_run_job_dbt_external_tables >> cloud_run_job_dbt_models

