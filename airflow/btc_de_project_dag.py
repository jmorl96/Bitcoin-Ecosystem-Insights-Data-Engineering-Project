from datetime import datetime, timedelta

from airflow.models.dag import DAG
from airflow.providers.google.cloud.operators.cloud_run import CloudRunExecuteJobOperator

import pendulum

with DAG(

    dag_id="btc_de_project_dag",

    dag_display_name="BTC Data Engineering Project DAG",

    default_args={

        "depends_on_past": False,

        "email": ["airflow@example.com"],

        "email_on_failure": False,

        "email_on_retry": False,

        "retries": 0,

        "retry_delay": timedelta(minutes=5),

        # 'queue': 'bash_queue',    start_date: datetime | None = None,


        # 'pool': 'backfill',

        # 'priority_weight': 10,

        # 'end_date': datetime(2016, 1, 1),

        # 'wait_for_downstream': False,

        # 'sla': timedelta(hours=2),

        # 'execution_timeout': timedelta(seconds=300),

        # 'on_failure_callback': some_function, # or list of functions

        # 'on_success_callback': some_other_function, # or list of functions

        # 'on_retry_callback': another_function, # or list of functions

        # 'sla_miss_callback': yet_another_function, # or list of functions

        # 'on_skipped_callback': another_function, #or list of functions

        # 'trigger_rule': 'all_success'

    },

    # [END default_args]

    description="A DAG to run the btc_de_project",

    schedule="@daily",

    start_date=datetime(2025, 1, 15),

) as dag:
    
    overrides = {
        "container_overrides": [
            {
                "name": "job",
                "args": ["XBTUSD", "{{ data_interval_start.int_timestamp }}", "-s", "gcs", "-d", "kraken_data_bucket_de_project", "-u", "{{ data_interval_end.int_timestamp }}"],
                "clear_args": False,
            }
        ],
        "task_count": 1,
        "timeout": "600s",
    }

    cloud_run_job_extract = CloudRunExecuteJobOperator(
        task_id='cloud_run_job_extract',
        project_id='engaged-hook-446222-g6',
        region='us-central1',
        overrides=overrides,
        job_name='kraken-trade-extract-agent-job',
        dag=dag,
        deferrable=False,
    )