#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# lg_kdz.py
# Get Latest LGE Cell Phone Firmware
#
# http://www.lg-phones.org/lg-optimus-me-firmwares-download.html
# http://forum.gsmhosting.com/vbb/archive/t-1512861.html
#
# http://csmg.lgmobile.com:9002/client/app/live_update.jsp
# http://csmg.lgmobile.com:9002/csmg/b2c/client/ftp_country_info.jsp
# http://csmg.lgmobile.com:9002/csmg/b2c/client/model_list.jsp?country=CN
# http://csmg.lgmobile.com:9002/svc/popup/model_check.jsp?esn=PUT_YOUR_IMEI_HERE
# http://csmg.lgmobile.com:9002/csmg/b2c/client/auth_model_check2.jsp?esn=PUT_YOUR_IMEI_HERE
# http://csmg.lgmobile.com:9002/csmg/b2c/client/tool_mode_country_check.jsp?country=CN&model=LGP350
# http://csmg.lgmobile.com:9002/csmg/b2c/client/web_model_list.jsp?country=CN&model=LGP350
#
# Author: Alex.wang
# Create: 2012-10-22 22:01
#
# Update: 2012-12-17 05:19
#  1. finish LGMobile implement
#  2. add Tkinter GUI.


import os, sys
import warnings
import httplib, urllib
import csv
from xml.etree import ElementTree as ET
import Tkinter, tkMessageBox, tkFont


class LGCountry:
	# ftp_country_info
	def __init__(self):
		self.country_code = ''
		self.country_isocode = ''
		self.country = ''
		self.region_name = ''
		self.region_code = ''
	def __eq__(self, other):
		return self.country_code == other.country_code


class LGModelSW:
	# lg model software information holder
	def __init__(self):
		self.model = ''
		self.swversion = ''
		self.buyer = ''
		self.region = ''
		self.country = ''
		self.chip_type = ''
		self.prod_type = ''
		self.buyer_name = ''
		self.live_date = ''
		self.suffix = ''
		self.firmware = ''
	def csv(self):
		return '%s,%s,%s,%s,%s,%s,%s,%s,%s,' % (self.model, self.region, self.country, self.chip_type, self.prod_type, self.buyer_name, self.swversion, self.live_date, self.firmware)
	def __str__(self):
		return 'model: %s, country: %s, date: %s, firmware: %s' % (self.model, self.country, self.live_date, self.firmware)


class ResponseFail(Exception):
	pass


class LGMobile:
	DIR = 'cache'
	SWHOST = 'csmgdl.lgmobile.com'
	def __init__(self):
		self.country = []
		self.model = {}
		self.modelsw = {}

		if not os.path.exists(self.DIR):
			os.mkdir(self.DIR)
		self.host = 'csmg.lgmobile.com:9002'
		self.http = httplib.HTTPConnection(self.host, timeout = 10)
		self.swhttp = httplib.HTTPConnection(self.SWHOST, timeout = 10)
	def __del__(self):
		self.http.close()
		self.swhttp.close()
	def exist(self, url):
		self.swhttp.request('HEAD', url)
		resp = self.swhttp.getresponse()
		resp.read()
		return resp.status == 200
	def _kdz(self, model, suffix, v1, v2):
		# FIXME: older Phone's firmware path format
		url = '/swdata/WDLSW/%s/%s/%s/%s.kdz' % (model, suffix, v1, v2)
		return self.exist(url) and 'http://%s%s' % (self.SWHOST, url) or None
	def kdz(self, model, suffix, swversion):
		swversion2 = swversion[0:3] + swversion[3].upper() + swversion[4:]
		return self._kdz(model, suffix, swversion, swversion2)
	def get(self, url, **parm):
		'''HTTP GET request'''
		if len(parm):
			url = '%s?%s' % (url, urllib.urlencode(parm))
		self.http.request('GET', url)
		return self.http.getresponse().read()
	def _getxml(self, url, **parm):
		elem = ET.fromstring(self.get(url, **parm).strip())
		if elem.attrib['status'] != 'OK':
			raise ResponseFail, 'get failed: %s, parm=%s' % (url, str(parm))
		return ET.ElementTree(elem[0])
	def getxml(self, fname, url, **parm):
		'''get xml object'''
		try:
			return ET.parse('%s/%s' % (self.DIR, fname))
		except IOError:
			tree = self._getxml(url, **parm)
			tree.write('%s/%s' % (self.DIR, fname))
			return tree
	def ftp_country_info(self):
		'''return a country list'''
		tree = self.getxml('ftp_country_info.xml', '/csmg/b2c/client/ftp_country_info.jsp')
		country = LGCountry()
		for elem in tree.getiterator():
			if hasattr(country, elem.tag):
				setattr(country, elem.tag, elem.text)
			if elem.tag == 'region_code':
				self.country.append(country)
				country = LGCountry()
		return self.country
	def model_list(self, country):
		'''return list of model avaliable in a COUNTRY'''
		try: return self.model[country]
		except KeyError: pass

		try:
			tree = self.getxml('web_model_list.%s.xml' % country, '/csmg/b2c/client/web_model_list.jsp', country = country)
			models = list(set([ elem.text for elem in tree.getiterator('model') ]))
		except: models = []
		self.model[country] = models
		return models
	def web_model_list(self, country, model):
		# used by tool_mode_country_check()
		try: tree = self.getxml('web_model_list.%s.%s.xml' % (country, model), '/csmg/b2c/client/web_model_list.jsp', country = country, model = model)
		except: return {}
		modelsw = {}
		sw = LGModelSW()
		for elem in tree.getiterator():
			if hasattr(sw, elem.tag):
				setattr(sw, elem.tag, elem.text)
			if elem.tag == 'popup_flag':
				modelsw[sw.buyer] = sw
				sw = LGModelSW()
		return modelsw
	def tool_mode_country_check(self, country, model):
		try: return self.modelsw[country][model]
		except KeyError: pass

		try: modelsw = self.web_model_list(country, model)
		except ResponseFail: modelsw = {}

		if country not in self.modelsw: self.modelsw[country] = {}
		if model not in self.modelsw[country]: self.modelsw[country][model] = modelsw

		if len(modelsw) == 0: return modelsw

		tree = self.getxml('tool_mode_country_check.%s.%s.xml' % (country, model), '/csmg/b2c/client/tool_mode_country_check.jsp', country = country, model = model)
		suffix = ''
		for elem in tree.getiterator():
			if elem.tag == 'suffix': suffix = elem.text
			elif elem.tag == 'buyer':
				try: sw = modelsw[elem.text.split('/')[0]]
				except KeyError: continue
				url = self.kdz(model, suffix, sw.swversion)
				if url:
					if sw.firmware: warnings.warn('url overwrited: country=%s, model=%s, url=%s' % (country, model, sw.firmware))
					sw.suffix = suffix
					sw.firmware = url
		return modelsw
	def auth_model_check2(self, imei):
		tree = self.getxml('auth_model_check2.%s.xml' % imei, '/csmg/b2c/client/auth_model_check2.jsp', esn = imei)
		return tree.getiterator('sw_url')[0].text


