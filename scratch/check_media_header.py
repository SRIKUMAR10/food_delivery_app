import sys

path = r"C:\Users\DELL\.gemini\antigravity-ide\brain\01fbfaa2-e2e8-46de-82de-078a84094517\uploaded_media_1785527936609.img"
try:
    with open(path, "rb") as f:
        head = f.read(128)
        print("Header:", head)
        print("Length:", len(head))
except Exception as e:
    print("Error:", e)
