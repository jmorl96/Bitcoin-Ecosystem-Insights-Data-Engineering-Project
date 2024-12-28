import argparse
import requests
import pandas as pd
import time


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
    last_timestamp = int(response.json()["result"]["last"])
    while last_timestamp < until:
        print(last_timestamp < until)
        print("Last timestamp: ", last_timestamp)
        print("until: ", int(response.json()["result"]["last"]))
        query_params = {"pair": pair, "since": last_timestamp}
        response = requests.request("GET", url, headers=headers, data=payload, params=query_params)
        response.raise_for_status() # Raise exception for HTTP errors
        if last_timestamp == int(response.json()["result"]["last"]):
            break
        yield response.json()
        last_timestamp = int(response.json()["result"]["last"])


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
    last = response["result"]["last"]
    return data, last

def kraken_trade_data_to_parquet(data:list, since:int, last:int):
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
    dataframe.to_parquet(f"{pair}-{since}-{last}.parquet.gzip",compression="gzip")




if __name__ == '__main__':

    parser = argparse.ArgumentParser()

    parser.add_argument('pair', type=str, help='Asset pair to get data for. Example: XBTUSD')
    parser.add_argument('since', type=int, help='Return trade data since given timestamp. Example: 1616663618')
    parser.add_argument('-u', '--until', type=int, help='Return trade data until given timestamp. Example: 1616663618')

    args = parser.parse_args()

    pair = args.pair
    since = args.since
    if args.until:
        until = args.until
    else:
        until = int(time.time_ns())

    full_data = []
    for response in read_from_kraken_trade_endpoint(pair,since,until):
        data, last_timestamp = parse_kraken_trade_endpoint_response(response)
        full_data = [*full_data, *data]    

    kraken_trade_data_to_parquet(full_data, since, last=last_timestamp)

