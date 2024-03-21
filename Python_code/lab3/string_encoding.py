string = input()
string = list(string)
offset = int(input())
for i in range(len(string)):
    string[i] = chr(ord(string[i]) + offset)
#输出列表所有字符拼接起来的字符串
print(''.join(string))
