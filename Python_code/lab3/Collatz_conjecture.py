n = int(input())

while(n != 1) :
    print("%d "%n)
    if n % 2 == 0 :
        n = n / 2
    else :
        n = 3 * n + 1
    
print(1)
