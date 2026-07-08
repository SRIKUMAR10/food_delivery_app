import os
import re
import json

def analyze_project(root_dir):
    data = {
        'tree': [],
        'screens': [],
        'imports': set()
    }
    
    # Generate tree
    def get_tree(dir_path, prefix=""):
        tree_lines = []
        try:
            items = sorted(os.listdir(dir_path))
        except:
            return tree_lines
        for i, item in enumerate(items):
            if item.startswith('.'):
                continue
            path = os.path.join(dir_path, item)
            is_last = (i == len(items) - 1)
            connector = "└── " if is_last else "├── "
            tree_lines.append(f"{prefix}{connector}{item}")
            if os.path.isdir(path):
                extension = "    " if is_last else "│   "
                tree_lines.extend(get_tree(path, prefix + extension))
        return tree_lines
    
    data['tree'] = get_tree(root_dir)
    
    # Analyze files
    for root, dirs, files in os.walk(root_dir):
        for file in files:
            if not file.endswith('.dart'):
                continue
                
            file_path = os.path.join(root, file)
            rel_path = os.path.relpath(file_path, root_dir)
            
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = f.read()
            except:
                continue
                
            # Check if it's a UI screen
            is_screen = ('StatelessWidget' in content or 'StatefulWidget' in content) and 'Widget build' in content
            
            if is_screen or 'bloc_architecture' in rel_path:
                class_names = re.findall(r'class\s+([A-Za-z0-9_]+)\s+extends', content)
                imports = re.findall(r"import\s+['\"]([^'\"]+)['\"]", content)
                
                nav_push = re.findall(r'Navigator\.(push[A-Za-z0-9_]*)\s*\(', content)
                nav_pop = 'Navigator.pop' in content
                
                targets = re.findall(r'builder:\s*\(\s*(?:context|ctx|_)\s*\)\s*=>\s*([A-Za-z0-9_]+)\s*\(', content)
                
                # Check for bloc, repo, api, data collection
                blocs = set([imp for imp in imports if 'bloc' in imp.lower() or 'cubit' in imp.lower()])
                repos = set([imp for imp in imports if 'repository' in imp.lower() or 'repo' in imp.lower()])
                apis = set([imp for imp in imports if 'api' in imp.lower() or 'service' in imp.lower()])
                data_col = set([imp for imp in imports if 'data' in imp.lower() or 'collection' in imp.lower() or 'model' in imp.lower()])
                
                data['screens'].append({
                    'file': rel_path,
                    'classes': class_names,
                    'is_screen': is_screen,
                    'nav_out': list(set(targets)),
                    'nav_push_methods': list(set(nav_push)),
                    'nav_pop': nav_pop,
                    'blocs': list(blocs),
                    'repos': list(repos),
                    'apis': list(apis),
                    'data_collections': list(data_col),
                    'raw_imports': imports
                })

    with open('analysis.json', 'w') as f:
        json.dump(data, f, indent=2)

analyze_project('d:/Flutter_Project/food_delivery_app/lib')
