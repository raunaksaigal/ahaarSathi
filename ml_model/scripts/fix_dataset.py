import os
import shutil
from pathlib import Path

def restructure_dataset_for_yolo_classification(source_dir):
    """
    Restructure dataset to match YOLOv8 classification format
    
    YOLOv8 classification requires:
    dataset/
    ├── train/
    │   ├── class1/
    │   │   ├── img1.jpg
    │   │   └── img2.jpg
    │   └── class2/
    │       ├── img3.jpg
    │       └── img4.jpg
    ├── val/
    │   ├── class1/
    │   │   ├── img5.jpg
    │   │   └── img6.jpg
    │   └── class2/
    │       ├── img7.jpg
    │       └── img8.jpg
    """
    source_path = Path(source_dir)
    
    # Get all class names from the YAML file
    class_names = []
    with open(source_path / 'dataset.yaml', 'r') as f:
        for line in f:
            if ':' in line and 'path:' not in line and 'train:' not in line and 'val:' not in line and 'test:' not in line and 'nc:' not in line:
                # Extract class name from format like "  0: class_name"
                parts = line.strip().split(':')
                if len(parts) == 2 and parts[0].strip().isdigit():
                    class_names.append(parts[1].strip())
    
    print(f"Found {len(class_names)} classes")
    
    # Create directory structure for classification
    for split in ['train', 'val', 'test']:
        for class_name in class_names:
            class_dir = source_path / split / class_name
            os.makedirs(class_dir, exist_ok=True)
    
    # Move images to class directories
    for split in ['train', 'val', 'test']:
        source_img_dir = source_path / 'images' / split
        source_label_dir = source_path / 'labels' / split
        
        if not source_img_dir.exists():
            print(f"Directory {source_img_dir} does not exist. Skipping.")
            continue
            
        # Process all images in the split
        for img_file in os.listdir(source_img_dir):
            if not img_file.endswith(('.jpg', '.jpeg', '.png')):
                continue
                
            # Get the corresponding label file
            base_name = os.path.splitext(img_file)[0]
            label_file = f"{base_name}.txt"
            label_path = source_label_dir / label_file
            
            if not label_path.exists():
                print(f"Warning: No label found for {img_file}. Skipping.")
                continue
                
            # Read the class index from the label file
            with open(label_path, 'r') as f:
                class_idx = int(f.read().strip())
                
            if 0 <= class_idx < len(class_names):
                class_name = class_names[class_idx]
                
                # Move the image to the class directory
                source_img_path = source_img_dir / img_file
                target_img_path = source_path / split / class_name / img_file
                
                # Copy the image
                shutil.copy(source_img_path, target_img_path)
                print(f"Copied {img_file} to {split}/{class_name}/")
            else:
                print(f"Warning: Invalid class index {class_idx} for {img_file}. Skipping.")
    
    print(f"Dataset restructuring complete. Structure is now in YOLOv8 classification format.")

if __name__ == "__main__":
    # Set paths
    dataset_dir = "D:/Stuff/hackathons/hack4bengal/food_classifier/data/food_dataset"
    
    # Restructure dataset
    restructure_dataset_for_yolo_classification(dataset_dir) 