import sys

def check_balance(filename):
    with open(filename, 'r', encoding='utf-8') as f:
        lines = f.readlines()
        
    stack = []
    pairs = {')': '(', '}': '{', ']': '['}
    
    with open('check_result.txt', 'w', encoding='utf-8') as out:
        for line_num, line in enumerate(lines, 1):
            for char_pos, char in enumerate(line, 1):
                if char in '({[':
                    stack.append((char, line_num, char_pos))
                elif char in ')}]':
                    if not stack:
                        out.write(f"Error: Unmatched closing '{char}' at line {line_num}, col {char_pos}\n")
                        return
                    top, top_line, top_col = stack.pop()
                    if top != pairs[char]:
                        out.write(f"Error: Mismatched closing '{char}' at line {line_num}, col {char_pos}. Expected to close '{top}' from line {top_line}\n")
                        return
                        
        if stack:
            out.write("Error: Unclosed brackets:\n")
            for bracket, line, col in stack:
                out.write(f"  '{bracket}' at line {line}, col {col}\n")
        else:
            out.write("All brackets are balanced!\n")

if __name__ == "__main__":
    check_balance(r"d:\Flutter_Project\food_delivery_app\lib\features\seller_bloc_architecture\seller_dashboard_page\seller_dashboard_page_ui.dart")
