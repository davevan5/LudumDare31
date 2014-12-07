levels = [
  {
    data:  [
      1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
      1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0, 1, 1, 0, 0, 1,
      1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1,
      1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 1, 0, 1,-1, 1, 1, 1, 0, 1,
      1, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1,
      1, 0, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 1,
      1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0,-1, 0, 1, 0, 0, 0, 0, 0, 1,
      1, 1, 1, 1, 0, 1, 1, 1, 0, 1, 0, 1, 1, 1,-1, 1, 1, 1, 0, 1,
      1, 0, 0, 0, 0, 0, 0, 1, 0, 1,-1, 1, 0, 0, 0, 1, 0, 0, 0, 1,
      1, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 1,
      1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
    ]
    start: (state) ->
      state.chest.sprite.position = Helpers.getEntityPositionForTile(17, 8)
      state.player.sprite.position = Helpers.getEntityPositionForTile(4, 13)
      state.player.forceMove(DIRECTION.up, 256, () ->
        state.player.inputActive = false
        state.getTile(4, 10).state(TILE_STATES.Raised)
        next =  -> state.player.forceMove(DIRECTION.down, 0, -> state.player.sprite.body.collideWorldBounds = true)
        setTimeout(next, 1250)
      )
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
    start: (state) ->
      state.chest.sprite.position = Helpers.getEntityPositionForTile(17, 8)
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

DIRECTION =
  up: 0
  down: 1
  left: 2
  right: 3
  none: 4

Helpers =
  getEntityPositionForTile: (tileX, tileY) ->
      x: tileX * TILE_PIXEL_SIZE.width
      y: tileY * TILE_PIXEL_SIZE.height + TILE_LOWERED_OFFSET
    
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

class ForceMoveDirection
  constructor: (moveable, amount) ->
    @moveable = moveable
    @amount = amount

  hasFinished: 
    true

class ForceMoveDirectionUp extends ForceMoveDirection
  constructor: (moveable, amount) ->
    super(moveable, amount)
    @start = moveable.sprite.y

  move: () ->
    @moveable.move(DIRECTION.up)
    
  hasFinished: () ->
    @moveable.sprite.y < @start - @amount
 
class ForceMoveDirectionDown extends ForceMoveDirection
  constructor: (moveable, amount) ->
    super(moveable, amount)
    @start = moveable.sprite.y

  move: () ->
    @moveable.move(DIRECTION.down)
    
  hasFinished: () ->
    @moveable.sprite.y > @start + @amount

class ForceMoveDirectionLeft extends ForceMoveDirection
  constructor: (moveable, amount) ->
    super(moveable, amount)
    @start = moveable.sprite.x

  move: () ->
    @moveable.move(DIRECTION.left)
    
  hasFinished: () ->
    @moveable.sprite.x < @start - @amount

class ForceMoveDirectionRight extends ForceMoveDirection
  constructor: (moveable, amount) ->
    super(moveable, amount)
    @start = moveable.sprite.x

  move: () ->
    @moveable.move(DIRECTION.right)
    
  hasFinished: () ->
    @moveable.sprite.x > @start + @amount

FORCEMOVE_DIRECTION_MAP = {}
FORCEMOVE_DIRECTION_MAP[DIRECTION.left] = ForceMoveDirectionLeft
FORCEMOVE_DIRECTION_MAP[DIRECTION.right] = ForceMoveDirectionRight
FORCEMOVE_DIRECTION_MAP[DIRECTION.up] = ForceMoveDirectionUp
FORCEMOVE_DIRECTION_MAP[DIRECTION.down] = ForceMoveDirectionDown

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
  MOVEMENT_SPEED: 150
  
  constructor: () ->
    @inputActive = true
    
    @sprite = game.add.sprite(256, 640, 'player')
    @sprite.animations.add('left', [0, 3, 0, 1], 7, true)
    @sprite.animations.add('right', [4, 5, 4, 7], 7, true)
    @sprite.animations.add('down', [8, 9, 10, 11], 7, true)
    @sprite.animations.add('up', [12, 13, 14, 15], 7, true)

    game.physics.arcade.enable(@sprite)
    @sprite.body.setSize(40, 64, 10, 0)
    @activeForceMove = null
    #@sprite.body.collideWorldBounds = true

  move: (direction) ->
    switch direction
      when DIRECTION.up
        @sprite.body.velocity.y = -@MOVEMENT_SPEED
        @sprite.animations.play('up')
      when DIRECTION.down
        @sprite.body.velocity.y = @MOVEMENT_SPEED
        @sprite.animations.play('down')
      when DIRECTION.left
        @sprite.body.velocity.x = -@MOVEMENT_SPEED
        @sprite.animations.play('left')
      when DIRECTION.right
        @sprite.body.velocity.x = @MOVEMENT_SPEED
        @sprite.animations.play('right')
      else
        @sprite.body.velocity.x = 0
        @sprite.body.velocity.y = 0
        @sprite.animations.stop()


  handleInput: () ->
    if cursors.left.isDown
      @move(DIRECTION.left)
    else if cursors.right.isDown
      @move(DIRECTION.right)
    else
      @sprite.body.velocity.x = 0

    if cursors.up.isDown
      @move(DIRECTION.up)
    else if cursors.down.isDown
      @move(DIRECTION.down)
    else
      @sprite.body.velocity.y = 0

  forceMove: (direction, amount, callback) ->
    type = FORCEMOVE_DIRECTION_MAP[direction]
    
    if type?
      @activeForceMove = new type(this, amount)
      @activeForceMove.callback = callback
      @inputActive = false
    
  update: () ->
    @sprite.z = Helpers.getZIndex(LEVEL_TILE_SIZE.width, Math.floor((@sprite.y + 26) / TILE_PIXEL_SIZE.height)) + 0.5

    @handleInput() if @inputActive

    if @activeForceMove?
      @activeForceMove.move()
      if @activeForceMove.hasFinished()
        @move(DIRECTION.none)
        @inputActive = true
        @activeForceMove.callback?(this)
        @activeForceMove = null

    if @sprite.body.velocity.x == 0 && @sprite.body.velocity.y == 0
      @sprite.animations.stop()

class Chest
  constructor: () ->
    @sprite = game.add.sprite(640, 192, 'chest')
    game.physics.arcade.enable(@sprite);
    @sprite.body.setSize(45, 5, 20, 30);
    @sprite.body.immovable = true    

  update: () ->
    @sprite.z = Helpers.getZIndex(LEVEL_TILE_SIZE.width, Math.floor((@sprite.y + 26) / TILE_PIXEL_SIZE.height)) + 0.1
      
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
        @entities.push(tile)
        
  updateLevel: (level) ->
    @level?.cleanup?(this)
    @level = level
    
    for y in [0...LEVEL_TILE_SIZE.height]
      for x in [0...LEVEL_TILE_SIZE.width]
        tileIndex = @getTileIndex(x,y)
        tile = @getTile(x,y)# @tiles[tileIndex]
        tile.state(level.data[tileIndex])

    @level?.start?(this)
    
  preload: () ->
    game.time.advancedTiming = true
    game.load.spritesheet('blocks', '../content/sprites/blocks.png', 64, 128)
    game.load.spritesheet('player', '../content/sprites/player.png', 64, 64)
    game.load.image('chest', '../content/sprites/chest.png')

  create: () ->
    @tiles = []
    @entities = []
    @criticalEntities = []
    game.physics.startSystem(Phaser.Physics.ARCADE)

    cursors = game.input.keyboard.createCursorKeys()

    @createTiles()
    @player = new Player()
    @chest = new Chest()
    @criticalEntities.push(@player)
    @criticalEntities.push(@chest)
    @updateLevel(levels[0])

    if debug
      debugKey = game.input.keyboard.addKey(Phaser.Keyboard.NUMPAD_0)
      debugKey.onDown.add () =>
        console.log(Helpers.levelDataToString(@tiles))
      
  update: () ->
    for entity in @criticalEntities
      entity.update?()
    
    # Perform updates
    for entity in @entities
      entity.update?()
      
    # Do collision checks
    for tile in @tiles
      if tile.state() != TILE_STATES.Normal
        game.physics.arcade.collide(@player.sprite, tile.sprite)

    game.physics.arcade.collide(@player.sprite, @chest.sprite, () => @updateLevel(levels[1]))

    # Sort sprites and groups in the world, so that z-order is correct
    game.world.sort()

  render: () ->
    game.debug.text(game.time.fps || '--', 2, 14, "#00ff00"); 
#    game.debug.renderInputInfo(16, 16)

game = new Phaser.Game 1280, 736, Phaser.WEBGL, '', allOnOne
