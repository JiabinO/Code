import sys, re

def test_all_functions():
    x = (29, -11)
    y = (-7, -15)
    print("add_excepted: -358/165")
    print("tested:")
    output(add(x, y))
    print("sub_excepted: -512/165")
    print("tested:")
    output(sub(x, y))
    print("mul_excepted: -203/165")
    print("tested:")
    output(mul(x, y))
    print("div_excepted: -435/77")
    print("tested:")
    output(div(x, y))
    
def gcd(a, b):
    while a != b:
        if(a > b):
            a -= b
        else:
            b -= a
    return a

def reduce(n, d):   #约分,返回约分后的元组，要求能处理分子、分母含负号的情形（尤其是除法）
    if n < 0:
        a1 = -n
    else :
        a1 = n
    a2 = d
    c  = gcd(abs(a1), abs(a2))
    a1 = a1 / c
    a2 = a2 / c
    if(a2 < 0):
        a2 = -a2
        a1 = -a1
    return (a1, a2)

    
def add(x, y):      #传入有理数元组x，y
    a = x[0] * y[1] + y[0] * x[1]
    b = x[1] * y[1]
    return reduce(a, b)
    
def sub(x, y):
    a = x[0] * y[1] - y[0] * x[1]
    b = x[1] * y[1]
    return reduce(a, b)
    
def mul(x, y):
    a = x[0] * y[0]
    b = x[1] * y[1]
    return reduce(a, b)

def div(x, y):
    a = x[0] * y[1]
    b = x[1] * y[0]
    return reduce(a, b)
    
def output(x):       #输出计算结果
    print(str(int(x[0])) + '/' + str(int(x[1])))
    
def get_rational(s): #从字符串s中得到列表[n, d]
    match = re.match(r'\((\d+)/(\d+)\)', s)
    if match:
        numerator = int(match.group(1))
        denominator = int(match.group(2))
        return (numerator, denominator)
    else:
        match = re.match(r'\((-?\d+)/(-?\d+)\)', s)
        if match:
            numerator = int(match.group(1))
            denominator = int(match.group(2))
            return (numerator, denominator)
            
if __name__ == '__main__':
    if len(sys.argv) == 1:
        print(__doc__)
    elif len(sys.argv) == 2 and sys.argv[1] == '-h':
        print(__doc__)
    elif len(sys.argv) == 2 and sys.argv[1] == 'test':
        test_all_functions()
    else:
        import argparse
        parser = argparse.ArgumentParser()
        parser.add_argument('--op', type = str)
        parser.add_argument('--x', type = str)
        parser.add_argument('--y', type = str)
        args = parser.parse_args()
        op = args.op
        x = get_rational(args.x); y = get_rational(args.y)
        f = {'add':add, 'sub':sub, 'mul':mul, 'div':div}
        output(f[op](x,y))
