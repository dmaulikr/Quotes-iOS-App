import json
def test():
            file = open("/Users/ChiragA/Desktop/testfile.txt", "r")
            x = []
            for line in file:
                        x.append(line.rstrip())
            with open('/Users/ChiragA/Desktop/json', 'w') as f:
                                    json.dump(x, f)
            print(x)

