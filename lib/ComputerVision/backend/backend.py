from flask import Flask, request, jsonify
import boto3
import os
from botocore.exceptions import ClientError
import logging
from flask_cors import CORS

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

aws_access_key = "AKIA6G75DYEK3NWC2AXH"
aws_secret_key = "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"
region_name = "us-east-1"

try:
    rekognition = boto3.client(
        "rekognition",
        aws_access_key_id=aws_access_key,
        aws_secret_access_key=aws_secret_key,
        region_name=region_name
    )
    logger.info("Rekognition client initialized successfully.")
except Exception as e:
    logger.error(f"Error initializing Rekognition client: {e}")
    rekognition = None

KNOWN_LANDMARKS = {
    "Pyramid": "أهرامات الجيزة",
    "Eiffel Tower": "برج إيفل",
    "Statue of Liberty": "تمثال الحرية",
    "Great Wall": "سور الصين العظيم",
    "Colosseum": "الكولوسيوم",
    "Taj Mahal": "تاج محل",
    "Machu Picchu": "ماتشو بيتشو",
    "Christ the Redeemer": "تمثال المسيح الفادي",
    "Big Ben": "ساعة بيج بن",
    "Leaning Tower of Pisa": "برج بيزا المائل",
    "Sydney Opera House": "دار أوبرا سيدني",
    "Mount Rushmore": "جبل راشمور",
    "Burj Khalifa": "برج خليفة",
}

@app.route("/recognize", methods=["POST"])
def recognize_landmark():
    if rekognition is None:
        return jsonify({"error": "Rekognition client not initialized"}), 500

    if "image" not in request.files:
        return jsonify({"error": "No image provided"}), 400

    try:
        image = request.files["image"]
        image_path = os.path.join(os.getcwd(), "temp_image.jpg")
        image.save(image_path)
        logger.info(f"Image saved to {image_path}")

        with open(image_path, "rb") as image_file:
            response = rekognition.detect_labels(
                Image={"Bytes": image_file.read()},
                MaxLabels=10
            )

        os.remove(image_path)
        logger.info(f"Image {image_path} removed")

        best_match = None
        for label in response.get("Labels", []):
            if label["Name"] in KNOWN_LANDMARKS:
                logger.info(f"Matched landmark: {label['Name']}")
                return jsonify({"landmark": KNOWN_LANDMARKS[label["Name"]]})
            if best_match is None or label["Confidence"] > best_match[1]:
                best_match = (label["Name"], label["Confidence"])

        result = best_match[0] if best_match else None
        logger.info(f"Best match: {result}")
        return jsonify({"landmark": result})

    except ClientError as e:
        logger.error(f"AWS error: {str(e)}")
        return jsonify({"error": f"AWS error: {str(e)}"}), 500
    except Exception as e:
        logger.error(f"Server error: {str(e)}")
        return jsonify({"error": f"Server error: {str(e)}"}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5001, debug=True)