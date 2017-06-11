import os

for n in os.listdir("wrd_dev"):
    
    with open("wrd_dev/%s" % n, "rb") as f:
        
        for i, line in enumerate(f):
            
            if len(line) == 2 and i != 7:
                
                print n, i