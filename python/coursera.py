#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# coursera.py
# download videos from coursera.org
#
# Author: Alex.wang
# Create: 2013-09-23 22:36


import os, sys
import urllib
import argparse
import ConfigParser


CONFIG_FILE = 'coursera.ini'

class Coursera:
	SECTION = 'coursera'
	DOWNLOAD_DIR = 'download'
	def __init__(self, course = None, total = None):
		self.config = ConfigParser.ConfigParser()
		self.config.read(CONFIG_FILE)
		if not self.config.has_section(self.SECTION):
			self.config.add_section(self.SECTION)
		# load last config
		if course is None:
			course = self.config.get(self.SECTION, 'last_course')
		if total is None:
			total = self.config.getint(self.SECTION, course)
		if not self.config.has_section(course):
			self.config.add_section(course)
		self.course = course
		self.total = total
		self.config.set(self.SECTION, 'last_course', course)
		self.config.set(self.SECTION, course, total)
		self.save()

	def save(self):
		with open(CONFIG_FILE, 'w+') as fp:
			self.config.write(fp)

	def _rename(self, i):
		'''rename the downloaded file to meaningful name'''
		files = os.listdir(self.DOWNLOAD_DIR)
		if len(files) == 0:
			raise Exception, 'no file downloaded, wrong course?'
		src = files[0]
		unquote = urllib.unquote_plus(src)
		# if substring not found, so download may fail, so use str.index() here
		dst = unquote[unquote.index('filename=') + 10:-1]
		os.rename('%s/%s' % (self.DOWNLOAD_DIR, src), '%s/%s' % (self.course, dst))
		self.config.set(self.course, str(i), dst)

	def _download(self, i):
		if not os.path.exists(self.DOWNLOAD_DIR):
			os.mkdir(self.DOWNLOAD_DIR)
		if not os.path.exists(self.course):
			os.mkdir(self.course)
		os.system('cd %s && wget --load-cookies=../coursera.txt --no-check-certificate --continue "https://class.coursera.org/%s/lecture/download.mp4?lecture_id=%d"' % (self.DOWNLOAD_DIR, self.course, i))
		self._rename(i)
		self.save()

	def downloads(self):
		ignore = [int(i) for i in self.config.options(self.course)]
		for i in xrange(1, self.total):
			if i in ignore:
				continue
			self._download(i)


def main():
	parser = argparse.ArgumentParser(description = '''\
Download videos from coursera.org.
You have to save the cookies to `coursera.txt', or wget will fail.
Call without argument will try to resume last download.

For example `coursera.py -c crypto-007 -n 66' will download
Video Lectures of `Cryptography I' from Stanford by Dan Boneh.
''', formatter_class = argparse.RawDescriptionHelpFormatter)
	parser.add_argument('-c', '--course', metavar = 'COURSE', help = 'Download Video Lectures of COURSE')
	parser.add_argument('-n', '--total', metavar = 'TOTAL', type = int, help = 'the number of videos to download')
	args = parser.parse_args(sys.argv[1:])
	print args
	try:
		c = Coursera(args.course, args.total)
		c.downloads()
	except ConfigParser.NoOptionError:
		parser.exit(2, 'use --course and --total for new download')
	except ValueError:
		parser.exit(1, 'Download failed, you should put cookies to `coursera.txt\' file')


if __name__ == '__main__':
	main()
