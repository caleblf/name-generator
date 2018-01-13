from random import randint, choice

class Language(object):
	"""Contains syllables from which to build names in one language"""

	def __init__(self, syllables_file):
		self.syllables = syllables_file.read().split()
		self.name = self.syllables.pop(0)
		self.range = (int(self.syllables.pop(0)), int(self.syllables.pop(0)))
		self.count = len(self.syllables)

	def build_names(self, amt=1):
		"""Generate a list of names using this language"""
		names = []
		for i in xrange(amt):
			new_name = ""
			for j in xrange(randint(*self.range)):
				new_name += choice(self.syllables)
			new_name = new_name.lower().capitalize()
			names.append(new_name)
		return names

def random_title(titles_list):
	return ' the ' + choice(titles_list)