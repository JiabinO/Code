import math

class Integrator:
    def __init__(self, a, b, n):
        self.a, self.b, self.n = a, b, n
        self.points, self.weights = self.compute_points()
        
    def compute_points(self):
        raise NotImplementedError(self.__class__.__name__)
        
    def integrate(self, f):
        calculation = 0
        for i in range(0, self.n + 1):
            calculation += f(self.points[i]) * self.weights[i]
        return calculation
    
class Trapezoidal(Integrator):
    def compute_points(self):
        x_list = []
        w_list = []
        h = (self.b - self.a) / self.n
        for i in range(0, self.n + 1):
            x_list.append(self.a + i * h)
            if i == 0 or i == self.n:
                w_list.append(h / 2)
            else:
                w_list.append(h)
        return x_list, w_list

class Simpson(Integrator):  #n为偶数
    def compute_points(self):
        x_list = []
        w_list = []
        n = 0
        if self.n % 2 == 0: #偶数
            n = self.n
        else :
            n = self.n + 1
        h = (self.b - self.a) / n            
        for i in range(0, n + 1):
            x_list.append(self.a + i * h)
            if i == 0 or i == n:
                w_list.append(h / 3)
            elif i % 2 == 0:    #偶数
                w_list.append(2 * h / 3)
            else:               #奇数
                w_list.append(4 * h / 3)
        return x_list, w_list

class GaussLegendre(Integrator):
    def compute_points(self):
        x_list = []
        w_list = []
        n = 0
        if self.n % 2 == 0:
            n = self.n + 1
        else:
            n = self.n
        h = 2 * (self.b - self.a) / (n + 1)
        for i in range(0, n + 1):
            w_list.append(h / 2)
            if i % 2 == 0:    #偶数
                x_list.append(self.a + (i + 1) * h / 2 - math.sqrt(3) * h / 6)
            else:               #奇数
                x_list.append(self.a + i * h / 2 + math.sqrt(3) * h / 6)
        return x_list, w_list
        
def test():
    def f(x): return (x * math.cos(x) + math.sin(x)) * \
                        math.exp(x * math.sin(x))
    def F(x): return math.exp(x * math.sin(x))

    a = 2; b = 3; n = 200
    I_exact = F(b) - F(a)
    tol = 1E-3

    methods = [Trapezoidal, Simpson, GaussLegendre]
    for method in methods:
        integrator = method(a, b, n)
        I = integrator.integrate(f)
        rel_err = abs((I_exact - I) / I_exact)
        print('%s: %g' %(method.__name__, rel_err))
        if rel_err > tol:
            print('Error in %s' % method.__name__)

if __name__ == '__main__':
    test()
