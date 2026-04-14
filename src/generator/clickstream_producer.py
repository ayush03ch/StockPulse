import boto3, json, time, random, os
from datetime import datetime, timezone
from dotenv import load_dotenv

PRODUCTS = ["P101", "P102", "P103", "P104"]
EVENTS = ["view", "search", "add_to_cart", "purchase"]

def build_event():
    product_id = random.choice(PRODUCTS)
    event_name = random.choices(EVENTS, weights=[0.65, 0.15, 0.15, 0.05])[0]

    return {
        "product_id": product_id,
        "event": event_name,
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "user_id": f"U{random.randint(1,500):04d}",
        "price": round(random.uniform(100, 2000), 2),  # adds realism
        "device": random.choice(["mobile", "desktop"]),
    }

def main():
    load_dotenv()
    kinesis = boto3.client("kinesis", region_name=os.getenv("AWS_REGION"))

    stream = os.getenv("KINESIS_STREAM_NAME", "clickstream")
    interval_seconds = float(os.getenv("EVENT_INTERVAL_SECONDS", "1"))

    print(f"Sending clickstream batches to '{stream}' in region '{os.getenv('AWS_REGION')}'")

    while True:
        records = []

        for _ in range(20):  # batch size
            payload = build_event()
            records.append({
                "Data": json.dumps(payload),
                "PartitionKey": payload["product_id"]
            })

        response = kinesis.put_records(StreamName=stream, Records=records)
        sent = len(records) - response["FailedRecordCount"]
        print(f"Sent={sent} Failed={response['FailedRecordCount']}")

        if response["FailedRecordCount"] > 0:
            print("Retrying failed records...")

        time.sleep(interval_seconds)


if __name__ == "__main__":
    main()
