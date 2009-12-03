import xbmc
from xbmcgui import Window
# from urllib import quote_plus, unquote_plus
# import re
# import sys
# import os
# import csv
# import time


class Main:
    # grab the home window
    WINDOW = Window( 10000 )


    def __init__( self ):
        self._update_lib_and_latest();

    def _update_lib_and_latest ( self ):
        xbmc.output(msg='Udate script called' , level=xbmc.LOGDEBUG)
        xbmc.executebuiltin('UpdateLibrary(video)');
        xbmc.sleep(3000)
        while True :
                isScanning= xbmc.getCondVisibility('Library.IsScanning')
                xbmc.output(msg='Library started scanning ### ' + str(isScanning) , level=xbmc.LOGDEBUG)
                xbmc.sleep(1000)
                if not isScanning:
                        break
        xbmc.executescript('special://skin/scripts/latest/latest.py')


if ( __name__ == "__main__" ):
    Main()


