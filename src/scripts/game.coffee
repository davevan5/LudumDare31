level = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1];

levelWidth=20
levelHeight=11
cursors = null
player = null
  
preload = () ->
  game.load.image('floor', '../content/sprites/floor.png')
  game.load.image('player', '../content/sprites/player.png')

create = () ->
  cursors = game.input.keyboard.createCursorKeys()

  for x in [0...levelWidth]
    for y in [0...levelHeight]
      game.add.sprite(x * 64, y * 64, 'floor') if level[x + (y * levelWidth)] == 1

  player = game.add.sprite(256, 640, 'player')
  game.physics.enable(player, Phaser.Physics.ARCADE)

update = () ->
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

game = new Phaser.Game 1280, 720, Phaser.WEBGL, '', { preload: preload, create: create, update: update }