import os

if __name__ == '__main__':
    txt_files = sorted([f for f in os.listdir() if f.endswith('.txt')])
    output = ''
    for txt_file in txt_files:
        with open(txt_file, 'r') as f:
            lines = f.readlines()
        while len(lines) < 25:
            lines.append('00000000\n')
        output += ''.join(lines)
    with open('code.txt', 'w') as f:
        f.write(output)