class LG_KDZ(Tkinter.Frame):
	def __init__(self, master = None):
		Tkinter.Frame.__init__(self, master)
		self.lg = LGMobile()
		self.countries = self.lg.ftp_country_info()
		self.countrycode = ''
		self.__widgets()
	def __widgets(self):
		self.swFrame = Tkinter.LabelFrame(self, text = 'By Country and Model')
		self.swFrame.grid_columnconfigure(1, weight = 1)

		countries = [ i.country for i in self.countries ]
		self.country = Tkinter.StringVar(self)
		self.cntryLabel = Tkinter.Label(self.swFrame, text = 'Country:')
		self.cntryMenu = Tkinter.OptionMenu(self.swFrame, self.country, *countries, command = self.setCountry)

		self.model = Tkinter.StringVar(self)
		self.modelLabel = Tkinter.Label(self.swFrame, text = 'Model:')
		self.modelMenu = Tkinter.OptionMenu(self.swFrame, self.model, '')
		self.modelMenu.config(state = Tkinter.DISABLED)

		self.cntryLabel.grid(row = 0, column = 0, sticky = Tkinter.E)
		self.cntryMenu.grid(row = 0, column = 1, sticky = Tkinter.EW)
		self.modelLabel.grid(row = 1, column = 0, sticky = Tkinter.E)
		self.modelMenu.grid(row = 1, column = 1, sticky = Tkinter.EW)

		self.imeiFrame = Tkinter.LabelFrame(self, text = 'By IMEI')

		self.imei = Tkinter.StringVar(self)
		self.imeiLabel = Tkinter.Label(self.imeiFrame, text = '   IMEI:')
		self.imeiEntry = Tkinter.Entry(self.imeiFrame, textvariable = self.imei)
		self.imeiButton = Tkinter.Button(self.imeiFrame, text = 'Get Firmware', command = self.imeiGet)

		self.imeiLabel.pack(side = Tkinter.LEFT)
		self.imeiEntry.pack(side = Tkinter.LEFT, expand = True, fill = Tkinter.X)
		self.imeiButton.pack(side = Tkinter.LEFT, ipadx = 3)

		self.result = Tkinter.Text(self, height = 15)
		self.result.config(state = Tkinter.DISABLED)
		font = tkFont.Font(size = 10)
		self.result.tag_configure('output', font = font)

		self.buttonFrame = Tkinter.Frame(self)
		self.cliButton = Tkinter.Button(self.buttonFrame, text = 'CLI Interface', command = self.cli, padx = 20)
		self.helpButton = Tkinter.Button(self.buttonFrame, text = 'Help', command = self.help, padx = 20)
		self.aboutButton = Tkinter.Button(self.buttonFrame, text = 'About', command = self.about, padx = 20)

		self.cliButton.pack(side = Tkinter.LEFT, padx = 20)
		self.helpButton.pack(side = Tkinter.LEFT, padx = 20)
		self.aboutButton.pack(side = Tkinter.LEFT, padx = 20)

		self.buttonFrame.pack(anchor = Tkinter.CENTER)
		self.swFrame.pack(expand = True, fill = Tkinter.X)
		self.imeiFrame.pack(expand = True, fill = Tkinter.X)
		self.result.pack(expand = True, fill = Tkinter.BOTH)
	def setCountry(self, country):
		self.countrycode = [ i.country_code for i in self.countries if i.country == country ][0]
		models = self.lg.model_list(self.countrycode)
		models.sort()
		if len(models) == 0: models.append('')
		self.modelMenu.forget()
		self.modelMenu = Tkinter.OptionMenu(self.swFrame, self.model, *models, command = self.modelGet)
		self.modelMenu.grid(row = 1, column = 1, sticky = Tkinter.EW)
	def setResult(self, text):
		self.result.config(state = Tkinter.NORMAL)
		self.result.insert(Tkinter.END, text + '\n', 'output')
		self.result.see(Tkinter.END)
		self.result.config(state = Tkinter.DISABLED)
	def imeiGet(self):
		imei = self.imei.get()
		if not imei:
			tkMessageBox.showwarning(title = 'Warning', message = 'Please fill in IMEI')
			self.imeiEntry.focus_set()
			return
		try: self.setResult('IMEI: %s, Firmware: %s\n' % (imei, self.lg.auth_model_check2(imei)))
		except ResponseFail:
			tkMessageBox.showerror(title = 'Error', message = 'Invalid IMEI: %s' % imei)
			self.imei.set('')
	def modelGet(self, model):
		if not model: return
		res = ''
		for sw in self.lg.tool_mode_country_check(self.countrycode, model).itervalues():
			res += str(sw) + '\n'
		self.setResult(res)
	def about(self):
		tkMessageBox.showinfo('lg_kdz.py - About', '''Get Latest LGE Cell Phone Firmware

Author: Tommy Alex
Email: iptux7#gmail.com
Date: 2012-12-17 04:47''')
	def cli(self):
		tkMessageBox.showinfo('lg_kdz.py - CLI interface', '''lg_kdz.py - Get Latest LGE Cell Phone Firmware

Usage: lg_kdz.py IMEI
       lg_kdz.py CountryCode PhoneModel''')
	def help(self):
		tkMessageBox.showinfo('lg_kdz.py - Help', '''Get Latest LGE Cell Phone Firmware

You have two option:

 1. If you have a `LG Cell Phone', fill IMEI of
    your `Cell Phone', Click `Get Firmware' Button,
    then the result will be show in the big box.

 2. or using Country and Phone Model
    - Select Country from `Country' combo box
    - Select Model from `Model' combo box
    then the result will be show in the big box.

NOTE: Different Country have different Model!
      Some Country don't have any Model!''')


