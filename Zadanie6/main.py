#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Author: Mateusz Krzak
# Date: 22.04.2020

import re
import io
import numpy as np


class Time:
	hour = None
	minute = None

	def __init__(self, hour, minute):
		self.hour = hour
		self.minute = minute

	def toString(self):
		return str(self.hour) + ":" + str(self.minute)


class Element:
	start_time: Time = None
	end_time: Time = None
	nazwa_przedmiotu = None
	semestr = None
	forma_studiow = None
	forma_zajec = None
	line = None

	def __init__(self):
		self.nazwa_przedmiotu = "--------"
		self.start_time = Time(0, 0)
		self.end_time = Time(0, 0)
		self.semestr = 0

	def toString(self):
		return self.nazwa_przedmiotu + \
			   "(semestr: " + str(self.semestr) + ") " + \
			   str(self.forma_zajec) + ", " + \
			   str(self.forma_studiow) + " " + \
			   self.start_time.toString() + " - " + \
			   self.end_time.toString()

	def generateHash(self):
		return self.nazwa_przedmiotu + "_" + str(self.forma_studiow) + "_" + str(self.forma_zajec)


minutyArray = []
lines = []


# zwraca w minutach różnicę pomiędzy czasami
def DiffTime(startTime, endTime, addToArray=False):
	lesson_length = 45
	hours = endTime.hour - startTime.hour
	minutes = endTime.minute - startTime.minute
	val = hours * 60 + minutes
	if addToArray:
		minutyArray.append(val)
	return val


try:
	with io.open('plan_zajec.ics', 'r', encoding='utf8') as file:
		for line in file:
			lines.append(line)

except FileNotFoundError:
	print('Error')

regex_time_start = "DTSTART;TZID=[A-Za-z]+/[A-Za-z]+:[0-9]{4}[0-9]{2}[0-9]{2}T*([0-9]{2})*([0-9]{2})[0-9]{2}"
regex_time_end = "DTEND;TZID=[A-Za-z]+/[A-Za-z]+:[0-9]{4}[0-9]{2}[0-9]{2}T*([0-9]{2})*([0-9]{2})[0-9]{2}"
regex_przedmiot = "SUMMARY:*([A-Za-z0-9 -ąćęłńóśźż]+) - Nazwa sem.: semestr [0-9a-zA-z]+, Nr sem.: ([0-9]), Grupa: (.*),"
regex_end = "END:VEVENT"
regex_begin = "BEGIN:VEVENT"
regex_formy = "(?:lato_|zima_)*(S1|S2|N1|N2)?.*(L|W)"

# lista wszystkich elementów
elements = []

# pojedynczy obiekt klasy Element
elem: Element = None

# operacje z użyciem regexów
for line in lines:
	result = re.findall(regex_begin, line)
	if len(result) != 0:
		elem = Element()

	result = re.findall(regex_time_start, line)
	if len(result) != 0:
		elem.start_time = Time(int(result[0][0]), int(result[0][1]))

	result = re.findall(regex_time_end, line)
	if len(result) != 0:
		elem.end_time = Time(int(result[0][0]), int(result[0][1]))

	result = re.findall(regex_przedmiot, line)
	if len(result) != 0:
		elem.nazwa_przedmiotu = result[0][0]
		elem.semestr = result[0][1]
		elem.line = line

		result2 = re.findall(regex_formy, result[0][2])
		if len(result2) != 0:
			elem.forma_studiow = result2[0][0]
			elem.forma_zajec = result2[0][1]

	result = re.findall(regex_end, line)
	if len(result) != 0:
		elements.append(elem)
		DiffTime(elem.start_time, elem.end_time, True)

# tworzenie słownika dla przedmiotów, form zajęć i form studiów
dictionary = {}
for item in elements:
	myhash = item.generateHash().replace(" ", "_")
	if myhash in dictionary:
		dictionary[myhash]["minuty"] = dictionary[myhash]["minuty"] + DiffTime(item.start_time, item.end_time)
	else:
		dictionary[myhash] = {"minuty": 0, "nazwa": "", "forma_studiow": "", "forma_zajec": ""}
		dictionary[myhash]["minuty"] = DiffTime(item.start_time, item.end_time)
		dictionary[myhash]["nazwa"] = item.nazwa_przedmiotu
		if item.forma_studiow == "":
			dictionary[myhash]["forma_studiow"] = "unknown"
		else:
			dictionary[myhash]["forma_studiow"] = item.forma_studiow
		dictionary[myhash]["forma_zajec"] = item.forma_zajec


iloscGodzin = np.sum(minutyArray) / 45
print("Ilość godzin: " + str(round(iloscGodzin, 2)))

# zapis słownika do pliku CSV
file = io.open('output.csv', 'w', encoding='utf8')
stringstream = "\"Nazwa przedmiotu\",\"Forma studiów\",\"Forma zajęć\",\"Godziny\"\n"
file.write(stringstream)
for item in dictionary:
	elem = dictionary[item]
	stringstream = "\""+ elem["nazwa"]+"\",\""+elem["forma_studiow"]+"\",\""+elem["forma_zajec"]+"\",\"" + str(round(elem["minuty"]/45,2)).replace(".",",")+"\"\n"
	file.write(stringstream)
file.close()


