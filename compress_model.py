import joblib
import os

# Get original size
original_size = os.path.getsize('backend/models/final_best_model.pkl')
print(f"Original size: {original_size / (1024**3):.2f} GB")

# Load the model
print("Loading model...")
model = joblib.load('backend/models/final_best_model.pkl')

# Save with maximum compression
print("Compressing with compression level 9...")
joblib.dump(model, 'backend/models/final_best_model_compressed.pkl', compress=9)

# Check new size
new_size = os.path.getsize('backend/models/final_best_model_compressed.pkl')
print(f"Compressed size: {new_size / (1024**3):.2f} GB")
print(f"Compression ratio: {(1 - new_size/original_size) * 100:.1f}%")

# Verify it loads
print("Verifying compressed model loads...")
test_model = joblib.load('backend/models/final_best_model_compressed.pkl')
print("✅ Compression successful!")