import subprocess
result = subprocess.run(['flutter', 'analyze'], capture_output=True, text=True)
with open('analyze_output.txt', 'w') as f:
    f.write(result.stdout)
    f.write(result.stderr)
