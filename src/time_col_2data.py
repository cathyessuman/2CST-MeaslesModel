#import os

with open("data.csv", "r") as f:
	X = f.readlines()

with open("dataset.csv", "w") as g:
	for line in X[:-2]:
		l = line.split("\n")[0].split(",")
		t = l[0] + "-"+l[1] + "-"+ l[2]
		g.write(l[0]+","+l[1]+","+l[2]+","+l[3]+","+t+"\n")
