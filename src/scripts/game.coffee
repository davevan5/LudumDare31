level = [
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
  1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
  1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
  1, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
  1, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
  1, 0, 0, 1, 1, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
  1, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
  1, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
  1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
  1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
  1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
];

cursors = null
player = null

LEVEL_TILE_SIZE =
  width: 20
  height: 11

TILE_PIXEL_SIZE =
  width: 64
  height: 64

TILE_LOWERED_OFFSET = 32

Helpers =
  rgbToHex: (r, g, b) ->
    result = 0
    result = (Math.floor(r * 255) & 0xFF) << 16
    result = result | (Math.floor(g * 255) & 0xFF) << 8
    result = result | (Math.floor(b * 255) & 0xFF)
    result

class LevelTile
  constructor: (x, y, blockType) ->
    @startLocation = { x: x * 64, y: y * 64 }
    @sprite = game.add.sprite(x * 64, y * 64, 'blocks', blockType)
    @raisedPosition = 0
    @tween = null
    @tweenDirection = 0
    this.updateBlockDisplay()

  updateBlockDisplay: () ->
    @sprite.position = { x: @startLocation.x, y: @startLocation.y + (TILE_LOWERED_OFFSET * (1 - @raisedPosition)) }
    componentDiff = (0xFF - 0xCC) / 0xFF
    component = 1 - (componentDiff * (1 - @raisedPosition))
    @sprite.tint = Helpers.rgbToHex(component, component, component)
    
  update: () ->
    if @isCollidable
      if @raisedPosition < 1 && @tweenDirection == 0
        @tweenDirection = 1
        @tween = game.add.tween(this).to({ raisedPosition: 1 }, 1000, Phaser.Easing.Linear.None)
        @tween.start()
    else
      if @raisedPosition > 0 && @tweenDirection == 1
        @tweenDirection = 0
        @tween = game.add.tween(this).to({ raisedPosition: 0 }, 1000, Phaser.Easing.Linear.None)
        @tween.start()        

    this.updateBlockDisplay()

  collidable: (v) ->    
    @isCollidable = v if v?
    @isCollidable

allOnOne =
  tiles: []

  getTileIndex: (x,y) ->
    x + (y * LEVEL_TILE_SIZE.width)

  getTile: (x,y) ->
    index = x + (y * LEVEL_TILE_SIZE.width)
    this.tiles[index]

  createTiles: () ->
    for x in [0...LEVEL_TILE_SIZE.width]
      for y in [0...LEVEL_TILE_SIZE.height]
        type = Math.floor(Math.random() * 5)
        tile = new LevelTile(x, y, type)
        this.tiles.push(tile)
        
        tileIndex = this.getTileIndex(x,y)
        collidable = level[tileIndex] > 0
        tile.collidable(collidable)
        #tile.collidable(level[this.getTileIndex(x,y)] > 0)

  preload: () ->
    game.load.spritesheet('blocks', '../content/sprites/blocks.png', 64, 96)
    game.load.image('player', '../content/sprites/player.png')

  create: () ->
    cursors = game.input.keyboard.createCursorKeys()
    this.createTiles()
    player = game.add.sprite(256, 640, 'player')
    game.physics.enable(player, Phaser.Physics.ARCADE)
  
  update: (t) ->
    if (cursors.left.isDown)
      player.body.velocity.x = -150
    else if (cursors.right.isDown)
  	  player.body.velocity.x = 150
    else
      player.body.velocity.x = 0

    if (cursors.up.isDown)
      player.body.velocity.y = -150
    else if (cursors.down.isDown)
      player.body.velocity.y = 150
    else
      player.body.velocity.y = 0

    tile.update() for tile in this.tiles

game = new Phaser.Game 1280, 720, Phaser.WEBGL, '', allOnOne
