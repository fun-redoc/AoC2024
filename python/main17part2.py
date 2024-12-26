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

if __name__ == '__main__':
    prg = [2,4,1,3,7,5,1,5,0,3,4,2,5,5,3,0] # <- has 16 positions
    #print(run(33024962))

    # IDEA
    # I'm going to try a tableau based DP (dynamic programming) solution
    # if you look at the program (function run) you see that a is divided by 8 each step and the results output is allways mod 8
    # so the formula for the next position is something like (last_input)*8 + a, where a € [0..7] and last _input already produces a part aof the desired output string.

    # lets start with an empty tableau
    tabl = 16*[0]

    # the seed is going to be the value which produces the 16th position
    last = 0
    i = 0
    tabl[i] = list(filter(lambda x: x[2] == [0], [(a,last*8+a, run(a)[3]) for a in range(0,8)]))
#    i += 1
#    tabl[i] = list(filter(lambda x: x[2] == [3,0], [(a,last[1]*8+a, run(last[1]*8+a)[3]) for a in range(0,8) for last in tabl[i-1]]))
#    i += 1
#    tabl[i] = list(filter(lambda x: x[2] == [5,3,0], [(a,last[1]*8+a, run(last[1]*8+a)[3]) for a in range(0,8) for last in tabl[i-1]]))
#    print(tabl[i])

    # etc. lets put into a loop of 16 (because of 16 positions)
    for i in range(1,16):
        subprg = prg[-(i+1):]
        tabl[i] = list(filter(lambda x: x[2] == subprg, [(a,last[1]*8+a, run(last[1]*8+a)[3]) for a in range(0,8) for last in tabl[i-1]]))
    
    # the complete resultin program resides in tabl[15]
    res = sorted(tabl[15], key=lambda x: x[1])
    print(res[0][1])