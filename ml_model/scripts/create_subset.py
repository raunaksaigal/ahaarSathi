import os
import random
import shutil
from pathlib import Path
import argparse

def create_dataset_subset(source_dir, dest_dir, images_per_class=5, min_classes=None, seed=42):
    """
    Create a smaller subset of the dataset for faster experimentation
    
    Args:
        source_dir: Path to original dataset with train/val/test folders
        dest_dir: Path to destination directory for subset
        images_per_class: Number of images to sample per class for training
        min_classes: Minimum number of classes to include (None = all classes)
        seed: Random seed for reproducibility
    """
    random.seed(seed)
    source_path = Path(source_dir)
    dest_path = Path(dest_dir)
    
    # Create destination directory structure
    os.makedirs(dest_path, exist_ok=True)
    
    # Create train, val, test directories
    for split in ['train', 'val', 'test']:
        os.makedirs(dest_path / split, exist_ok=True)
    
    # Get all available classes
    all_classes = []
    
    for class_dir in (source_path / 'train').iterdir():
        if class_dir.is_dir():
            all_classes.append(class_dir.name)
    
    # If min_classes is specified, randomly select classes
    if min_classes and min_classes < len(all_classes):
        selected_classes = random.sample(all_classes, min_classes)
    else:
        selected_classes = all_classes
    
    print(f"Creating subset with {len(selected_classes)} classes, {images_per_class} images per class")
    
    # For each class, copy a subset of images
    for class_name in selected_classes:
        print(f"Processing class: {class_name}")
        
        # Create class directories in each split
        for split in ['train', 'val', 'test']:
            os.makedirs(dest_path / split / class_name, exist_ok=True)
        
        # For each split, copy a subset of images
        for split in ['train', 'val', 'test']:
            source_class_dir = source_path / split / class_name
            dest_class_dir = dest_path / split / class_name
            
            # Skip if source directory doesn't exist
            if not source_class_dir.exists():
                print(f"Warning: {source_class_dir} doesn't exist, skipping.")
                continue
            
            # Get all images in this class
            images = list(source_class_dir.glob('*.jpg')) + \
                     list(source_class_dir.glob('*.jpeg')) + \
                     list(source_class_dir.glob('*.png'))
            
            # Determine number of images to copy
            # Use fewer images for val/test splits
            if split == 'train':
                num_images = min(images_per_class, len(images))
            elif split == 'val':
                num_images = min(max(1, images_per_class // 5), len(images))
            else:  # test
                num_images = min(max(1, images_per_class // 5), len(images))
                
            # Randomly select images
            selected_images = random.sample(images, num_images) if num_images < len(images) else images
            
            # Copy images
            for img_path in selected_images:
                shutil.copy(img_path, dest_class_dir / img_path.name)
                
            print(f"  {split}: Copied {len(selected_images)} images to {dest_class_dir}")
    
    total_images = sum(len(list((dest_path / split).glob('**/*.jpg'))) for split in ['train', 'val', 'test'])
    print(f"Subset creation complete. Total images: {total_images}")
    print(f"Dataset subset created at: {dest_path}")
    
    return dest_path

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Create a smaller subset of the dataset for faster training')
    parser.add_argument('--source', type=str, 
                        default='D:/Stuff/hackathons/hack4bengal/food_classifier/data/food_dataset',
                        help='Path to original dataset directory')
    parser.add_argument('--dest', type=str, 
                        default='D:/Stuff/hackathons/hack4bengal/food_classifier/data/food_dataset_subset',
                        help='Path to destination directory for subset')
    parser.add_argument('--images-per-class', type=int, default=5, 
                        help='Number of images to include per class for training')
    parser.add_argument('--min-classes', type=int, default=20, 
                        help='Minimum number of classes to include (default=20, 0=all classes)')
    parser.add_argument('--seed', type=int, default=42, help='Random seed for reproducibility')
    
    args = parser.parse_args()
    
    # Adjust min_classes if it's 0 (use all classes)
    min_classes = None if args.min_classes == 0 else args.min_classes
    
    # Create subset
    create_dataset_subset(
        source_dir=args.source,
        dest_dir=args.dest,
        images_per_class=args.images_per_class,
        min_classes=min_classes,
        seed=args.seed
    ) 