#!/system/bin/bash
#
# python.sh
# execute python scripts in sl4a shell
#
# NOTE: android.Android is not support here


p4a_extra=/mnt/sdcard/com.googlecode.pythonforandroid/extras/python
export PYTHONHOME=/data/data/com.googlecode.pythonforandroid/files/python
export PYTHONPATH=${p4a_extra}:${p4a_extra}/plat-linux2:${p4a_extra}/site-packages:
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${PYTHONHOME}/lib

${PYTHONHOME}/bin/python $*

