window.Game = {} unless window.Game

# Set to true to enable debug features
debug = true

cursors = null
wasd = null
shakeWorld = 0

PI = Math.PI
QUARTER_PI = PI * 0.25
HALF_PI = PI * 0.5
THREE_QUARTER_PI = PI * 0.75

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
  spideyPlaceChestOnTile: (state, tileX, tileY, callback) ->
    state.spider.grabChest(state.chest)
    state.spider.setTarget(Helpers.getEntityPositionForTile(tileX, tileY))
    state.spider.resetPosition()
    state.spider.lowerToTarget(() ->
      state.spider.releaseChest(state.chest)
      state.spider.raiseFromTarget(callback))


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

  chainCallback: (o, n) ->
    () ->
      n?.apply(null, arguments)
      o?.apply(null, arguments)

  getDirectionFromAngle: (angle) ->
    if angle >= -QUARTER_PI && angle < QUARTER_PI
      DIRECTION.right
    else if (angle >= THREE_QUARTER_PI && angle <= PI) || (angle >= -PI && angle < -THREE_QUARTER_PI)
      DIRECTION.left
    else if angle >= QUARTER_PI && angle < THREE_QUARTER_PI
      DIRECTION.down
    else
      DIRECTION.up
  zeroTimeout: (c) ->
    setTimeout(c, 0)


class KeymapEntry
  constructor: () ->
    @keys = []

  add: (key) ->
    @keys.push(key)

  isDown: () ->
    for key in @keys
      return true if key.isDown
    false

keymap =
  up: new KeymapEntry(),
  down: new KeymapEntry(),
  left: new KeymapEntry(),
  right: new KeymapEntry()


class ForceMoveDirection
  constructor: (amount, callback) ->
    @amount = amount
    @callback = callback

  move: () ->
    if @hasFinished()
      @callback?()

  assignMovable: (movable) ->
    @movable = movable
    @onMovableAssigned?()

  hasFinished: 
    true

class ForceKnockbackMove extends ForceMoveDirection
  constructor: (amount, direction, callback) ->
    @direction = direction
    super(amount, callback)

  onMovableAssigned: () ->
    @start = game.time.now

  move: () ->
    switch @direction
      when DIRECTION.left
        @movable.sprite.body.velocity.x = -@amount
      when DIRECTION.right
        @movable.sprite.body.velocity.x = @amount
      when DIRECTION.up
        @movable.sprite.body.velocity.y = -@amount
      when DIRECTION.down
        @movable.sprite.body.velocity.y = @amount

    super()

  hasFinished: () ->
    game.time.now > @start + 250

class ForceMoveDirectionUp extends ForceMoveDirection
  constructor: (amount, callback) ->
    super(amount, callback)

  onMovableAssigned: () ->
    @start = @movable.sprite.y
    
  move: () ->
    @movable.move(DIRECTION.up)
    super()
    
  hasFinished: () ->
    @movable.sprite.y < @start - @amount
 
class ForceMoveDirectionDown extends ForceMoveDirection
  constructor: (amount, callback) ->
    super(amount, callback)

  onMovableAssigned: () ->
    @start = @movable.sprite.y

  move: () ->
    @movable.move(DIRECTION.down)
    super()
    
  hasFinished: () ->
    @movable.sprite.y > @start + @amount

class ForceMoveDirectionLeft extends ForceMoveDirection
  constructor: (amount, callback) ->
    super(amount, callback)

  onMovableAssigned: () ->
    @start = @movable.sprite.x

  move: () ->
    @movable.move(DIRECTION.left)
    super()
    
  hasFinished: () ->
    @movable.sprite.x < @start - @amount

class ForceMoveDirectionRight extends ForceMoveDirection
  constructor: (amount, callback) ->
    super(amount, callback)

  onMovableAssigned: () ->
    @start = @movable.sprite.x

  move: () ->
    @movable.move(DIRECTION.right)
    super()
    
  hasFinished: () ->
    @movable.sprite.x > @start + @amount

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
    shakeWorld = 0

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

class Movable
  move: (direction) ->
    switch direction
      when DIRECTION.up then @onMoveUp?()
      when DIRECTION.down then @onMoveDown?()
      when DIRECTION.left then @onMoveLeft?()
      when DIRECTION.right then @onMoveRight?()
      when DIRECTION.none then @onMoveStop?()

  forceMove: (m) ->
    @activeForceMove = m
    m.assignMovable(this)
    @activeForceMove.callback = Helpers.chainCallback(@activeForceMove.callback, () =>
      @move(DIRECTION.none)
      @activeForceMove = null)
      

  update: () ->
    @activeForceMove.move() if @activeForceMove?

