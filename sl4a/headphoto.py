# -*- coding: utf-8 -*-
#
# headphoto.py
# script to generate my headphoto
#
# Author: Alex.Wang
# Create: 2012-09-17 21:27


import DroidUi as Ui
from DroidUi import DroidDialog as Dialog


class HeadPhoto(Ui.RelativeLayout):
	def __init__(self, size = 9):
		self.value = [None] * (size * size)
		self.size = size
		Ui.RelativeLayout.__init__(self,
			background = '#7fffff7f',
			gravity = Ui.CENTER,
		)
		self.array = []
		row = [Ui.TextView(self,
					text = 0,
					layout_width = '34dp',
					layout_height = '34dp',
					background = '#7f0f0f00',
					layout_marginRight = '1.5dp',
					gravity = Ui.CENTER,
			)]
		for j in range(1, size - 1):
			row.append(Ui.TextView(self,
				text = j,
				layout_width = '34dp',
				layout_height = '34dp',
				background = '#7f0f%df00' % j,
				layout_toRightOf = '@id/' + row[j - 1].id,
				layout_marginRight = '1.5dp',
				gravity = Ui.CENTER,
			))
		row.append(Ui.TextView(self,
			text = size - 1,
			layout_width = '34dp',
			layout_height = '34dp',
			background = '#7f0f%df00' % (size - 1,),
			layout_toRightOf = '@id/' + row[size - 2].id,
			gravity = Ui.CENTER,
		))
		self.array.append(row)
		for i in range(1, size):
			row = [Ui.TextView(self,
					text = i * 9,
					layout_width = '34dp',
					layout_height = '34dp',
					background = '#7f%df0f00' % i,
					layout_below = '@id/' + self.array[i - 1][0].id,
					layout_marginTop = '1.5dp',
					gravity = Ui.CENTER,
			)]
			for j in range(1, size):
				row.append(Ui.TextView(self,
					text = i * 9 + j,
					layout_width = '34dp',
					layout_height = '34dp',
					background = '#7f%df%df00' % (i, j),
					layout_alignLeft = '@id/' + self.array[0][j].id,
					layout_alignTop = '@id/' + row[0].id,
					gravity = Ui.CENTER,
				))
			self.array.append(row)


if __name__ == '__main__':
	HeadPhoto().mainloop()

