#贷款总额计算
#float 计算
def pay_amount_per_month (r, n, money_amount):
    P = r * money_amount /( 12 * (1 - (1 + r/12) **(-n) ) )
    return P

A = 1000000 #贷款总额
month = 30 * 12
print("(%f,%f)"%(pay_amount_per_month(0.04, month, A), month * pay_amount_per_month(0.04, month, A)) )
print("(%f,%f)"%(pay_amount_per_month(0.05, month, A), month * pay_amount_per_month(0.05, month, A)) )
print("(%f,%f)"%(pay_amount_per_month(0.06, month, A), month * pay_amount_per_month(0.06, month, A)) )
