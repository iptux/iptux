#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# waveform.py
# generate waveform in .wav format
#
# Author: Alex.wang
# Create: 2017-04-14 11:11


import math
import wave
import struct


class Waveform(object):
	# https://en.wikipedia.org/wiki/Sampling_(signal_processing)
	FRAME_RATE = (
		8000,
		11025,
		16000,
		22050,
		32000,
		37800,
		44056,
		44100,
		47250,
		48000,
		50000,
		50400,
		88200,
		98000,
		176400,
		192000,
		352800,
		2822400,
		5644800,
	)
	BIT_DEPTH = (
		8,
		16,
		24,
		32,
	)
	PACK_FORMAT = (
		None,
		'b',
		'h',
		None,
		'i',
	)
	def __init__(self, rate=None, bitdepth=None):
		self.nchannels = 2
		self.framerate = float(rate) if rate in self.FRAME_RATE else 44100.0
		self.samplewidth = bitdepth // 8 if bitdepth in self.BIT_DEPTH else 2
		self._max = float(2**(self.samplewidth * 8 - 1))
		self._pack = struct.Struct(self.PACK_FORMAT[self.samplewidth])

	def wave(self, t):
		'''t -> v, v in range [-1, 1]'''
		raise NotImplementedError('wave not defined')

	def _sample(self, n):
		return int(self._max * self.wave(n / self.framerate))

	def _frame(self, n):
		return self._pack.pack(self._sample(n))

	def generate(self, fname, t):
		wav = wave.open(fname, 'wb')
		wav.setnchannels(self.nchannels)
		wav.setsampwidth(self.samplewidth)
		wav.setframerate(self.framerate)

		seg = 1024
		fb = [None] * seg * self.nchannels
		N = int(t * self.framerate)
		for n in xrange(0, N + 1, seg):
			count = min(seg, N + 1 - n)
			for i in xrange(count):
				v = self._frame(n + i)
				fb[i * self.nchannels : (i + 1) * self.nchannels] = [v] * self.nchannels
			wav.writeframesraw(''.join(fb[:count * self.nchannels]))
		wav.writeframes('')
		wav.close()


class SineWave(Waveform):
	def __init__(self, hz, rate=None, bitdepth=None):
		super(SineWave, self).__init__(rate, bitdepth)
		self.factor = 2 * math.pi * hz

	def wave(self, t):
		return math.sin(self.factor * t)


class SawtoothWave(Waveform):
	def __init__(self, hz, rate=None, bitdepth=None):
		super(SawtoothWave, self).__init__(rate, bitdepth)
		self.hz = hz

	def wave(self, t):
		return (2 * self.hz * t) % 2 - 1


class SquareWave(SawtoothWave):
	def __init__(self, hz, peak=0.8, rate=None, bitdepth=None):
		super(SquareWave, self).__init__(hz, rate, bitdepth)
		self.peak = peak

	def wave(self, t):
		return self.peak if super(SquareWave, self).wave(t) > 0 else -self.peak


class TriangularWave(Waveform):
	def __init__(self, hz, rate=None, bitdepth=None):
		super(TriangularWave, self).__init__(rate, bitdepth)
		self.hz = hz

	def wave(self, t):
		v = (4 * self.hz * t) % 4 - 1
		return 2 - v if v >= 1.0 else v


if __name__ == '__main__':
	SineWave(1000).generate('sine.wav', 1)
	SawtoothWave(1000).generate('sawtooth.wav', 1)
	SquareWave(1000).generate('square.wav', 1)
	TriangularWave(1000).generate('triangular.wav', 1)