# Player is the player object
class Player extends Movable

  MOVEMENT_SPEED: 150
  
  constructor: () ->
    @health = new HealthMeter(10, 10, 6)

    @inputActive = true
    
    @sprite = game.add.sprite(256, 640, 'player')
    @sprite.animations.add('left', [0, 3, 0, 1], 7, true)
    @sprite.animations.add('right', [4, 5, 4, 7], 7, true)
    @sprite.animations.add('down', [8, 9, 10, 11], 7, true)
    @sprite.animations.add('up', [12, 13, 14, 15], 7, true)

    game.physics.arcade.enable(@sprite)
    @sprite.body.setSize(40, 64, 10, 0)
    @activeForceMove = null
    @sprite.body.collideWorldBounds = true

  onMoveUp: () ->
    @sprite.body.velocity.y = -@MOVEMENT_SPEED
    @sprite.animations.play('up')

  onMoveDown: () ->
    @sprite.body.velocity.y = @MOVEMENT_SPEED
    @sprite.animations.play('down')

  onMoveLeft: () ->
    @sprite.body.velocity.x = -@MOVEMENT_SPEED
    @sprite.animations.play('left')

  onMoveRight: () ->
    @sprite.body.velocity.x = @MOVEMENT_SPEED
    @sprite.animations.play('right')

  onMoveStop: () ->
    @sprite.body.velocity.x = 0
    @sprite.body.velocity.y = 0
    @sprite.animations.stop()

  handleInput: () ->
    if keymap.left.isDown()
      @move(DIRECTION.left)
    else if keymap.right.isDown()
      @move(DIRECTION.right)
    else
      @sprite.body.velocity.x = 0

    if keymap.up.isDown()
      @move(DIRECTION.up)
    else if keymap.down.isDown()
      @move(DIRECTION.down)
    else
      @sprite.body.velocity.y = 0

  forceMove: (f) ->
    @inputActive = false    
    f.callback = Helpers.chainCallback(f.callback, () => @inputActive = true)
    super(f)
    
  update: () ->
    super()

    @sprite.z = Helpers.getZIndex(LEVEL_TILE_SIZE.width, Math.floor((@sprite.y + 26) / TILE_PIXEL_SIZE.height)) + 0.5

    @handleInput() if @inputActive

    if @sprite.body.velocity.x == 0 && @sprite.body.velocity.y == 0
      @sprite.animations.stop()

  takeDamage: (source) ->
    unless @activeForceMove?
      direction = Helpers.getDirectionFromAngle(Phaser.Math.angleBetweenPoints(source.sprite.position, @sprite.position))
      @forceMove(new ForceKnockbackMove(300, direction, () -> {}))
      @health.update(source.damage)

HEART_STATES =
  full: 0
  half: 1
  empty: 2

class HealthMeter
  constructor: (x, y, max) ->
    @hearts = []
    @max = max
    @current = max

    @hearts.push(new Heart(x, y, i, 0)) for i in [0...@max / 2]
      

  update: (damage) ->
    @current -= damage

    floor = Math.floor(@current / 2)
    ceiling = Math.ceil(@current / 2)

    for i in [0...@max / 2]
      if i < floor
        @hearts[i].setState(HEART_STATES.full)
      else if i == floor && floor != ceiling
        @hearts[i].setState(HEART_STATES.half)
      else
        @hearts[i].setState(HEART_STATES.empty)


class Heart
  constructor: (x, y, index, state) ->
    @sprite = game.add.sprite(x + (32 * index), y, 'heart', state)
    @sprite.z = 100000

  setState: (state) ->
    @sprite.frame = state


class Chest
  constructor: () ->
    @sprite = game.add.sprite(640, 192, 'chest')
    game.physics.arcade.enable(@sprite);
    @sprite.body.setSize(45, 5, 20, 30);
    @sprite.body.immovable = true    

  update: () ->
    if @forceZ?
      @sprite.z = @forceZ
    else
      @sprite.z = Helpers.getZIndex(LEVEL_TILE_SIZE.width, Math.floor((@sprite.y + 26) / TILE_PIXEL_SIZE.height)) + 0.1

