import sys
from PIL import Image
import os

def process_image(input_path, output_path):
    print(f"Processing {input_path} -> {output_path}")
    if not os.path.exists(input_path):
        print(f"File not found: {input_path}")
        return
        
    img = Image.open(input_path).convert("RGBA")
    datas = img.getdata()
    
    new_data = []
    # Replace white-ish background with transparent, handling anti-aliasing
    for item in datas:
        # Distance from pure white
        r, g, b, a = item
        brightness = (r + g + b) / 3.0
        
        if brightness > 250:
            new_data.append((255, 255, 255, 0))
        elif brightness > 230:
            # Scale alpha based on how close to white it is
            alpha = int(255 * (250 - brightness) / 20.0)
            new_data.append((r, g, b, alpha))
        else:
            new_data.append(item)
            
    img.putdata(new_data)
    
    # Get bounding box of non-transparent pixels
    bbox = img.getbbox()
    if bbox:
        img = img.crop(bbox)
        
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    img.save(output_path, "PNG")

if __name__ == "__main__":
    assets = [
        (r"C:\Users\Administrator\.gemini\antigravity\brain\e739ecb6-7616-465f-bdb1-da3fae52d1f0\obstacle_barrier_1782658413799.png", r"D:\GODOT\test1\test\assets\objects\obstacle_barrier.png"),
        (r"C:\Users\Administrator\.gemini\antigravity\brain\e739ecb6-7616-465f-bdb1-da3fae52d1f0\obstacle_cone_1782658431485.png", r"D:\GODOT\test1\test\assets\objects\obstacle_cone.png"),
        (r"C:\Users\Administrator\.gemini\antigravity\brain\e739ecb6-7616-465f-bdb1-da3fae52d1f0\obstacle_crate_1782658454247.png", r"D:\GODOT\test1\test\assets\objects\obstacle_crate.png"),
        (r"C:\Users\Administrator\.gemini\antigravity\brain\e739ecb6-7616-465f-bdb1-da3fae52d1f0\obstacle_sign_1782658475081.png", r"D:\GODOT\test1\test\assets\objects\obstacle_sign.png")
    ]
    
    for input_p, output_p in assets:
        process_image(input_p, output_p)
    print("Done")
