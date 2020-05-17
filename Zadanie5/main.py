# Author: Mateusz Krzak
# Date: 22.04.2020

from os import walk, stat
from itertools import permutations
import sys


def Compare(tuppleFile1, tuppleFile2):
	filename1 = tuppleFile1[0]
	size1 = tuppleFile1[1]

	filename2 = tuppleFile2[0]
	size2 = tuppleFile2[1]

	if size1 != size2:
		return False
	file1 = open(filename1, 'rb')
	file2 = open(filename2, 'rb')

	is_the_same = True

	while file1_byte := file1.read(1):
		file2_byte = file2.read(1);
		if file1_byte != file2_byte:
			is_the_same = False
			break

	file1.close()
	file2.close()

	return is_the_same


def GetSize(path):
	size = 0
	file = open(path, 'rb')
	byte = file.read(1)
	while byte:
		byte = file.read(1)
		size = size + 1
	file.close()
	return size


def Main():
	if len(sys.argv) == 1:
		print("Brak argumentów")
		sys.exit(-1)
	path = sys.argv[1:len(sys.argv)]
	print("Foldery: ", path)
	# path = ["pliki1", "pliki2"]

	# zapisanie nazw wszystkich plików z katalogów do listy
	# w formacie (nazwa_pliku, rozmiar w bajtach)
	onlyfiles = []
	for item in path:
		for root, dirs, files in walk(item):
			onlyfiles.extend((root + "/" + file, stat(root + "/" + file).st_size) for file in files)
	# poniższa instrukcja działa ale jest bardzo wolna
	# onlyfiles.extend((root + "/" + file, GetSize(root + "/" + file)) for file in files)

	# permutacje wszystkich plików bez duplikatów
	# (plik1,plik44) == (plik44,plik1)
	noDuplicates = []
	filePerm = set(permutations(onlyfiles, 2))
	for item in filePerm:
		if item[0][0] < item[-1][0]:
			noDuplicates.append(item)

	print("Duplicates:")
	for item in noDuplicates:
		if Compare(item[0], item[1]):
			print(item[0][0] + " -> " + str(item[1][0]) + " (size:" + str(item[0][1]) + "b)")


Main()
