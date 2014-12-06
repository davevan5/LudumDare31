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
    @sprite = game.add.sprite(x * 64, y * 64, 'floor')

  update: () ->

allOnOne =
  tiles: []

  createTiles: () ->
    for x in [0...LEVEL_TILE_SIZE.width]
      for y in [0...LEVEL_TILE_SIZE.height]
        this.tiles.push(new LevelTile(x, y, game))

  getTile: (x,y) ->
    index = x + (y * LEVEL_TILE_SIZE.width)
    tiles[index]

  preload: () ->
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
