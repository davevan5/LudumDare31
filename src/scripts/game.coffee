level = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1];

cursors = null
player = null
LEVEL_TILE_SIZE =
  width: 20
  height: 11

TILE_PIXEL_SIZE =
  width: 64
  height: 64
  
class LevelTile
  constructor: (x, y, game) ->
    @sprite = game.add.sprite(x * 64, y * 64, 'blocks', 5)

  update: () ->

  collidable: (v) ->    
    if v?
      @isCollidable = v
      if @isCollidable == true
        @sprite.frame = 0
      else
        @sprite.frame = 5
        
    @isCollidable

allOnOne =
  tiles: []

  getTileIndex: (x,y) ->
    x + (y * LEVEL_TILE_SIZE.width)

  getTile: (x,y) ->
    index = x + (y * LEVEL_TILE_SIZE.width)
    tiles[index]

  createTiles: () ->
    for x in [0...LEVEL_TILE_SIZE.width]
      for y in [0...LEVEL_TILE_SIZE.height]
        tile = new LevelTile(x, y, game)
        this.tiles.push(tile)
        
        tileIndex = this.getTileIndex(x,y)
        collidable = level[tileIndex] > 0
        tile.collidable(collidable)
        alert(tile.collidable())
        #tile.collidable(level[this.getTileIndex(x,y)] > 0)

  preload: () ->
    game.load.spritesheet('blocks', '../content/sprites/blocks.png', 64, 96)
    game.load.image('floor', '../content/sprites/floor.png')
    game.load.image('player', '../content/sprites/player.png')

  create: () ->
    cursors = game.input.keyboard.createCursorKeys()
    this.createTiles()
    player =game.add.sprite(256, 640, 'player')
    game.physics.enable(player, Phaser.Physics.ARCADE)
  
  update: () ->
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

    tile.update for tile in this.tiles

game = new Phaser.Game 1280, 720, Phaser.WEBGL, '', allOnOne
