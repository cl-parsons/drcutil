import sys

num = 0
for line in sys.stdin:
    if line.find("nan") >= 0:
        print "FALL"
        sys.exit(0)
    num += 1
    if num == 2:
        position = eval(line)
    if num == 3:
        rotation = eval(line)

if rotation[0] > -0.1 and rotation[0] < 0.1 and \
   rotation[1] > -0.1 and rotation[1] < 0.1 and \
   rotation[2] > -2.0 and rotation[2] < 2.0:
    print "OK"
else:
    print "FALL"
