import os
import argparse
from ultralytics import YOLO
from pathlib import Path

def train_yolo_classifier(
    data_yaml,
    model_size='s',
    epochs=50,
    batch_size=16,
    image_size=640,
    device='cpu',
    project='../models',
    name='food_classifier',
):
    """
    Train a YOLOv8 classification model on food images
    
    Args:
        data_yaml: Path to dataset YAML file
        model_size: YOLOv8 model size ('n', 's', 'm', 'l', 'x')
        epochs: Number of training epochs
        batch_size: Batch size
        image_size: Input image size
        device: Device to train on ('cuda:0', 'cpu')
        project: Directory to save results
        name: Name of the experiment
    """
    # Create the model - using classification model
    model = YOLO(f'yolov8{model_size}-cls.pt')
    
    # Train the model
    results = model.train(
        data=data_yaml,
        epochs=epochs,
        batch=batch_size,
        imgsz=image_size,
        device=device,
        project=project,
        name=name,
        verbose=True
    )
    
    # Save model
    model_dir = Path(project) / name
    print(f"Training complete. Model saved to {model_dir}")
    
    return model, model_dir

def validate_model(model, data_yaml):
    """
    Validate trained model on the validation set
    
    Args:
        model: Trained YOLO model
        data_yaml: Path to dataset YAML file
    """
    # Validate the model
    metrics = model.val(data=data_yaml)
    print(f"Validation results:")
    print(f"Accuracy: {metrics.top1}")
    print(f"Top-5 Accuracy: {metrics.top5}")
    
    return metrics

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Train YOLOv8 food classifier')
    parser.add_argument('--data', type=str, default='D:/Stuff/hackathons/hack4bengal/food_classifier/data/food_dataset', help='Path to dataset directory')
    parser.add_argument('--model-size', type=str, default='s', choices=['n', 's', 'm', 'l', 'x'], 
                        help='YOLOv8 model size')
    parser.add_argument('--epochs', type=int, default=50, help='Number of epochs to train')
    parser.add_argument('--batch-size', type=int, default=16, help='Batch size')
    parser.add_argument('--image-size', type=int, default=640, help='Image size')
    parser.add_argument('--device', type=str, default='cpu', help='Device to use (cpu or cuda device id)')
    parser.add_argument('--project', type=str, default='../models', help='Directory to save results')
    parser.add_argument('--name', type=str, default='food_classifier', help='Experiment name')
    
    args = parser.parse_args()
    
    # Train model
    trained_model, model_dir = train_yolo_classifier(
        data_yaml=args.data,
        model_size=args.model_size,
        epochs=args.epochs,
        batch_size=args.batch_size,
        image_size=args.image_size,
        device=args.device,
        project=args.project,
        name=args.name
    )
    
    # Validate model
    validate_model(trained_model, args.data) 