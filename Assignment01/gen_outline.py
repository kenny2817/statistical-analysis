import json
from pathlib import Path

def markdown_outline(lines):
    outline = []
    stack = []

    for line in lines:
        if line.startswith("#"):
            level = len(line) - len(line.lstrip("#"))
            
            # Ignore headings deeper than level 2
            if level > 2:
                continue
                
            title = line.strip("# ").strip()

            node = {"title": title, "children": []}

            while stack and stack[-1][0] >= level:
                stack.pop()

            if stack:
                stack[-1][1]["children"].append(node)
            else:
                outline.append(node)

            stack.append((level, node))

    return outline

def generate_combined_outline(base_dir="."):
    combined_outline = []
    
    # Iterate through README.md files in folders that match Q1, Q2, etc.
    for readme_path in sorted(Path(base_dir).glob('Q*/README.md')):
        with open(readme_path, 'r', encoding='utf-8') as f:
            lines = f.readlines()
            
        file_outline = markdown_outline(lines)
        
        # Directly append the file's outline without the folder name wrapper
        combined_outline.extend(file_outline)
        
    return combined_outline

def outline_to_markdown(outline_nodes, depth=0):
    lines = []
    indent = "  " * depth
    for node in outline_nodes:
        lines.append(f"{indent}- {node['title']}")
        if node["children"]:
            lines.extend(outline_to_markdown(node["children"], depth + 1))
    return lines

if __name__ == "__main__":
    final_outline = generate_combined_outline()
    
    # Generate Markdown text
    md_lines = ["# Assignment Outline\n"]
    md_lines.extend(outline_to_markdown(final_outline))
    
    # Write to an outline.md file
    out_path = Path("outline.md")
    out_path.write_text("\n".join(md_lines), encoding="utf-8")
    
    print(f"Outline saved to {out_path.absolute()}")