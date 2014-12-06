level = [
  1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
  1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,
  1,0,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,
  1,0,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,
  1,0,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,
  1,0,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,
  1,0,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,
  1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,
  1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,
  1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,
  1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1];

levelWidth=20
levelHeight=11
  
preload = () ->
  game.load.image('floor', '../content/sprites/floor.png')

create = () ->
  for x in [0...levelWidth]
    for y in [0...levelHeight]
      game.add.sprite(x * 64, y * 64, 'floor') if level[x + (y * levelWidth)] == 1
  
  game.add.tilemap('test', 64, 64, 20, 11)

update = () ->
  # game logic here

game = new Phaser.Game 1280, 720, Phaser.WEBGL, '', { preload: preload, create: create, update: update }
