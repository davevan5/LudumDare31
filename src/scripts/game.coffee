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

level2 = [
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
  1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
  1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1,
  1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1,
  1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1,
  1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1,
  1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1,
  1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1,
  1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1,
  1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
  1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
]

cursors = null
player = null
chest = null

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
  constructor: (x, y, z, blockType) ->
    @defaultz = z
    @startLocation = { x: x * 64, y: y * 64 }
    @sprite = game.add.sprite(x * 64, y * 64, 'blocks', blockType)
    @sprite.z = z
    @raisedPosition = 0
    @tween = null
    @tweenDirection = 0
    this.collidable(false)
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

    if @raisedPosition >= 1
      @sprite.z = @defaultz + 1000
    else
      @sprite.z = @defaultz

    this.updateBlockDisplay()

  collidable: (v) ->
    if v?
      @isCollidable = v
      if @isCollidable
        game.physics.arcade.enable(@sprite)
        @sprite.body.immovable = true
        @sprite.body.setSize(64, 64, 0, 32);
        
    @isCollidable

allOnOne =
  getTileIndex: (x,y) ->
    x + (y * LEVEL_TILE_SIZE.width)

  getTile: (x,y) ->
    result = @tiles[this.getTileIndex(x,y)]
    result

  getZIndex: (x,y) ->
    x + (y * (LEVEL_TILE_SIZE.width + 1))

  createTiles: () ->
    for y in [0...LEVEL_TILE_SIZE.height]
      for x in [0...LEVEL_TILE_SIZE.width]
        type = Math.floor(Math.random() * 5)
        z = this.getZIndex(x, y)
        tile = new LevelTile(x, y, z, type)
        @tiles.push(tile)
        
  updateLevel: (data) ->
    for y in [0...LEVEL_TILE_SIZE.height]
      for x in [0...LEVEL_TILE_SIZE.width]
        tileIndex = this.getTileIndex(x,y)
        console.log("Tile Index", tileIndex)
        tile = @tiles[tileIndex]
        console.log(tile)
        collidable = data[tileIndex] > 0
        tile.collidable(collidable)
    
  preload: () ->
    game.load.spritesheet('blocks', '../content/sprites/blocks.png', 64, 96)
    game.load.spritesheet('player', '../content/sprites/player.png', 64, 64)
    game.load.image('chest', '../content/sprites/chest.png')

  create: () ->
    @tiles = []
    game.physics.startSystem(Phaser.Physics.ARCADE)

    player = game.add.sprite(256, 640, 'player')
    chest = game.add.sprite(640, 192, 'chest')
    player.animations.add('left', [0, 3, 2, 1], 10, true);
    player.animations.add('right', [4, 5, 6, 7], 10, true);

    game.physics.arcade.enable(player);
    player.body.setSize(30, 30, 20, 30);
    player.body.collideWorldBounds = true;
    cursors = game.input.keyboard.createCursorKeys()
    this.createTiles()
    this.updateLevel(level)

    game.world.bringToTop(player)
  
  update: () ->
    player.z = 500

    for tile in this.tiles
      if tile.collidable()
        game.physics.arcade.collide(player, tile.sprite)

    if cursors.left.isDown
      player.body.velocity.x = -150
      player.animations.play('left')
    else if cursors.right.isDown
      player.body.velocity.x = 150
      player.animations.play('right')
    else
      player.body.velocity.x = 0
      player.animations.stop()

    if cursors.up.isDown
      player.body.velocity.y = -150
    else if cursors.down.isDown
      player.body.velocity.y = 150
    else
      player.body.velocity.y = 0

    tile.update() for tile in this.tiles

    game.world.bringToTop(chest)
    game.world.sort()

game = new Phaser.Game 1280, 736, Phaser.WEBGL, '', allOnOne
