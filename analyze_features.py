import os
import json

def get_feature_details(base_path):
    features = {}
    if not os.path.exists(base_path):
        return features
    for entry in os.listdir(base_path):
        full_path = os.path.join(base_path, entry)
        if os.path.isdir(full_path):
            files = []
            for root, dirs, filenames in os.walk(full_path):
                for f in filenames:
                    files.append(f)
            features[entry] = files
    return features

buyer_path = r"d:\Flutter_Project\food_delivery_app\lib\features\buyer_bloc_architecture"
seller_path = r"d:\Flutter_Project\food_delivery_app\lib\features\seller_bloc_architecture"

buyer_features = get_feature_details(buyer_path)
seller_features = get_feature_details(seller_path)

print("=== Buyer Features ===")
for f, files in buyer_features.items():
    print(f"{f}: {len(files)} files")
    
print("\n=== Seller Features ===")
for f, files in seller_features.items():
    bloc_files = [x for x in files if 'bloc' in x.lower() or 'event' in x.lower() or 'state' in x.lower()]
    ui_files = [x for x in files if 'ui' in x.lower() or 'screen' in x.lower() or 'page' in x.lower()]
    print(f"{f}: {len(files)} files (BLoC: {len(bloc_files)}, UI: {len(ui_files)})")
