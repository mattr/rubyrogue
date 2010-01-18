# config.rb - Configuration File
# This file constants constants that influence the appearance, behaviour or performance.
# These constants may be edited to reflect personal preferences.
#
# Should the game break, just revert to defaults noted in comments.

# MainWindow: window settings
# SCREEN_SIZE defines the size of window or full screen display. Default is [1024,768]
SCREEN_SIZE = [1024,768]
# FULLSCREEN = 0 by default starts the game in windowed mode; 1 sets full screen
FULLSCREEN = 0
# FPS_LIMIT - framerate at which the game will run. Default is 60 FPS (may be an overkill)
FPS_LIMIT = 60
# TILE_SIZE defines the size of an individual tile. Default is [16,16]
TILE_SIZE = [16,16]

#The below constants are automatically calculated, though you can use custom values.
# Defaults: SCREEN_SIZE[0]/TILE_SIZE[0] and SCREEN_SIZE[1]/TILE_SIZE[1] 
SCREEN_TILE_WIDTH = SCREEN_SIZE[0] / TILE_SIZE[0]
SCREEN_TILE_HEIGHT = SCREEN_SIZE[1] / TILE_SIZE[1]

# Tileset - the file must be in ./images/ folder
FILE_TILESET = "Cooz_16x16.png"

# Input delay in milliseconds
DELAY = 200

# World parameters
WORLD_SEED=0
WORLD_SIZE=[32,32]
REGION_SIZE=[32,32]