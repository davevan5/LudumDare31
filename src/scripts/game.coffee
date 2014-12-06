levels = [
  {
    data: [
      1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
      1, -1, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
      1, -1, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
      1, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1,
      1, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1,
      1, 0, 0, 1, 1, 1, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1,
      1, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1,
      1, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, -1, 0, 0, 0, 0, 0, 0, 1,
      1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
      1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
      1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
    ]
    start: null
    cleanup: null
  }, {
    data: [
      1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
      1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
      1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
      1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
      1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
      1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
      1, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
      1, 0, 1, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
      1, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
      1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
      1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
    ]
    start: null
    cleanup: null
  }
]
# Set to true to enable debug features
debug = true

cursors = null
player = null
chest = null
derp = true

LEVEL_TILE_SIZE =
  width: 20
  height: 11

TILE_PIXEL_SIZE =
  width: 64
  height: 64

TILE_LOWERED_OFFSET = 32

TILE_STATES =
  Depressed: -1
  Normal: 0
  Raised: 1

SHADOW_COLOR =
  from: 0x55
  to: 0xFF

BLOCK_TYPES = 4

Helpers =
  rgbToHex: (r, g, b) ->
    result = 0
    result = (Math.floor(r * 255) & 0xFF) << 16
    result = result | (Math.floor(g * 255) & 0xFF) << 8
    result = result | (Math.floor(b * 255) & 0xFF)
    result

  getTileIndex: (x,y) ->
    x + (y * LEVEL_TILE_SIZE.width)
    
  getZIndex: (x,y) ->
    x + (y * (LEVEL_TILE_SIZE.width + 1))

  logSprite: (sprite) ->
    console.log(sprite.x + "," + sprite.y + "," + sprite.z) if debug

  levelDataToString: (tiles) ->
    result = "["
    for y in [0...LEVEL_TILE_SIZE.height]
      result += "\n  "
      for x in [0...LEVEL_TILE_SIZE.width]
        state = tiles[Helpers.getTileIndex(x, y)].state()
        v = " "
        v = "" if state == -1
        result += v + state + ","
    result.substr(0, result.length - 1) + "]"

# LevelTile represents a single tile in the level
class LevelTile
  constructor: (x, y, z, blockType) ->
    @blockType = blockType
    @startLocation = { x: x * 64, y: y * 64 }
    @defaultz = z
    @mousePressed = false

    @raisedPosition = 0
    @tweenDirection = 0
    @currState = TILE_STATES.Normal
    @prevState = TILE_STATES.Normal
    
    @createSprite()

    @updateBlockDisplay()

    
  createSprite: () ->
    @sprite = game.add.sprite(@startLocation.x, @startLocation.y, 'blocks', @blockType)
    game.physics.arcade.enable(@sprite)
    @sprite.z = @defaultz
    @sprite.body.immovable = true
    @sprite.body.setSize(64, 30, 0, 34);
    @sprite.inputEnabled = true
    @sprite.events.onInputDown.add () =>
      if debug == true
        newState = @currState + 1
        newState = TILE_STATES.Depressed if newState > 1
        @state(newState)


  updateBlockDisplay: () ->
    @sprite.position = { x: @startLocation.x, y: @startLocation.y + (TILE_LOWERED_OFFSET * (1 - @raisedPosition)) }
    componentDiff = (SHADOW_COLOR.to - SHADOW_COLOR.from) / 0xFF
    raisedState = (@raisedPosition + 1) / 2
    component = 1 - (componentDiff * (1 - raisedState))
    @sprite.tint = Helpers.rgbToHex(component, component, component)

  expectedStateDirection: () ->
    @currState - @prevState
    
  hasStateChanged: () ->
    @prevState != @currState && @tweenDirection != @expectedStateDirection()

  commitState: () ->
    @prevState = @currState
    @tweenDirection = 0

  onStateChanged: () ->
    @tweenDirection = @expectedStateDirection()
    tween = game.add.tween(this).to({ raisedPosition: @currState }, 1000, Phaser.Easing.Linear.None)
    tween.onComplete.add () => @commitState()
    tween.start()
    
  update: () ->
    if @hasStateChanged()
      @onStateChanged()
      
    @sprite.z = @defaultz
    @updateBlockDisplay()

  state: (v) ->
    if v?
      @currState = v
      switch @currState
        when TILE_STATES.Depressed then @sprite.body.setSize(64, 10, 0, -30)
        when TILE_STATES.Raised then @sprite.body.setSize(64, 30, 0, 34)

    @currState

