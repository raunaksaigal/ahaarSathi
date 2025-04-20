import os
import shutil
import random
from pathlib import Path

def create_data_splits(source_dir, dest_dir, train_ratio=0.7, val_ratio=0.15, test_ratio=0.15):
    """
    Split data into train, validation, and test sets and organize in YOLO format
    
    Args:
        source_dir: Path to source directory with food class folders
        dest_dir: Path to destination directory where data will be organized
        train_ratio: Ratio of data to use for training
        val_ratio: Ratio of data to use for validation
        test_ratio: Ratio of data to use for testing
    """
    # Ensure ratios sum to 1
    assert abs(train_ratio + val_ratio + test_ratio - 1.0) < 1e-5, "Ratios must sum to 1"
    
    # Create destination directories
    dest_path = Path(dest_dir)
    for split in ['train', 'val', 'test']:
        split_img_dir = dest_path / 'images' / split
        split_label_dir = dest_path / 'labels' / split
        
        os.makedirs(split_img_dir, exist_ok=True)
        os.makedirs(split_label_dir, exist_ok=True)
    
    # Create dataset.yaml
    class_names = []
    for class_dir in sorted(os.listdir(source_dir)):
        if os.path.isdir(os.path.join(source_dir, class_dir)):
            class_names.append(class_dir)
    
    with open(dest_path / 'dataset.yaml', 'w') as f:
        f.write(f"# YOLO dataset configuration\n")
        f.write(f"path: {os.path.abspath(dest_dir)}\n")
        f.write(f"train: images/train\n")
        f.write(f"val: images/val\n")
        f.write(f"test: images/test\n\n")
        f.write(f"# Classes\n")
        f.write(f"names:\n")
        for i, name in enumerate(class_names):
            f.write(f"  {i}: {name}\n")
        f.write(f"\n# Number of classes\n")
        f.write(f"nc: {len(class_names)}")
    
    # Process each class directory
    print(f"Processing {len(class_names)} classes...")
    for idx, class_name in enumerate(class_names):
        class_dir = os.path.join(source_dir, class_name)
        print(f"Processing class {idx+1}/{len(class_names)}: {class_name}")
        
        # Get all image files
        image_files = [f for f in os.listdir(class_dir) if f.endswith(('.jpg', '.jpeg', '.png'))]
        random.shuffle(image_files)
        
        # Calculate split sizes
        n_train = int(len(image_files) * train_ratio)
        n_val = int(len(image_files) * val_ratio)
        
        # Split data
        train_files = image_files[:n_train]
        val_files = image_files[n_train:n_train+n_val]
        test_files = image_files[n_train+n_val:]
        
        # Copy files and create YOLO format labels
        for split_name, files in zip(['train', 'val', 'test'], [train_files, val_files, test_files]):
            for file in files:
                # Copy image
                src_img = os.path.join(class_dir, file)
                dst_img = dest_path / 'images' / split_name / file
                shutil.copy(src_img, dst_img)
                
                # Create label file (YOLO format)
                # For classification, we just need class index
                # For object detection, we would need bounding box, but here we're just doing classification
                base_name = os.path.splitext(file)[0]
                label_path = dest_path / 'labels' / split_name / f"{base_name}.txt"
                
                # YOLO format for classification: just the class index
                with open(label_path, 'w') as f:
                    f.write(f"{idx}")
    
    print(f"Dataset preparation complete. Data organized at {dest_path}")
    print(f"Train: {n_train} images, Val: {n_val} images, Test: {len(image_files) - n_train - n_val} images")

if __name__ == "__main__":
    # Set random seed for reproducibility
    random.seed(42)
    
    # Set paths - using absolute paths instead of relative
    source_dir = "D:/Stuff/hackathons/hack4bengal/foodimages/indian_food_images"
    dest_dir = "D:/Stuff/hackathons/hack4bengal/food_classifier/data/food_dataset"
    
    # Create data splits
    create_data_splits(source_dir, dest_dir) 