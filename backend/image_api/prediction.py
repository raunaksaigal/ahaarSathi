# image_api/prediction.py

def predict_image_content(image_path):
    """
    A mock function that simulates image prediction.
    In a real application, this would use a ML model like TensorFlow or PyTorch.
    
    Args:
        image_path: Path to the uploaded image
        
    Returns:
        dict: Prediction result with class name and confidence
    """
    # Mock prediction - in a real app, replace with actual ML model prediction
    import random
    
    # Example prediction categories
    categories = [
        "cat", "dog", "car", "bicycle", "bird", 
        "flower", "tree", "building", "person", "landscape"
    ]
    
    # Simulate prediction by randomly selecting a category
    predicted_class = random.choice(categories)
    confidence = round(random.uniform(0.7, 0.99), 2)
    
    return {
        "class": predicted_class,
        "confidence": confidence
    }