def main_ui():
	root = Tkinter.Tk()
	gui = LG_KDZ(root)
	gui.pack(expand = True, fill = Tkinter.BOTH)
	root.title('Get Latest LGE Cell Phone Firmware')
	root.resizable(False, False)
	root.mainloop()


def main(argv):
	if len(argv) == 2:
		print LGMobile().auth_model_check2(argv[1])
	elif len(argv) == 3:
		for sw in LGMobile().tool_mode_country_check(argv[1], argv[2]).itervalues():
			print str(sw)
	else:
		main_ui()


#################################################
# test code

def _batch():
	csv = open('lg_kdz.csv', 'wb+')
	csv.write('model,region,country,chip_type,prod_type,buyer_name,swversion,live_date,firmware,\n')
	lg = LGMobile()
	for country in lg.ftp_country_info():
		ccode = country.country_code
		for model in lg.model_list(ccode):
			print ccode, model
			for sw in lg.tool_mode_country_check(ccode, model).itervalues():
				csv.write(sw.csv() + '\n')
	csv.close()


def _batch2(model):
	csv = open('lg_kdz.%s.csv' % (model), 'wb+')
	csv.write('model,region,country,chip_type,prod_type,buyer_name,swversion,live_date,firmware,\n')
	lg = LGMobile()
	for country in lg.ftp_country_info():
		ccode = country.country_code
		print ccode, model
		for sw in lg.tool_mode_country_check(ccode, model).itervalues():
			csv.write(sw.csv() + '\n')
	csv.close()


if __name__ == '__main__':
	#_batch2('LGP350')
	main(sys.argv)

