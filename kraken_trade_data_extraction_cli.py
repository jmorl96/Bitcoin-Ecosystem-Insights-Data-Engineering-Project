"""
kraken_trade_data_extraction_cli.py

This script fetches trade data from the Kraken API for a specified asset pair within a given time range.
The data is then converted to a Parquet file and uploaded to Google Cloud Storage or saved locally.
Command Line Interface (CLI) like tool.

Usage:
    python kraken_trade_data_extraction_cli.py <pair> <since> [-u <until>] [-s <storage>] [-d <destination>]

Arguments:
    pair (str): The asset pair to fetch data for (e.g., 'XBTUSD').
    since (int): The starting timestamp for fetching trade data.
    -u, --until (int): The ending timestamp for fetching trade data.
    -s, --storage (str): Destination storage provider. Options: 'local' or 'gcs'. Default: 'local'.
    -d, --destination (str): Destination bucket name in Google Cloud Storage.
"""

import argparse
import requests
import pandas as pd
import time
import logging
import io


def read_from_kraken_trade_endpoint(pair:str,since:int,until:int):
    """
    Fetches trade data from the Kraken API for a specified asset pair within a given time range.

    This function makes repeated requests to the Kraken API's public Trades endpoint to fetch trade data
    for the specified asset pair. It continues to make requests until the 'until' timestamp is reached or exceeded.

    Args:
        pair (str): The asset pair to fetch data for (e.g., 'XBTUSD').
        since (int): The starting timestamp for fetching trade data.
        until (int): The ending timestamp for fetching trade data.

    Yields:
        dict: The JSON response from the Kraken API containing trade data.

    Raises:
        requests.exceptions.HTTPError: If an HTTP error occurs during the API request.
    """
    url = "https://api.kraken.com/0/public/Trades"

    payload = {}
    query_params = {"pair": pair, "since": since}
    headers = {
    'Accept': 'application/json'
    }

    response = requests.request("GET", url, headers=headers, data=payload, params=query_params)
    response.raise_for_status() # Raise exception for HTTP errors
    yield response.json()
    if len(str(until)) < 19:
        until = until * 10**(19-len(str(until))) # Convert until to nanoseconds
    last_timestamp = int(response.json()["result"]["last"])
    while last_timestamp < until:
        query_params = {"pair": pair, "since": last_timestamp}
        response = requests.request("GET", url, headers=headers, data=payload, params=query_params)
        response.raise_for_status() # Raise exception for HTTP errors
        if last_timestamp == int(response.json()["result"]["last"]):
            break
        yield response.json()
        last_timestamp = int(response.json()["result"]["last"])
        time.sleep(2) # Kraken API has a rate limit of 1 request per second for public endpoints so we are sleeping for 2 seconds



def parse_kraken_trade_endpoint_response(response:dict):
    """
    Parses the JSON response from the Kraken API's public Trades endpoint.
    
    Args:
        response (dict): The JSON response from the Kraken API containing trade data.
    
    Returns:
        tuple: A tuple containing the trade data and the last timestamp.
    """
    for key in response["result"].keys():
        if key != "last":
            data = response["result"][key]
    last = int(response["result"]["last"])
    if len(str(last)) > 10:
        last = last // 10**9 # Convert last to seconds
    return data, last

def kraken_trade_data_to_parquet(data:list, since:int, last:int, pair:str, file_object):
    """
    Converts Kraken trade data to a Parquet file.

    Args:
        data (list): The trade data to be converted.
        since (int): The starting timestamp for the trade data.
        last (int): The ending timestamp for the trade data.
    """
    columns = [
    "price",
    "volume",
    "time",
    "buy_sell",
    "market_limit",
    "miscellanious",
    "trade_id"
    ]

    dataframe = pd.DataFrame(data=data, columns=columns)
    if file_object:
        dataframe.to_parquet(file_object,compression="gzip")
    else:
        dataframe.to_parquet(f"{pair}-{since}-{last}.parquet.gzip",compression="gzip")
    
def upload_to_gcs(file_object,bucket_name,destination_blob_name):
    """
    Uploads a file object to Google Cloud Storage.
    Args:
        file_object (str): The content of the file to be uploaded.
        bucket_name (str): The name of the GCS bucket where the file will be uploaded.
        destination_blob_name (str): The destination path and filename in the GCS bucket.
    Returns:
        None
    Raises:
        google.cloud.exceptions.GoogleCloudError: If an error occurs during the upload process.
    Example:
        upload_to_gcs("file content", "my_bucket", "path/to/destination/file.txt")
    """
    
    from google.cloud import storage
    storage_client = storage.Client()
    bucket = storage_client.bucket(bucket_name)
    blob = bucket.blob(destination_blob_name)

    blob.upload_from_string(file_object)

    print(
    f"{destination_blob_name} uploaded to {bucket_name}."
    )

def epoch_to_datetime(epoch:int):
    """
    Converts an epoch timestamp to a datetime string in the format 'YYYY-MM-DDTHHMMSSZ'.
    """
    return time.strftime('%Y-%m-%dT%H%M%SZ', time.gmtime(epoch))



if __name__ == '__main__':

    # Configure logging
    logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

    # Parse command line arguments
    parser = argparse.ArgumentParser()

    parser.add_argument('pair', type=str, help='Asset pair to get data for. Example: XBTUSD')
    parser.add_argument('since', type=int, help='Return trade data since given timestamp. Example: 1616663618')
    parser.add_argument('-u', '--until', type=int, help='Return trade data until given timestamp. Example: 1616663618')
    parser.add_argument('-s', '--storage', type=str, choices=['local','gcs'],default='local', help='Destination storage provider. Example: gcs')
    parser.add_argument('-d', '--destination', type=str, help='Destination bucket name. Example: kraken_data_bucket_de_project')


    args = parser.parse_args()

    pair = args.pair
    since = args.since
    if args.until:
        until = args.until
    else:
        until = int(time.time_ns())
    storage = args.storage
    destination = args.destination
    
    # Data extraction process
    logging.info(f'Starting data extraction for pair: {pair}, since: {since}, until: {until}')

    full_data = []
    for response in read_from_kraken_trade_endpoint(pair,since,until):
        data, last_timestamp = parse_kraken_trade_endpoint_response(response)
        full_data = [*full_data, *data]

    logging.info(f'Finished data extraction. Total records: {len(full_data)}')

    # Data storage process
    if storage == 'local':
        kraken_trade_data_to_parquet(full_data, epoch_to_datetime(since), epoch_to_datetime(last_timestamp), pair, None)
        logging.info('Data successfully written to parquet file')
    
    elif storage == 'gcs':
        file_object = io.BytesIO()
        kraken_trade_data_to_parquet(full_data, since, last_timestamp, pair, file_object)
        upload_to_gcs(file_object.getvalue(),destination,f"{pair}/{pair}-{epoch_to_datetime(since)}-{epoch_to_datetime(last_timestamp)}.parquet.gzip")
        logging.info(f'Data successfully uploaded to GCS bucket: {destination}')

    logging.info('Process completed')


    

