import os

# 🔹 하위 탐색을 멈출 폴더 및 파일 리스트
LIMITED_ITEMS = [".git", "__pycache__"]

def generate_directory_structure(root_dir, output_file="output.txt"):
    """현재 디렉토리 구조를 트리 형태로 문서화하여 파일로 저장 (제한 폴더/파일 포함)"""
    
    def traverse(dir_path, prefix=""):
        """재귀적으로 디렉토리 구조 탐색 (LIMITED_ITEMS 내 포함되면 하위 탐색 중단)"""
        items = sorted(os.listdir(dir_path))
        tree_lines = []
        
        for index, item in enumerate(items):
            item_path = os.path.join(dir_path, item)
            is_last = index == len(items) - 1
            connector = "└── " if is_last else "├── "
            tree_lines.append(f"{prefix}{connector}{item}")

            # 만약 제한된 폴더/파일이면 하위 탐색 중단
            relative_path = os.path.relpath(item_path, root_dir).replace("\\", "/")  # 윈도우 경로 처리
            if relative_path in LIMITED_ITEMS:
                continue  # 하위 탐색 안 함

            if os.path.isdir(item_path):
                extension = "    " if is_last else "│   "
                tree_lines.extend(traverse(item_path, prefix + extension))

        return tree_lines
    
    # 트리 구조를 파일로 저장
    with open(output_file, "w", encoding="utf-8") as f:
        f.write(root_dir + "\n")
        f.writelines("\n".join(traverse(root_dir)))

    print(f"디렉토리 구조가 '{output_file}' 파일에 저장되었습니다.")

# 실행 예시
generate_directory_structure(".")
