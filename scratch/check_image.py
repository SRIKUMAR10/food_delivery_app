import os

path = r"d:\Flutter_Project\food_delivery_app\assets\images\Delivery_scooter.png"
if os.path.exists(path):
    print("File exists, size:", os.path.getsize(path))
    with open(path, "rb") as f:
        header = f.read(16)
        print("Header bytes:", header)
else:
    print("File does not exist")
