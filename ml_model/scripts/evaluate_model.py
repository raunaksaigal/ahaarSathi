import os
import argparse
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from pathlib import Path
from sklearn.metrics import confusion_matrix, classification_report
from ultralytics import YOLO
import seaborn as sns

def evaluate_model(model_path, data_path, output_dir=None):
    """
    Evaluate a trained YOLOv8 classification model
    
    Args:
        model_path: Path to the trained model weights
        data_path: Path to the test data directory
        output_dir: Directory to save results
    """
    # Load model
    print(f"Loading model from {model_path}")
    model = YOLO(model_path)
    
    # Create output directory
    if output_dir is not None:
        os.makedirs(output_dir, exist_ok=True)
    
    # Get class names (directory names in the test folder)
    test_path = Path(data_path) / 'test'
    class_names = sorted([d.name for d in test_path.iterdir() if d.is_dir()])
    num_classes = len(class_names)
    
    print(f"Found {num_classes} classes in test dataset")
    
    # Run validation on test dataset
    print("Running validation on test dataset...")
    metrics = model.val(data=data_path)
    
    print("\nTest Results:")
    print(f"Top-1 Accuracy: {metrics.top1:.4f}")
    print(f"Top-5 Accuracy: {metrics.top5:.4f}")
    
    # Collect predictions for detailed analysis
    all_predictions = []
    true_labels = []
    
    # Process each class directory
    for class_idx, class_name in enumerate(class_names):
        class_dir = test_path / class_name
        print(f"Processing {class_name} test images ({len(list(class_dir.glob('*.jpg')))} images)")
        
        # Process each image in the class directory
        for img_path in class_dir.glob('*.jpg'):
            # Get prediction
            result = model.predict(str(img_path), verbose=False)[0]
            
            # Get the predicted class and its probability
            pred_class_idx = int(result.probs.top1)
            pred_class_name = result.names[pred_class_idx]
            confidence = float(result.probs.top1conf)
            
            # Store results
            all_predictions.append({
                'image': img_path.name,
                'true_class': class_name,
                'predicted_class': pred_class_name,
                'confidence': confidence,
                'correct': class_name == pred_class_name
            })
            
            # Store true label index
            true_labels.append(class_idx)
    
    # Convert to DataFrame
    results_df = pd.DataFrame(all_predictions)
    
    # Calculate accuracy
    accuracy = results_df['correct'].mean()
    print(f"\nDetailed Analysis:")
    print(f"Overall Accuracy: {accuracy:.4f}")
    
    # Class-wise accuracy
    class_accuracy = results_df.groupby('true_class')['correct'].mean().sort_values(ascending=False)
    print("\nTop 5 Classes with Highest Accuracy:")
    print(class_accuracy.head(5))
    
    print("\nBottom 5 Classes with Lowest Accuracy:")
    print(class_accuracy.tail(5))
    
    # Save results if output directory provided
    if output_dir is not None:
        # Save detailed results CSV
        results_df.to_csv(Path(output_dir) / 'detailed_results.csv', index=False)
        print(f"Saved detailed results to {Path(output_dir) / 'detailed_results.csv'}")
        
        # Plot class-wise accuracy
        plt.figure(figsize=(10, 8))
        class_accuracy.plot(kind='bar')
        plt.title('Accuracy by Food Class')
        plt.xlabel('Food Class')
        plt.ylabel('Accuracy')
        plt.tight_layout()
        plt.savefig(Path(output_dir) / 'class_accuracy.png')
        
        # Plot confusion matrix for most confused classes (top 20 classes)
        top_classes = class_accuracy.head(20).index.tolist()
        
        # Filter data for top classes
        filtered_df = results_df[results_df['true_class'].isin(top_classes)]
        
        # Create confusion matrix
        y_true = filtered_df['true_class']
        y_pred = filtered_df['predicted_class']
        
        cm = confusion_matrix(y_true, y_pred, labels=top_classes)
        
        plt.figure(figsize=(12, 10))
        sns.heatmap(cm, annot=True, fmt='d', cmap='Blues', xticklabels=top_classes, yticklabels=top_classes)
        plt.title('Confusion Matrix (Top 20 Classes)')
        plt.xlabel('Predicted Label')
        plt.ylabel('True Label')
        plt.tight_layout()
        plt.savefig(Path(output_dir) / 'confusion_matrix.png')
        
        print(f"Saved plots to {output_dir}")
    
    return metrics, results_df

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Evaluate trained food classifier')
    parser.add_argument('--model', type=str, required=True, help='Path to trained model weights')
    parser.add_argument('--data', type=str, default='D:/Stuff/hackathons/hack4bengal/food_classifier/data/food_dataset', 
                        help='Path to dataset directory')
    parser.add_argument('--output-dir', type=str, default='../results', help='Directory to save results')
    
    args = parser.parse_args()
    
    # Evaluate model
    evaluate_model(
        model_path=args.model,
        data_path=args.data,
        output_dir=args.output_dir
    ) 