#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# wrapper for mplayer
#
# Author: Alex.wang
# Create: 2014-01-23 00:34


import subprocess
import threading


class MPlayer:
	BIN = '/usr/bin/mplayer'

	def __init__(self, *music):
		self.mplayer = None
		self.thread = None
		self.music = []
		self.paused = False
		self.loop = False
		self.play(*music)

	def __del__(self):
		self.quit()

	@staticmethod
	def _replay(player):
		'''replay the music if loop required'''
		assert isinstance(player, MPlayer)
		while True:
			player.wait()
			if len(player.music) and player.loop:
				player.play(*player.music)
				continue
			break
		player.paused = False

	def play(self, *music):
		'''return True if the MUSIC is to be playing, else return False'''
		if not len(music) or self._isAlive():
			return False

		self.music = music
		args = [MPlayer.BIN]
		args.extend(music)
		self.mplayer = subprocess.Popen(args, stdin = subprocess.PIPE)
		self.stdin = self.mplayer.stdin

		self.thread = threading.Thread(target = MPlayer._replay, args = (self,))
		self.thread.start()
		self.paused = False
		return True

	def setLoop(self, loop = True):
		self.loop = loop

	def _isAlive(self):
		return self.mplayer and self.mplayer.returncode is None

	def _sendcmd(self, cmd):
		'''send a cmd to mplayer if possible (internal used)'''
		if self._isAlive():
			self.stdin.write(cmd)
			self.stdin.flush()

	def isPlaying(self):
		'''return True if mplayer is playing music'''
		return self._isAlive() and not self.paused

	def wait(self):
		'''wait until all music play finished'''
		if self._isAlive():
			self.mplayer.wait()

	def pause(self):
		'''pause the music, pause again will continue'''
		if self._isAlive():
			self._sendcmd('p')
			self.paused = not self.paused

	def next(self):
		'''forward to next music, forward to much will quit the play'''
		self._sendcmd('>')

	def prev(self):
		'''backward to previous music, backward to much will quit the play'''
		self._sendcmd('<')

	def quit(self):
		'''quit the play'''
		self._sendcmd('q')

	def inc_volume(self):
		'''increase the volume'''
		self._sendcmd('0')

	def dec_volume(self):
		'''decrease the volume'''
		self._sendcmd('9')

