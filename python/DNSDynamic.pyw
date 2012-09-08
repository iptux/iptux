#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# DNSdynamic.py
# python client for http://www.dnsdynamic.org/ using webapi
#
# Author: Alex.wang
# Create: 2012-08-24 17:04


import base64
import urllib, urllib2
import ConfigParser
import Tkinter
import tkMessageBox


confile = 'DNSDynamic.conf'
APP_TITLE = u'DNS Dynamic'


gui = None


class DomainFrame(Tkinter.Frame):
	def __init__(self, master, domain = '', ip = ''):
		Tkinter.Frame.__init__(self, master)
		self.domain = Tkinter.StringVar(self, domain)
		self.ip = Tkinter.StringVar(self, ip)
		self.__widgets()
	def __widgets(self):
		self.domainLabel = Tkinter.Label(self, text = u'域名')
		self.domainEntry = Tkinter.Entry(self, textvariable = self.domain, width = 18)

		self.ipLabel = Tkinter.Label(self, text = u'地址')
		self.ipEntry = Tkinter.Entry(self, textvariable = self.ip, width = 15)

		self.getipButton = Tkinter.Button(self, text = u'获取ip', command = self.getip)
		self.refreshButton = Tkinter.Button(self, text = u'刷新', command = self.refresh)
		self.delButton = Tkinter.Button(self, text = u'删除', command = lambda e = self: gui.delDomain(e))

		self.domainLabel.pack(side = Tkinter.LEFT)
		self.domainEntry.pack(side = Tkinter.LEFT)
		self.ipLabel.pack(side = Tkinter.LEFT)
		self.ipEntry.pack(side = Tkinter.LEFT)
		self.getipButton.pack(side = Tkinter.LEFT)
		self.refreshButton.pack(side = Tkinter.LEFT)
		self.delButton.pack(side = Tkinter.LEFT)
	def getip(self):
		self.ip.set(urllib2.urlopen('http://myip.dnsd.info/').read())
	def refresh(self):
		d = self.domain.get()
		u = self.ip.get()
		s = u'域名或地址无效'
		if d and u:
			s = u'%s: %s' % (d, gui.refresh(d, u))
		tkMessageBox.showinfo(u'刷新结果', s)
	def __eq__(self, o):
		return self.domain.get() == o.domain.get()


class DNSDynamic(Tkinter.Frame):
	def __init__(self, master = None):
		Tkinter.Frame.__init__(self, master)
		self.config = ConfigParser.ConfigParser()
		self.config.read(confile)
		self.domains = []
		self.__widgets()
		sec = self.config.sections()
		sec.sort()
		for s in sec:
			self.addDomain(s, self.config.get(s, 'ip'))
	def destroy(self):
		self.saveConfig()
	def __widgets(self):
		self.setFrame = Tkinter.LabelFrame(self, text = u'账户设置')

		self.user = Tkinter.StringVar(self)
		try: self.user.set(self.config.get('DEFAULT', 'user'))
		except: pass
		self.userLabel = Tkinter.Label(self.setFrame, text = u'账户')
		self.userEntry = Tkinter.Entry(self.setFrame, textvariable = self.user)

		self.passwd = Tkinter.StringVar(self)
		try: self.passwd.set(self.config.get('DEFAULT', 'passwd'))
		except: pass
		self.passwdLabel = Tkinter.Label(self.setFrame, text = u'密码')
		self.passwdEntry = Tkinter.Entry(self.setFrame, textvariable = self.passwd, show = '*')

		self.userLabel.pack(side = Tkinter.LEFT)
		self.userEntry.pack(side = Tkinter.LEFT)
		self.passwdLabel.pack(side = Tkinter.LEFT)
		self.passwdEntry.pack(side = Tkinter.LEFT)

		self.domainFrame = Tkinter.LabelFrame(self, text = u'域名管理')

		self.btnFrame = Tkinter.Frame(self.domainFrame)
		self.addButton = Tkinter.Button(self.btnFrame, text = u'添加域名', command = self.addDomain)
		self.freshButton = Tkinter.Button(self.btnFrame, text = u'全部刷新', command = self.refreshAll)
		self.aboutButton = Tkinter.Button(self.btnFrame, text = u'关于', command = self.about)
		self.addButton.pack(side = Tkinter.LEFT, ipadx = 5, padx = 5)
		self.freshButton.pack(side = Tkinter.LEFT, ipadx = 5, padx = 5)
		self.aboutButton.pack(side = Tkinter.LEFT, ipadx = 5, padx = 5)
		self.btnFrame.pack()

		self.setFrame.pack()
		self.domainFrame.pack(fill = Tkinter.X)
	def addDomain(self, domain = '', ip = ''):
		frame = DomainFrame(self.domainFrame, domain, ip)
		if frame in self.domains:
			tkMessageBox.showinfo(APP_TITLE + u' - Info', u'域名 %s 已存在' % domain)
			return
		self.domains.append(frame)
		frame.pack(before = self.btnFrame)
	def delDomain(self, e):
		if e in self.domains:
			self.domains.remove(e)
			e.forget()
			del e
	def refreshAll(self):
		if len(self.domains) == 0:
			tkMessageBox.showinfo(u'更新结果', u'没有什么要更新的')
			return
		s = u'域名更新结果：\n'
		for f in self.domains:
			d = f.domain.get()
			i = f.ip.get()
			r = u'输入无效'
			if d and i:
				r = self.refresh(d, i)
			s += u'%s: %s\n' % (d, r)
		tkMessageBox.showinfo(u'更新结果', s)
	def refresh(self, domain, ip):
		try:
			u = self.user.get()
			p = self.passwd.get()
			r = u'请输入用户名和密码'
			if u and p:
				auth_encoded = base64.encodestring('%s:%s' % (u, p))
				req = urllib2.Request('https://www.dnsdynamic.org/api/?hostname=%s&myip=%s' % (domain, ip))
				req.add_header('Authorization', 'Basic %s' % auth_encoded)
				r = urllib2.urlopen(req).read()
			return r.strip()
		except Exception, e:
			return str(e)
	def saveConfig(self):
		self.config.set('DEFAULT', 'user', self.user.get())
		self.config.set('DEFAULT', 'passwd', self.passwd.get())
		for s in self.config.sections():
			self.config.remove_section(s)
		for f in self.domains:
			d = f.domain.get()
			u = f.ip.get()
			if d and u:
				self.config.add_section(d)
				self.config.set(d, 'ip', u)
		self.config.write(open(confile, 'w+'))
	def about(self):
		tkMessageBox.showinfo(APP_TITLE + u' - About', u'dnsdynamic.org Python版客户端\n\n作者：Alex.wang\nEmail：iptux7@gmail.com')


def main():
	global gui
	root = Tkinter.Tk()
	gui = DNSDynamic(root)
	gui.pack()
	root.resizable(False, False)
	root.title(APP_TITLE)
	root.mainloop()


if __name__ == '__main__':
	main()

