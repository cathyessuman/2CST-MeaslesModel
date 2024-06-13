# Open a file data containing a dataset without head
with open("data.csv", "r") as f:
	X = f.readlines()

# Add a new column with for time in the format DD/MM/YYYY
with open("data.csv", "w") as g:
	for line in X[:-2]:
		l = line.split("\n")[0].split(",")
		t = l[0] + "-"+l[1] + "-"+ l[2]
		g.write(l[0]+","+l[1]+","+l[2]+","+l[3]+","+t+"\n")
