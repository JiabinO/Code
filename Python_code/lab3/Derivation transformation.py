nums = {25,18,91,365,12,78,59}
multiplier_of_3 = []
for i in nums:
    if i % 3 == 0:
        multiplier_of_3.append(i)

print(multiplier_of_3)

square_of_odds = set()
for i in nums:
    if i % 2 == 1:
        square_of_odds.add(i**2)

print(square_of_odds)

s = [25,18,91,365,12,78,59,18,91]
sr = {}
for i in set(s):
    sr[i] = i % 3

print(sr)
tr = {}
for (n,r) in sr.items():
    if r == 0:
        tr[n] = r
print(tr)
