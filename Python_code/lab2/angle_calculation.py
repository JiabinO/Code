#math模块
import math

def cos_thm(a,b,c):
    return (a**2 + b**2 - c**2) / (2*a*b)

A = 3.0
B = 6.0
C = 7.0

cos_alpha = cos_thm(B, C, A)
cos_beta  = cos_thm(A, C, B)
cos_gama  = cos_thm(A, B, C)

alpha = math.degrees(math.acos(cos_alpha))
beta  = math.degrees(math.acos(cos_beta))
gama  = math.degrees(math.acos(cos_gama)) 
#由于是由弧度制表示，故需要使用degrees函数将其转化
print(alpha, beta, gama, alpha + beta + gama)
