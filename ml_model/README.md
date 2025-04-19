# Food Calorie Tracker with ML Classification

This project implements a food classification system using YOLOv8 to identify Indian food items and provide nutritional information. The system can be integrated into a calorie tracking application.

## Project Structure

```
food_classifier/
│
├── data/                   # Directory for processed dataset
│   └── food_dataset/       # Contains dataset in YOLOv8 classification format
│       ├── train/          # Training data with class subdirectories 
│       ├── val/            # Validation data with class subdirectories
│       └── test/           # Test data with class subdirectories
│
├── models/                 # Trained models will be saved here
│
├── scripts/                # Python scripts
│   ├── prepare_data.py     # Script for preparing dataset
│   ├── fix_dataset.py      # Script to restructure data for YOLOv8 classification
│   ├── train_model.py      # Script for training YOLOv8 model
│   ├── evaluate_model.py   # Script for evaluating model performance
│   └── predict.py          # Script for making predictions
│
└── requirements.txt        # Python dependencies
```

## Dataset Structure for YOLOv8 Classification

YOLOv8 classification requires a specific dataset structure:

```
dataset/
├── train/
│   ├── class1/
│   │   ├── image1.jpg
│   │   └── image2.jpg
│   └── class2/
│       ├── image3.jpg
│       └── image4.jpg
├── val/
│   ├── class1/
│   │   ├── image5.jpg
│   │   └── image6.jpg
│   └── class2/
│       ├── image7.jpg
│       └── image8.jpg
└── test/  (optional)
    ├── class1/
    │   ├── image9.jpg
    │   └── image10.jpg
    └── class2/
        ├── image11.jpg
        └── image12.jpg
```

## Setup and Installation

1. Install the required dependencies:

```bash
pip install -r requirements.txt
```

2. Prepare the dataset:

```bash
cd scripts
python prepare_data.py
python fix_dataset.py
```

This will organize the images into train/validation/test splits in the format required by YOLOv8 for classification.

## Training the Model

To train the YOLOv8 model on the food dataset:

```bash
cd scripts
python train_model.py --epochs 50 --batch-size 16 --model-size s --device cpu
```

Options:
- `--epochs`: Number of training epochs
- `--batch-size`: Batch size
- `--model-size`: YOLOv8 model size ('n', 's', 'm', 'l', 'x')
- `--device`: Device to use (cpu or cuda device id)
- `--image-size`: Input image size

## Evaluating the Model

After training, evaluate the model's performance:

```bash
cd scripts
python evaluate_model.py --model ../models/food_classifier/weights/best.pt
```

This will generate accuracy metrics and visualizations to help analyze model performance.

## Making Predictions

To classify a food image and get nutritional information:

```bash
cd scripts
python predict.py --model ../models/food_classifier/weights/best.pt --image path/to/your/food/image.jpg
```

Options:
- `--model`: Path to trained model weights
- `--image`: Path to input image
- `--conf-threshold`: Confidence threshold for predictions
- `--save-json`: Save results as JSON
- `--output-dir`: Directory to save results

## Dataset

The project uses a dataset containing 4,000+ images of Indian food items across 80+ classes. The classes include various dishes like butter chicken, biryani, gulab jamun, etc.

## Model Architecture

The system uses YOLOv8, a state-of-the-art object detection and classification model. For this project, YOLOv8 is used in classification mode.

## Nutritional Database

A simplified nutritional database is included in the code. For a production system, it's recommended to use a more comprehensive database or API.

## Troubleshooting

If you encounter a "dataset not found" error, ensure your dataset follows the structure required by YOLOv8 for classification (see Dataset Structure section). The `fix_dataset.py` script restructures the data into the correct format.

## Future Work

1. Expand the nutritional database with more accurate information
2. Implement portion size estimation
3. Create a mobile app frontend with camera integration
4. Add support for more cuisines and food types 