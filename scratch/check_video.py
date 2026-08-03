import os

video_path = r"d:\Flutter_Project\food_delivery_app\assets\videos\delivery_scooter.mp4"

print(f"File exists: {os.path.exists(video_path)}")
if os.path.exists(video_path):
    size = os.path.getsize(video_path)
    print(f"File size: {size} bytes")
    
    with open(video_path, 'rb') as f:
        header = f.read(512)
        print("First 512 bytes (hex):")
        print(header.hex())
        
        # Look for standard MP4 brands
        print("\nAscii representations in first 512 bytes:")
        ascii_chars = "".join(chr(b) if 32 <= b <= 126 else "." for b in header)
        print(ascii_chars)
else:
    print("Video file not found!")