class Monster
  constructor: (x, y, type, health, damage) ->
    @health = health
    @damage = damage

    @sprite = game.add.sprite(0, 0, type)
    @sprite.position = Helpers.getEntityPositionForTile(x, y)
    @sprite.animations.add('idle', [0, 1, 2, 3, 4, 5, 6, 7], 14, true)

    game.physics.arcade.enable(@sprite)
    @sprite.body.setSize(40, 64, 10, 0)
    @sprite.body.immovable = true

  update: () ->
    @sprite.z = Helpers.getZIndex(LEVEL_TILE_SIZE.width, Math.floor((@sprite.y + 26) / TILE_PIXEL_SIZE.height)) + 0.1
    @sprite.animations.play('idle')

  takeDamage: (dmg) ->
    @health = @health - dmg

class SpiderThief extends Movable
  constructor: () ->
    @sprite = game.add.sprite(-100, -100, 'spiderThief', @sprite)
    @sprite.animations.add('wriggle', [0, 1, 2, 3, 2, 1], 7, true)
    @sprite.animations.play('wriggle')
    game.physics.arcade.enable(@sprite)
    
  setTarget: (p) ->
    @targetPosition =
      x: p.x - 32
      y: p.y - 32
    @forceZ = Helpers.getZIndex(
      LEVEL_TILE_SIZE.width,
      Math.floor((p.y + 32) / TILE_PIXEL_SIZE.height)) + 0.8

  onMoveDown: () ->
    @sprite.body.velocity.y = 250

  onMoveUp: () ->
    @sprite.body.velocity.y = -250

  onMoveStop: () ->
    @sprite.body.velocity.y = 0

  resetPosition: () ->
    @sprite.position =
      x: @targetPosition.x
      y: -128

  lowerToTarget: (callback) ->
    @forceMove(new ForceMoveDirectionDown(@targetPosition.y - @sprite.position.y, callback))

  raiseFromTarget: (callback) ->
    @forceMove(new ForceMoveDirectionUp(Math.abs(-128 - @targetPosition.y), callback))

  grabChest: (chest) ->
    chest.sprite.anchor = { x: 0, y: 0 }
    chest.sprite.position = { x: 32, y: 0 }
    chest.sprite.z = 0
    chest.forceZ = 0
    @sprite.addChild(chest.sprite)

  releaseChest: (chest) ->
    apos = chest.sprite.toGlobal({x: 0, y: 0})
    apos.y += 32
    @sprite.removeChild(chest.sprite)
    game.world.add(chest.sprite)
    chest.sprite.position = apos
    chest.sprite.anchor = { x: 0, y: 0 }
    chest.forceZ = null
    
  update: () ->
    super()

    @sprite.z = @forceZ

