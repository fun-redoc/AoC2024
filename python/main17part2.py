from functools import reduce
from functools import lru_cache

@lru_cache(maxsize=2**6)
def chrono(a:int, b:int, c:int, max_out:int)->tuple[bool, tuple[int,int,int,list[int]]]:
    ready = False
    res =[]
    cnt_out = 0
    while not ready and cnt_out < max_out:
        b = a % 8
        b = b^3
        c = a // (2**b)
        b = b ^ 5
        a = a // 8
        b = b ^ c
        res.append(b%8)
        if a == 0:
            ready = True
        else:
            cnt_out += 1
    return (a ==0 ,(a,b,c,res)) # a==0 means terminated # a != 0 means not terminated

def run(a:int)->tuple[bool, tuple[int,int,int,list[int]]]:
    ready = False
    res =[]
    cnt_out = 0
    while not ready:
        b = a % 8
        b = b^3
        c = a // (2**b)
        b = b ^ 5
        a = a // 8
        b = b ^ c
        res.append(b%8)
        if a == 0:
            ready = True
    return (a,b,c,res) # a==0 means terminated # a != 0 means not terminated

def run1(a:int, max_out:int)->list[int]:
    res = []
    out1 = []

    b = a % 8
    b = b^3
    c = a // (2**b)
    b = b ^ 5
    a = a // 8
    b = b ^ c
    out = b%8
    terminated = True
    if a != 0:
        (terminated, (a,b,c,out1)) = chrono(a,b,c, max_out-1)
    return (terminated,[out] + out1)

def run2(a:int, prg:list[int], max_out:int)->list[int]:
    res = []

    for i in range(0,max_out):
        cmp = prg[i]
        b = a % 8
        b = b^3
        c = a // (2**b)
        b = b ^ 5
        a = a // 8
        b = b ^ c
        out = b%8
        if out != cmp:
            return (False, res)
        res.append(out)
        if a == 0:
            return (True, res)

out  = lambda a:(((((a%8)^3)^5)^(a//(2**((a%8)^3))))%8, a//8)

if __name__ == '__main__':
    prg = [2,4,1,3,7,5,1,5,0,3,4,2,5,5,3,0]
    #print(run(6816))
    run(2)
    run(53*8 + 1)
#     print(run(33024962))
#    print(run2(33024962,prg, 16))
#    5,1,3,4,3,7,2,1,7.
     
#    try_start = 35220480000000 #2**(3*15)+1
#    try_end = 2**(3*16) +1
#    for a in range(try_start, try_end):
#        if a%10000000 == 0:
#            print(f"{a} :{((a-try_start)/(try_end-try_start))*100}% ready")
#        res, prg1 = run2(a,prg, 16)
#        if res:
#            print(f"finished with a={a} prg1={prg1}")




