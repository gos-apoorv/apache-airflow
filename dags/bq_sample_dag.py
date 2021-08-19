from datetime import timedelta, datetime
from airflow import DAG
from airflow.contrib.operators.bigquery_operator import BigQueryOperator
from airflow.contrib.operators.bigquery_check_operator import BigQueryCheckOperator

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(year=2021, month=8, day=19),
    'email': ['airflow@airflow.com'],
    'email_on_failure': True,
    'email_on_retry': False,
    'retries': 5,
    'retry_delay': timedelta(minutes=1),
    'connection_id': 'gcp_test_bigquery',
}


dag = DAG(
    'bq_sample_dag',
    default_args=default_args,
    schedule_interval=None,
    max_active_runs=1,
    concurrency=10,
    tags=['bigquery'],
)

t1 = BigQueryCheckOperator(
    task_id='bq_check_applesearch_max_day',
    bigquery_conn_id='gcp_test_bigquery',
    sql='''
    #legacySql
    SELECT date(max(report_date)) as report_date 
    FROM applesearch_data.campaign_summary 
    WHERE DATE(report_date) = "2021-08-18";
    ''',
    dag=dag)

t2 = BigQueryCheckOperator(
    task_id='bq_check_applesearch_min_day',
    bigquery_conn_id='gcp_test_bigquery',
    sql='''
    #legacySql
    SELECT date(min(report_date)) as report_date 
    FROM applesearch_data.campaign_summary 
    WHERE DATE(report_date) = "2021-08-18";
    ''',
    dag=dag)

# t2 = BigQueryOperator(
#     task_id='bq_write_applesearch_agg',
#     use_legacy_sql=False,
#     write_disposition='WRITE_TRUNCATE',
#     allow_large_results=True,
#     create_disposition='CREATE_IF_NEEDED',
#     sql='''
#     #standardSQL
#     SELECT DATE(report_date),
#     sum(impressions) as num_impression,
#     sum(installs) as num_install,
#     sum(newDownloads) as num_downloads
#     FROM applesearch_data.campaign_summary
#     WHERE DATE(report_date) = "2021-08-18"
#     Group by 1
#     ''',
#     destination_dataset_table='test-gelato-data-warehouse.applesearch_data.campaign_aggregated',
#     dag=dag)

t2.set_upstream(t1)