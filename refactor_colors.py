import os
import re

directory = '/Users/fumilayo/tailorsync-v2/lib'
import_statement = "import 'package:needlix/core/theme/app_colors.dart';"

# Explicit mappings based on AppColors.dart
# We handle both the `const Color` and `Color` permutations to avoid invalid `const AppColors.primary` strings.
color_replacements = {
    "0xFF0076B6": "AppColors.primary",
    "0xFF00AEEF": "AppColors.primaryLight",
    "0xFF0A1128": "AppColors.secondary",
    
    # Legacy blue theme replacements
    "0xFF1E78D2": "AppColors.primary",
    "0xFF1565C0": "AppColors.primaryDark",
    "0xFF42A5F5": "AppColors.primaryLight",
    
    # Legacy orange theme replacements
    "0xFFF58220": "AppColors.warning",
    "0xFFFF8C42": "AppColors.warning",
    "0xFFE65100": "AppColors.warning",
    
    # Grey theme mappings
    "0xFF607D8B": "AppColors.textHintDark",
}

def process_file(filepath):
    # Don't refactor the app_colors.dart file itself!
    if 'app_colors.dart' in filepath:
        return

    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original_content = content
    modified = False

    for hex_code, app_color in color_replacements.items():
        # Replace `const Color(0xFF...)` -> `app_color`
        pattern_const = r"const\s+Color\(" + hex_code + r"\)"
        if re.search(pattern_const, content):
            content = re.sub(pattern_const, app_color, content)
            modified = True
            
        # Replace `Color(0xFF...)` -> `app_color`
        pattern_regular = r"Color\(" + hex_code + r"\)"
        if re.search(pattern_regular, content):
            content = re.sub(pattern_regular, app_color, content)
            modified = True

    if modified:
        # Check if the import statement exists
        if import_statement not in content:
            # find the last flutter/dart/package import to place it cleanly
            lines = content.split('\n')
            insert_idx = 0
            for i, line in enumerate(lines):
                if line.startswith('import '):
                    insert_idx = i + 1
            
            lines.insert(insert_idx, import_statement)
            content = '\n'.join(lines)
        
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Refactored: {filepath}")

for root, _, files in os.walk(directory):
    for file in files:
        if file.endswith('.dart'):
            filepath = os.path.join(root, file)
            process_file(filepath)

print("Refactoring complete.")
