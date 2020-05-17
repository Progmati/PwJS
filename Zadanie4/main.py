import sys
import matplotlib.pyplot as plt


# funkcja zliczajaca wystepowania liter w tekscie
def countLetters(lineParam):
	for c in lineParam:
		if ('A' <= c <= 'Z') or ('a' <= c <= 'z'):
			if c in chars:
				chars[c] = chars[c] + 1
			else:
				chars[c] = 1

argFilename = ""

if len(sys.argv) > 1:
	argFilename = sys.argv[1]
else:
	print("Nie podano argumentu przy wywołaniu programu")
	exit(-1)


chars = {}

# odczyt pliku
histogramLine = ""
text = ""
index = 0
try:
	with open(argFilename) as file:
		for line in file:
			if index == 0:
				histogramLine = line
				index = index + 1
			else:
				countLetters(line)
				text = text + line
except FileNotFoundError:
	print('Error. Nie znaleziono takiego pliku')
	exit(-2)

# posortowanie słownika z wystąpieniami
chars = {key: value for key, value in reversed(sorted(chars.items(), key=lambda item: item[1]))}

# slownik zawierajacy pare zaszyfrowana wartosc - nowa wartosc
replaceValues = {}
i = 0
for item in chars:
	replaceValues[item] = histogramLine[i]
	i = i + 1

# odszyfrowywanie tekstu
decipher = ""
for a in text:
	if a in chars:
		decipher += str(replaceValues.get(a))
	else:
		decipher += a

# zapis do pliku odszyfrowanego tekstu
try:
	with open('decipher.txt', 'w') as file:
		file.write(decipher)
		print('Zapisano do pliku')
except FileNotFoundError:
	print('Error')

# wyświetlenie histogramu
plt.bar(list(chars.keys()), chars.values(), width=0.5, color='g')
plt.show()
