import os
import boto3
from megadetector.detection import run_detector
from megadetector.visualization import visualization_utils as vis_utils

s3 = boto3.client("s3")

PROCESSED_BUCKET = os.environ["PROCESSED_BUCKET"]
CONFIDENCE_THRESHOLD = 0.2  # Standardwert laut MegaDetector-Doku, ggf. später anpassen (0.15-0.3 üblich)

# Modell wird beim Kaltstart der Lambda EINMAL geladen, nicht bei jedem Aufruf
model = run_detector.load_detector("MDV5A")

CATEGORY_TO_FOLDER = {
    "1": "tier",    # animal
    "2": "mensch",  # person
    "3": "auto",    # vehicle
}


def lambda_handler(event, context):
    for record in event["Records"]:
        source_bucket = record["s3"]["bucket"]["name"]
        source_key = record["s3"]["object"]["key"]

        local_path = f"/tmp/{os.path.basename(source_key)}"
        s3.download_file(source_bucket, source_key, local_path)

        image = vis_utils.load_image(local_path)
        result = model.generate_detections_one_image(image)

        detections_above_threshold = [
            d for d in result["detections"] if d["conf"] > CONFIDENCE_THRESHOLD
        ]

        if not detections_above_threshold:
            folder = "leer"
        else:
            # höchste Konfidenz gewinnt, falls mehrere Kategorien im Bild erkannt wurden
            top_detection = max(detections_above_threshold, key=lambda d: d["conf"])
            folder = CATEGORY_TO_FOLDER.get(top_detection["category"], "leer")

        target_key = f"{folder}/{os.path.basename(source_key)}"
        s3.upload_file(local_path, PROCESSED_BUCKET, target_key)
        os.remove(local_path)

    return {"statusCode": 200}