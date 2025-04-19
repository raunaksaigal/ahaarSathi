import os
import argparse
import json
import numpy as np
from pathlib import Path
from PIL import Image
from ultralytics import YOLO
import cv2

# Dictionary mapping food names to nutritional information (calories per 100g)
# This is a simplified example - in a real app, use a more comprehensive database
NUTRITION_INFO = {
    "butter_chicken": {"calories": 280, "protein": 14, "carbs": 8, "fat": 22},
    "biryani": {"calories": 200, "protein": 7, "carbs": 30, "fat": 7},
    "gulab_jamun": {"calories": 320, "protein": 4, "carbs": 40, "fat": 15},
    "naan": {"calories": 260, "protein": 9, "carbs": 53, "fat": 3},
    "palak_paneer": {"calories": 180, "protein": 11, "carbs": 6, "fat": 14},
    "samosa": {"calories": 240, "protein": 4, "carbs": 24, "fat": 14},
    # Add more foods as needed
}

def load_model(model_path):
    """
    Load a trained YOLO model
    
    Args:
        model_path: Path to the trained model weights
        
    Returns:
        Loaded YOLO model
    """
    model = YOLO(model_path)
    return model

def preprocess_image(image_path):
    """
    Preprocess image for inference
    
    Args:
        image_path: Path to the image
        
    Returns:
        Preprocessed image
    """
    image = cv2.imread(image_path)
    if image is None:
        raise ValueError(f"Could not read image {image_path}")
    
    return image

def predict_food(model, image, conf_threshold=0.25):
    """
    Predict food class for an image
    
    Args:
        model: Trained YOLO model
        image: Input image (numpy array)
        conf_threshold: Confidence threshold for predictions
        
    Returns:
        Dictionary with prediction results
    """
    # Run inference
    results = model.predict(image, conf=conf_threshold)
    result = results[0]  # Get first result (only one image)
    
    # Process predictions
    predictions = []
    for i, prob in enumerate(result.probs.data):
        class_id = int(i)
        class_name = result.names[class_id]
        confidence = float(prob)
        
        # Get nutrition info if available
        nutrition = NUTRITION_INFO.get(class_name, {
            "calories": "unknown",
            "protein": "unknown",
            "carbs": "unknown",
            "fat": "unknown"
        })
        
        predictions.append({
            "class_id": class_id,
            "class_name": class_name,
            "confidence": confidence,
            "nutrition": nutrition
        })
    
    # Sort by confidence
    predictions.sort(key=lambda x: x["confidence"], reverse=True)
    
    return {
        "top_prediction": predictions[0] if predictions else None,
        "all_predictions": predictions
    }

def process_image_file(model, image_path, output_dir=None, save_json=False):
    """
    Process a single image file
    
    Args:
        model: Trained YOLO model
        image_path: Path to the image
        output_dir: Directory to save visualization results
        save_json: Whether to save results as JSON
        
    Returns:
        Dictionary with prediction results
    """
    print(f"Processing image: {image_path}")
    
    # Preprocess image
    image = preprocess_image(image_path)
    
    # Make prediction
    predictions = predict_food(model, image)
    
    # Display results
    top_pred = predictions["top_prediction"]
    if top_pred:
        print(f"Top prediction: {top_pred['class_name']} ({top_pred['confidence']:.2f})")
        print(f"Nutritional info (per 100g):")
        print(f"  Calories: {top_pred['nutrition']['calories']}")
        print(f"  Protein: {top_pred['nutrition']['protein']}g")
        print(f"  Carbs: {top_pred['nutrition']['carbs']}g")
        print(f"  Fat: {top_pred['nutrition']['fat']}g")
    else:
        print("No predictions found")
    
    # Save results if needed
    if save_json and output_dir:
        os.makedirs(output_dir, exist_ok=True)
        output_path = Path(output_dir) / f"{Path(image_path).stem}_result.json"
        with open(output_path, 'w') as f:
            json.dump(predictions, f, indent=2)
        print(f"Results saved to {output_path}")
    
    return predictions

def main():
    parser = argparse.ArgumentParser(description='Predict food class and nutrition')
    parser.add_argument('--model', type=str, required=True, help='Path to trained model')
    parser.add_argument('--image', type=str, required=True, help='Path to input image')
    parser.add_argument('--output-dir', type=str, default='../results', help='Output directory')
    parser.add_argument('--save-json', action='store_true', help='Save results as JSON')
    parser.add_argument('--conf-threshold', type=float, default=0.25, help='Confidence threshold')
    
    args = parser.parse_args()
    
    # Load model
    model = load_model(args.model)
    
    # Process image
    process_image_file(
        model=model, 
        image_path=args.image, 
        output_dir=args.output_dir,
        save_json=args.save_json
    )

if __name__ == "__main__":
    main() 