def is_sorted(s):
    for i in range(0,len(s)-1):
        if(s[i] > s[i+1]):      
            return False
    return True

def qsort(s):
    if len(s) <= 1: return s
    s_less = []; s_greater = []; s_equal = []
    for k in s:
        if k < s[0]:
            s_less.append(k)
        elif k > s[0]:
            s_greater.append(k)
        else:
            s_equal.append(k)
    return qsort(s_less) + s_equal + qsort(s_greater)

def binary_search(s, low, high, k):
    mid = (int)((low + high) / 2)
    while low <= high :
        if s[mid] == k:
            return mid
        else :
            if s[mid] > k :
                high = mid - 1
            else :
                low = mid + 1
            mid = (int)((low + high) / 2)    
    return -1    
            
s = [5, 6, 21, 32, 51, 60, 67, 73, 77, 99]

print(binary_search(s, 0, len(s) - 1, 5)) 
print(binary_search(s, 0, len(s) - 1, 31)) 
print(binary_search(s, 0, len(s) - 1, 99)) 
print(binary_search(s, 0, len(s) - 1, 64)) 
print(binary_search(s, 0, len(s) - 1, 51)) 
