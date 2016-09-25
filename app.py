#!/usr/bin/env python

from sys import exit
from tools.generator import *

def intro():
	print(
"""
D&D Name Generator v0.2
Caleb Lucas-Foley
2016-03-04

Commands:

exit
	Exits program
list
	Lists the currently loaded languages
load <filename>
	Loads the specified filename from ./languages
build <language_name> <amount>
	Builds the specified amount of names from the specified language
titles
	Toggle use of titles
"""
		)

def load_language(language_dict, filename):
	if not filename.startswith('languages/'):
		filename = 'languages/' + filename
	if not filename.endswith('.txt'):
		filename += '.txt'
	print('Opening ' + filename)
	try:
		syllables_file = open(filename, 'r')
		new_language = Language(syllables_file)
		syllables_file.close()
		language_dict[new_language.name.lower()] = new_language
		print('New language loaded: ' + new_language.name)
	except:
		print('File not found')

def load_titles(titles):
	print('Loading titles')
	try:
		titles_file = open('titles/titles.txt', 'r')
		titles.extend(titles_file.read().split('\n'))
		titles_file.close()
	except:
		print('File not found')

def pretty_print(name_list, titles_list=[], use_titles=False):
	for name in name_list:
		if use_titles:
			print(name + random_title(titles_list))
		else:
			print(name)

def list_languages(language_dict):
	if len(language_dict) == 0:
		print('No languages loaded')
	else:
		for language_name, language in language_dict.iteritems():
			print(language.name + ': ' + str(language.count) + ' units')

def run():
	intro()

	languages = {}
	titles = []
	use_titles = False

	while True:
		command = raw_input('> ').split()

		if len(command) < 1:
			print('Enter a command')

		elif command[0] == 'exit':
			print('Quitting....')
			exit(0)

		elif command[0] == 'load': # load <filename>
			if len(command) < 2:
				print('Please specify a language')
				continue
			load_language(languages, command[1])

		elif command[0] == 'build': # build <language_name> <amount>
			if len(command) < 2:
				print('Please specify a language and amount')
				continue
			if len(command) < 3:
				command.append('1')
			if command[1].lower() in languages:
				print('Building %s names from %s' % (command[2], command[1]))
				pretty_print(languages[command[1].lower()].build_names(int(command[2])),
					titles, use_titles)
			else:
				print('Language ' + command[1] + ' not found')

		elif command[0] == 'titles':
			if use_titles:
				use_titles = False
				print('Titles disabled')
			else:
				use_titles = True
				if not titles:
					load_titles(titles)
				print('Titles enabled')

		elif command[0] == 'list':
			list_languages(languages);

		else:
			print('Command not recognized')

run()
