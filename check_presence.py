#!/usr/bin/python3

# put reads from textfile in list -> 2251 
logfile = open("raw.txt", "r")
data = logfile.read()
raw_list = data.split("\n")
logfile.close()
# remove empty list items (such as last \n)
raw_list = list(filter(None, raw_list))
len(raw_list)

# put reads from textfile in list -> 2833
logfile = open("merged.txt", "r")
data = logfile.read()
merge_list = data.split("\n")
logfile.close()
# remove empty list items (such as last \n)
merge_list = list(filter(None, merge_list))
len(merge_list)

sourceFile = open('presence_labeled.fas', 'a')
c=0
for i in raw_list:
    c +=1
    if i in merge_list:
        print(f">{c}__Present", file=sourceFile)
        print(f"{i}", file=sourceFile)
    else:
        print(f">{c}__Missing", file=sourceFile)
        print(f"{i}", file=sourceFile)
sourceFile.close()