class Trap
  constructor: () ->
    @sprite = game.add.sprite(0, 0, 'flameGrate')
    @sprite.animations.add('idle', [0], 1, false)
    @sprite.animations.add('warmup', [1, 2, 3, 4], 5, false)
    @sprite.animations.add('sprout', [5, 6, 7, 6], 10, true)
    @sprite.animations.add('cooldown', [6, 7, 8, 4, 3, 2], 10, false)
    @sprite.animations.play('idle')
    @sprite.anchor = {x:0, y: 10}
    @chooseNextFireTime()
    @state = 'idle'
    @sprite.events.onAnimationComplete.add((e, a) =>
      if a.name == 'warmup'
        @state = 'sprout'
        @sprite.animations.play('sprout')
        @chooseNextFireTime()
      if a.name == 'cooldown'
        @state = 'idle'
        @sprite.animations.play('idle')
        @chooseNextFireTime())
      

  chooseNextFireTime: () ->
    @fireTime = game.time.now + 2000 + (Math.floor(Math.random() * 500))

  attachTo: (tile) ->
    @sprite.anchor = { x: 0, y: 0 }
    @sprite.position = { x: 0, y: -10 }
    tile.sprite.addChild(@sprite)
    @attachedTo = tile

  update: () ->
    @sprite.tint = @attachedTo.sprite.tint if @attachedTo?

    if game.time.now > @fireTime
      if @state == 'idle'
        @state = 'warmup'
        @sprite.animations.play("warmup")
      if @state == 'sprout'
        @state = 'cooldown'
        @sprite.animations.play("cooldown")
    
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
    for monster in @monsterEntities
        monster.sprite.kill()

    @level?.cleanup?(this)
    @level = level
    shakeWorld = 1
    for y in [0...LEVEL_TILE_SIZE.height]
      for x in [0...LEVEL_TILE_SIZE.width]
        tileIndex = @getTileIndex(x,y)
        tile = @getTile(x,y)# @tiles[tileIndex]
        tile.state(level.data[tileIndex])

    @level?.start?(this)

  nextLevel: () ->
    @currentLevel++ if @currentLevel?
    @currentLevel = 0 unless @currentLevel?

    @updateLevel(window.Game.levels[@currentLevel])

  levelTransition: () ->
    unless @transitioning
      @transitioning = true
      @spider.setTarget(@chest.sprite.position)
      @spider.resetPosition()
      @spider.lowerToTarget(() =>
        @spider.grabChest(@chest)
        @spider.raiseFromTarget(() =>
          @nextLevel()
          @transitioning = false))
    
  preload: () ->
    game.time.advancedTiming = true
    game.load.spritesheet('blocks', '../content/sprites/blocks.png', 64, 128)
    game.load.spritesheet('player', '../content/sprites/player.png', 64, 64)
    game.load.spritesheet('heart', '../content/sprites/heart.png', 32, 32)
    game.load.image('chest', '../content/sprites/chest.png')
    game.load.spritesheet('slime', '../content/sprites/slime.png', 64, 64)
    game.load.spritesheet('spiderThief', '../content/sprites/spider.png', 128 ,128)
    game.load.spritesheet('flameGrate', '../content/sprites/fire.png', 64, 74)

  setupKeyboard: () ->
    addToKeyMap = (maps) ->
      for mapKey, key of maps
        keymap[mapKey].add(key) if keymap[mapKey]?

    addToKeyMap(game.input.keyboard.createCursorKeys())
    addToKeyMap(
      up: game.input.keyboard.addKey(Phaser.Keyboard.W)
      down: game.input.keyboard.addKey(Phaser.Keyboard.S)
      left: game.input.keyboard.addKey(Phaser.Keyboard.A)
      right: game.input.keyboard.addKey(Phaser.Keyboard.D))

  create: () ->
    @tiles = []
    @entities = []
    @criticalEntities = []
    @monsterEntities = []

    game.physics.startSystem(Phaser.Physics.ARCADE)
    @setupKeyboard()

    @createTiles()
    @player = new Player()
    @chest = new Chest()
    @spider = new SpiderThief()
    @criticalEntities.push(@player)
    @criticalEntities.push(@chest)
    @criticalEntities.push(@spider)
    @nextLevel()

    if debug
      debugKey = game.input.keyboard.addKey(Phaser.Keyboard.TILDE)
      debugKey.onDown.add () =>
        console.log(Helpers.levelDataToString(@tiles))
        
  update: () ->
    for entity in @criticalEntities
      entity.update?()

    for entity in @monsterEntities
      entity.update?()
    
    # Perform updates
    for entity in @entities
      entity.update?()
      
    # Do collision checks
    for tile in @tiles
      if tile.state() != TILE_STATES.Normal
        game.physics.arcade.collide(@player.sprite, tile.sprite)
        for monster in @monsterEntities
          game.physics.arcade.collide(monster.sprite, tile.sprite)

    for monster in @monsterEntities
      game.physics.arcade.collide(
        @player.sprite, monster.sprite, () => @player.takeDamage(monster))

    game.physics.arcade.collide(@player.sprite, @chest.sprite, () => @levelTransition())

    #if shakeWorld > 0
    #  @rand1 = game.rnd.integerInRange(-20,20)
    #  @rand2 = game.rnd.integerInRange(-20,20)
    #  game.world.setBounds(@rand1, @rand2, game.width + @rand1, game.height + @rand2)

    #if shakeWorld == 0
    #  game.world.setBounds(0, 0, game.width, game.height)

    # Sort sprites and groups in the world, so that z-order is correct
    game.world.sort()

  render: () ->
    game.debug.text(game.time.fps || '--', 2, 14, "#00ff00");
#    game.debug.renderInputInfo(16, 16)

game = new Phaser.Game 1280, 736, Phaser.WEBGL, '', allOnOne

window.Game.game = game
window.Game.TILE_STATES = TILE_STATES
window.Game.Helpers = Helpers
window.Game.Monster = Monster
window.Game.ForceMoveDirection = ForceMoveDirection
window.Game.ForceMoveDirectionUp = ForceMoveDirectionUp
window.Game.ForceMoveDirectionDown = ForceMoveDirectionDown
window.Game.ForceMoveDirectionLeft = ForceMoveDirectionLeft
window.Game.ForceMoveDirectionRight = ForceMoveDirectionRight
window.Game.Trap = Trap
