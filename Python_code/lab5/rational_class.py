import math

def gcd(a, b):
    while a != b:
        if a > b:
            a -= b
        else:
            b -= a
    return a

class Rational:
    def __init__(self, n=0, d=1):
        # 将 [n, d] 表示的有理数转换成标准形式
        nu = n
        de = d
        if de < 0:
            nu = -nu
            de = -de
        gcd_value = gcd(abs(nu), abs(de))
        
        nu //= gcd_value
        de //= gcd_value
        self.__dict__['nu'] = nu
        self.__dict__['de'] = de
    
    def __setattr__(self, name, value):
        if name in ['nu', 'de']:
            self.__dict__[name] = value
        else:
            raise AttributeError('Rational objects have read-only attributes')
        
    def __str__(self): 
        return '%d/%d' % (self.nu, self.de)
    
    def __add__(self, other):
        added_nu = self.nu * other.de + self.de * other.nu
        added_de = self.de * other.de
        gcd_value = gcd(abs(added_nu), abs(added_de))
        added_nu //= gcd_value
        added_de //= gcd_value
        return Rational(added_nu, added_de)
    
    def __sub__(self, other):
        subed_nu = self.nu * other.de - self.de * other.nu
        subed_de = self.de * other.de
        gcd_value = gcd(abs(subed_nu), abs(subed_de))
        subed_nu //= gcd_value
        subed_de //= gcd_value
        return Rational(subed_nu, subed_de)
    
    def __mul__(self, other):
        nu = self.nu * other.nu
        de = self.de * other.de
        gcd_value = gcd(abs(nu), abs(de))
        nu //= gcd_value
        de //= gcd_value
        return Rational(nu, de)
    
    def __truediv__(self, other):
        nu = self.nu * other.de
        de = self.de * other.nu
        gcd_value = gcd(abs(nu), abs(de))
        nu //= gcd_value
        de //= gcd_value
        return Rational(nu, de)
    
    def __eq__(self, other):
        return self.nu == other.nu and self.de == other.de
    
    def __ne__(self, other):
        return not self.__eq__(other)
    
    def __gt__(self, other):
        sub = self.__sub__(other)
        return sub.nu > 0
    
    def __lt__(self, other):
        sub = self.__sub__(other)
        return sub.nu < 0
    
    def __ge__(self, other):
        sub = self.__sub__(other)
        return sub.nu >= 0
    
    def __le__(self, other):
        sub = self.__sub__(other)
        return sub.nu <= 0

    
def test():
    testsuite = [
            ('Rational(2, 3) + Rational(-70, 40)', Rational(-13, 12)),
            ('Rational(-20, 3) - Rational(120, 470)', Rational(-976, 141)),
            ('Rational(-6, 19) * Rational(-114, 18)', Rational(2, 1)),
            ('Rational(-6, 19) / Rational(-114, -28)', Rational(-28, 361)),
            ('Rational(-6, 19) == Rational(-14, 41)', False),
            ('Rational(-6, 19) != Rational(-14, 41)', True),
            ('Rational(6, -19) > Rational(14, -41)', True),
            ('Rational(-6, 19) < Rational(-14, 41)', False),            
            ('Rational(-6, 19) >= Rational(-14, 41)', True),
            ('Rational(6, -19) <= Rational(14, -41)', False),
            ('Rational(-15, 8) == Rational(120, -64)', True),   
            ]
    for t in testsuite:
        try:
            result = eval(t[0])
        except:
            print('Error in evaluating' + t[0]); continue
    
        if result != t[1]:
            print('Error: %s != %s' % (t[0], t[1]))
            
if __name__ == '__main__':
    test()
