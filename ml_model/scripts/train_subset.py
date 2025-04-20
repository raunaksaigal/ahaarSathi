import os
import argparse
from ultralytics import YOLO
from pathlib import Path

def train_yolo_classifier_subset(
    data_path,
    model_size='n',  # Smaller model for faster training
    epochs=10,       # Fewer epochs
    batch_size=8,    # Smaller batch size
    image_size=320,  # Smaller image size
    device='cpu',
    project='../models',
    name='food_classifier_subset',
):
    """
    Train a YOLOv8 classification model on a small subset of food images
    
    Args:
        data_path: Path to dataset directory
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
        data=data_path,
        epochs=epochs,
        batch=batch_size,
        imgsz=image_size,
        device=device,
        project=project,
        name=name,
        verbose=True,
        patience=5  # Early stopping with fewer patience
    )
    
    # Save model
    model_dir = Path(project) / name
    print(f"Training complete. Model saved to {model_dir}")
    
    return model, model_dir

def validate_model(model, data_path):
    """
    Validate trained model on the validation set
    
    Args:
        model: Trained YOLO model
        data_path: Path to dataset directory
    """
    # Validate the model
    metrics = model.val(data=data_path)
    print(f"Validation results:")
    print(f"Accuracy: {metrics.top1}")
    print(f"Top-5 Accuracy: {metrics.top5}")
    
    return metrics

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Train YOLOv8 food classifier on subset')
    parser.add_argument('--data', type=str, default='D:/Stuff/hackathons/hack4bengal/food_classifier/data/food_dataset_subset', 
                        help='Path to dataset directory')
    parser.add_argument('--model-size', type=str, default='n', choices=['n', 's', 'm', 'l', 'x'], 
                        help='YOLOv8 model size (n=smallest/fastest)')
    parser.add_argument('--epochs', type=int, default=10, help='Number of epochs to train')
    parser.add_argument('--batch-size', type=int, default=8, help='Batch size')
    parser.add_argument('--image-size', type=int, default=320, help='Image size')
    parser.add_argument('--device', type=str, default='cpu', help='Device to use (cpu or cuda device id)')
    parser.add_argument('--project', type=str, default='../models', help='Directory to save results')
    parser.add_argument('--name', type=str, default='food_classifier_subset', help='Experiment name')
    
    args = parser.parse_args()
    
    # Create dataset subset if not exists
    if not os.path.exists(args.data):
        import create_subset
        print(f"Creating dataset subset at {args.data}...")
        create_subset.create_dataset_subset(
            source_dir='D:/Stuff/hackathons/hack4bengal/food_classifier/data/food_dataset',
            dest_dir=args.data,
            images_per_class=5,
            min_classes=20
        )
    
    # Train model
    trained_model, model_dir = train_yolo_classifier_subset(
        data_path=args.data,
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