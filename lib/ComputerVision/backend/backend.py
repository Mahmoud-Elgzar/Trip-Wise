from flask import Flask, request, jsonify, send_file
import boto3
import os
from botocore.exceptions import ClientError
import logging
from flask_cors import CORS
import wikipedia
from gtts import gTTS
from PIL import Image, ImageEnhance
import uuid

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})

# AWS credentials (replace with secure method in production)
aws_access_key = os.getenv("AWS_ACCESS_KEY_ID", "")
aws_secret_key = os.getenv("AWS_SECRET_ACCESS_KEY", "")
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

# Known landmarks for recognition
KNOWN_LANDMARKS = {
    "Pyramid": "Giza Pyramids",
    "Eiffel Tower": "Eiffel Tower",
    "Statue of Liberty": "Statue of Liberty",
    "Great Wall": "Great Wall of China",
    "Colosseum": "Colosseum",
    "Taj Mahal": "Taj Mahal",
    "Machu Picchu": "Machu Picchu",
    "Christ the Redeemer": "Christ the Redeemer",
    "Big Ben": "Big Ben",
    "Leaning Tower of Pisa": "Leaning Tower of Pisa",
    "Sydney Opera House": "Sydney Opera House",
    "Mount Rushmore": "Mount Rushmore",
    "Burj Khalifa": "Burj Khalifa"
}

# Enhance and resize image
def enhance_image(image):
    logger.info("Enhancing image")
    enhancer = ImageEnhance.Contrast(image)
    image = enhancer.enhance(1.5)
    enhancer = ImageEnhance.Sharpness(image)
    image = enhancer.enhance(2.0)
    # Resize to 640x360 while maintaining aspect ratio
    image.thumbnail((640, 360), Image.Resampling.LANCZOS)
    return image

# Detect landmark using AWS Rekognition
def detect_landmark(image_path):
    logger.info("Detecting landmark from image: %s", image_path)
    with open(image_path, "rb") as image_file:
        response = rekognition.detect_labels(Image={"Bytes": image_file.read()}, MaxLabels=10)

    best_match = None
    for label in response.get("Labels", []):
        logger.info(f"Label: {label['Name']}, Confidence: {label['Confidence']:.2f}%")
        if label["Name"] in KNOWN_LANDMARKS:
            return KNOWN_LANDMARKS[label["Name"]]
        if best_match is None or label["Confidence"] > best_match[1]:
            best_match = (label["Name"], label["Confidence"])

    return best_match[0] if best_match else None

# Fetch Wikipedia information
def get_wikipedia_info(object_name, lang="en"):
    logger.info("Fetching Wikipedia info for: %s, language: %s", object_name, lang)
    try:
        wikipedia.set_lang(lang)
        results = wikipedia.search(object_name)
        if not results:
            return "No results found on Wikipedia."
        page = wikipedia.page(results[0])
        return page.summary[:600]
    except Exception as e:
        logger.error(f"Error fetching Wikipedia info: {e}")
        return f"Error fetching Wikipedia info: {e}"

# Convert text to speech
def text_to_speech(text, lang="en"):
    logger.info("Generating audio for text in language: %s", lang)
    try:
        tts = gTTS(text=text, lang=lang)
        audio_path = f"temp_audio_{uuid.uuid4()}.mp3"
        tts.save(audio_path)
        logger.info("Audio saved: %s", audio_path)
        return audio_path
    except Exception as e:
        logger.error(f"Error generating audio: {e}")
        return None

@app.route("/recognize", methods=["POST"])
def recognize_landmark():
    logger.info("Received request to /recognize")
    if rekognition is None:
        logger.error("Rekognition client not initialized")
        return jsonify({"error": "Rekognition client not initialized"}), 500

    if "image" not in request.files or "language" not in request.form:
        logger.error("Missing image or language")
        return jsonify({"error": "Image and language are required"}), 400

    image_path = None
    audio_path = None
    try:
        # Save and enhance image
        image = request.files["image"]
        lang = request.form["language"]
        image_path = f"temp_image_{uuid.uuid4()}.jpg"
        image.save(image_path)
        with Image.open(image_path) as img:
            img = enhance_image(img)
            img.save(image_path)
        logger.info(f"Image saved and enhanced: {image_path}")

        # Detect landmark
        landmark_name = detect_landmark(image_path)
        logger.info("Landmark detected: %s", landmark_name)
        if not landmark_name:
            os.remove(image_path)
            logger.error("No landmark recognized")
            return jsonify({"error": "No landmark recognized"}), 400

        # Fetch Wikipedia info
        wiki_info = get_wikipedia_info(landmark_name, lang)
        logger.info("Wikipedia info fetched")
        if "error" in wiki_info.lower():
            os.remove(image_path)
            logger.error("Wikipedia info error: %s", wiki_info)
            return jsonify({"error": wiki_info}), 500

        # Generate audio
        audio_path = text_to_speech(wiki_info, lang)
        logger.info("Audio generated: %s", audio_path)
        if not audio_path:
            os.remove(image_path)
            logger.error("Failed to generate audio")
            return jsonify({"error": "Failed to generate audio"}), 500

        # Prepare response
        response = {
            "landmark": landmark_name,
            "information": wiki_info,
            "image_url": f"/image/{os.path.basename(image_path)}",
            "audio_url": f"/audio/{os.path.basename(audio_path)}"
        }

        logger.info("Response prepared: %s", response)
        return jsonify(response)

    except ClientError as e:
        logger.error(f"AWS error: {str(e)}")
        return jsonify({"error": f"AWS error: {str(e)}"}), 500
    except Exception as e:
        logger.error(f"Server error: {str(e)}")
        return jsonify({"error": f"Server error: {str(e)}"}), 500
    finally:
        # Defer cleanup to serving endpoints
        pass

@app.route("/image/<filename>", methods=["GET"])
def serve_image(filename):
    logger.info("Serving image: %s", filename)
    image_path = os.path.join(os.getcwd(), filename)
    if not os.path.exists(image_path):
        logger.error("Image not found: %s", image_path)
        return jsonify({"error": "Image not found"}), 404
    try:
        response = send_file(image_path, mimetype="image/jpeg")
        # Delete file after sending
        try:
            os.remove(image_path)
            logger.info("Image deleted: %s", image_path)
        except Exception as e:
            logger.warning(f"Failed to delete image {image_path}: {e}")
        return response
    except Exception as e:
        logger.error(f"Error serving image: {str(e)}")
        return jsonify({"error": f"Error serving image: {str(e)}"}), 500

@app.route("/audio/<filename>", methods=["GET"])
def serve_audio(filename):
    logger.info("Serving audio: %s", filename)
    audio_path = os.path.join(os.getcwd(), filename)
    if not os.path.exists(audio_path):
        logger.error("Audio not found: %s", audio_path)
        return jsonify({"error": "Audio not found"}), 404
    try:
        response = send_file(audio_path, mimetype="audio/mpeg")
        # Delete file after sending
        try:
            os.remove(audio_path)
            logger.info("Audio deleted: %s", audio_path)
        except Exception as e:
            logger.warning(f"Failed to delete audio {audio_path}: {e}")
        return response
    except Exception as e:
        logger.error(f"Error serving audio: {str(e)}")
        return jsonify({"error": f"Error serving audio: {str(e)}"}), 500

if __name__ == "__main__":
    logger.info("Starting Flask server on port 5001")
    app.run(host="0.0.0.0", port=5001, debug=True)