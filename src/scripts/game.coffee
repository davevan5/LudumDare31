level = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1];

cursors = null
player = null

LEVEL_TILE_SIZE =
  width: 20
  height: 11

TILE_PIXEL_SIZE =
  width: 64
  height: 64
  
class LevelTile
  constructor: (x, y, z, game) ->
    @sprite = game.add.sprite(x * 64, y * 64, 'blocks', 5)
    @sprite.z = z 

  update: () ->
    absz = Math.abs(@sprite.z)
    if @isCollidable
      @sprite.z = absz
    else
      @sprite.z = -absz

  collidable: (v) ->    
    if v?
      @isCollidable = v
      if @isCollidable == true
        @sprite.frame = 0
        game.physics.arcade.enable(@sprite)
        @sprite.body.immovable = true
        @sprite.body.setSize(64, 64, 0, 32);
      else
        @sprite.frame = 5
        
    @isCollidable

allOnOne =
  tiles: []

  getTileIndex: (x,y) ->
    x + (y * LEVEL_TILE_SIZE.width)

  getTile: (x,y) ->
    index = x + (y * (LEVEL_TILE_SIZE.width))
    tiles[index]

  getZIndex: (x,y) ->
    x + (y * (LEVEL_TILE_SIZE.width + 1))

  createTiles: () ->
    for y in [0...LEVEL_TILE_SIZE.height]
      for x in [0...LEVEL_TILE_SIZE.width]
        z = this.getZIndex(x, y)
        tile = new LevelTile(x, y, z, game)
        this.tiles.push(tile)
        
        tileIndex = this.getTileIndex(x,y)
        collidable = level[tileIndex] > 0
        tile.collidable(collidable)

  preload: () ->
    game.load.spritesheet('blocks', '../content/sprites/blocks.png', 64, 96)
    game.load.image('floor', '../content/sprites/floor.png')
    game.load.image('player', '../content/sprites/player.png')

  create: () ->
    game.physics.startSystem(Phaser.Physics.ARCADE)

    player = game.add.sprite(256, 640, 'player')
    game.physics.arcade.enable(player);
    player.body.setSize(30, 30, 17, 17);
    player.body.collideWorldBounds = true;
    cursors = game.input.keyboard.createCursorKeys()
    this.createTiles()

    game.world.bringToTop(player);
  
  update: () ->
    playerY = Math.floor(player.y / TILE_PIXEL_SIZE.height)
    player.z = this.getZIndex(LEVEL_TILE_SIZE.width, playerY)

    for tile in this.tiles
      if tile.collidable()
        game.physics.arcade.collide(player, tile.sprite)

    if cursors.left.isDown
      player.body.velocity.x = -150
    else if cursors.right.isDown
  	  player.body.velocity.x = 150
    else
      player.body.velocity.x = 0

    if cursors.up.isDown
      player.body.velocity.y = -150
    else if cursors.down.isDown
      player.body.velocity.y = 150
    else
      player.body.velocity.y = 0

    tile.update() for tile in this.tiles

    game.world.sort()

game = new Phaser.Game 1280, 736, Phaser.WEBGL, '', allOnOne
