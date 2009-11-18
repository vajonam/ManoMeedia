import xbmc
from xbmcgui import Window
from urllib import quote_plus, unquote_plus
import re
import sys
import os
import csv


class Main:
    # grab the home window
    WINDOW = Window( 10000 )

    def _clear_properties( self ):
        # reset Totals property for visible condition
        self.WINDOW.clearProperty( "Database.Totals" )
        # we enumerate thru and clear individual properties in case other scripts set window properties
        for count in range( self.LIMIT ):
            # we clear title for visible condition
            self.WINDOW.clearProperty( "LatestMovie.%d.Title" % ( count + 1, ) )
            self.WINDOW.clearProperty( "LatestEpisode.%d.ShowTitle" % ( count + 1, ) )
            self.WINDOW.clearProperty( "LatestSong.%d.Title" % ( count + 1, ) )


    def __init__( self ):
        # parse argv for any preferences
        # clear properties
        # self._clear_properties()
        self._fetch_xsp_info()

    def _fetch_xsp_info( self ):
	realpath = xbmc.translatePath("special://skin/scripts/xsplauncher/xsplauncher.config")
        myfile = csv.reader(open(realpath)) 
	for count, row in enumerate( myfile ):
            # set properties
	    count = count + 1
	    localizedString = xbmc.getLocalizedString( row[ 0 ] )
            self.WINDOW.setProperty( "XspLauncher.%d.StringId" % ( count ), localizedString )
            self.WINDOW.setProperty( "XspLauncher.%d.XspPath" % ( count ), row[ 1 ] )

if ( __name__ == "__main__" ):
    Main()
  
