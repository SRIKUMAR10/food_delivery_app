import json
import base64

manifest_path = r"d:\Flutter_Project\food_delivery_app\build\web\assets\AssetManifest.bin.json"

with open(manifest_path, 'r') as f:
    encoded_str = f.read().strip().strip('"') # remove surrounding quotes
    
decoded_bytes = base64.b64decode(encoded_str)
print("Decoded content length:", len(decoded_bytes))

# Search for the video filename or "videos"
decoded_text = ""
for b in decoded_bytes:
    if 32 <= b <= 126:
        decoded_text += chr(b)
    else:
        decoded_text += "."

print("\nSearching for 'delivery_scooter' in decoded text:")
print("delivery_scooter" in decoded_text)

print("\nSearching for 'videos' in decoded text:")
print("videos" in decoded_text)

print("\nFirst 1000 chars of decoded text:")
print(decoded_text[:1000])