# Player is the player object
class Player
  constructor: () ->
    @sprite = game.add.sprite(256, 640, 'player')
    @sprite.animations.add('left', [0, 3, 0, 1], 7, true)
    @sprite.animations.add('right', [4, 5, 4, 7], 7, true)
    @sprite.animations.add('down', [8, 9, 10, 11], 7, true)
    @sprite.animations.add('up', [12, 13, 14, 15], 7, true)

    game.physics.arcade.enable(@sprite)
    @sprite.body.setSize(40, 64, 10, 0)
    @sprite.body.collideWorldBounds = true

  update: () ->
    @sprite.z = Helpers.getZIndex(LEVEL_TILE_SIZE.width, Math.floor((@sprite.y + 26) / TILE_PIXEL_SIZE.height)) + 0.5

    if cursors.left.isDown
      @sprite.body.velocity.x = -150
      @sprite.animations.play('left')
    else if cursors.right.isDown
      @sprite.body.velocity.x = 150
      @sprite.animations.play('right')
    else
      @sprite.body.velocity.x = 0

    if cursors.up.isDown
      @sprite.body.velocity.y = -150
      @sprite.animations.play('up')
    else if cursors.down.isDown
      @sprite.body.velocity.y = 150
      @sprite.animations.play('down')
    else
      @sprite.body.velocity.y = 0

    if @sprite.body.velocity.x == 0 && @sprite.body.velocity.y == 0
      @sprite.animations.stop()

# Default game state
allOnOne =
  getTileIndex: (x,y) ->
    x + (y * LEVEL_TILE_SIZE.width)

  getTile: (x,y) ->
    @tiles[@getTileIndex(x,y)]
    
  createTiles: () ->
    for y in [0...LEVEL_TILE_SIZE.height]
      for x in [0...LEVEL_TILE_SIZE.width]
        type = Math.floor(Math.random() * BLOCK_TYPES)
        z = Helpers.getZIndex(x, y)
        tile = new LevelTile(x, y, z, type)
        @tiles.push(tile)
        
  updateLevel: (level) ->
    @level.cleanup(this) if @level?.cleanup?
    @level = level
    
    for y in [0...LEVEL_TILE_SIZE.height]
      for x in [0...LEVEL_TILE_SIZE.width]
        tileIndex = @getTileIndex(x,y)
        tile = @getTile(x,y)# @tiles[tileIndex]
        tile.state(level.data[tileIndex])

    @level.start(this) if @level?.start?
    
  preload: () ->
    game.load.spritesheet('blocks', '../content/sprites/blocks.png', 64, 128)
    game.load.spritesheet('player', '../content/sprites/player.png', 64, 64)
    game.load.image('chest', '../content/sprites/chest.png')

  create: () ->
    @tiles = []
    game.physics.startSystem(Phaser.Physics.ARCADE)

    chest = game.add.sprite(640, 192, 'chest')
    game.physics.arcade.enable(chest);
    chest.body.setSize(45, 5, 20, 30);
    chest.body.immovable = true    



    cursors = game.input.keyboard.createCursorKeys()
    @player = new Player()
    @createTiles()
    @updateLevel(levels[0])

    if debug
      debugKey = game.input.keyboard.addKey(Phaser.Keyboard.NUMPAD_0)
      debugKey.onDown.add () =>
        console.log(Helpers.levelDataToString(@tiles))
      
  update: () ->
    chest.z = Helpers.getZIndex(LEVEL_TILE_SIZE.width, chest.y / TILE_PIXEL_SIZE.height)

    for tile in @tiles
      if tile.state() != TILE_STATES.Normal
        game.physics.arcade.collide(@player.sprite, tile.sprite)

    @player.update()
    tile.update() for tile in @tiles

    game.physics.arcade.collide(@player.sprite, chest, () => @updateLevel(levels[1]))

    game.world.sort()

game = new Phaser.Game 1280, 736, Phaser.WEBGL, '', allOnOne
