preload = () ->
  game.load.image('floor', '../content/sprites/floor.png')

create = () ->
  game.add.sprite(0, 0, 'floor')

update = () ->
  # game logic here

game = new Phaser.Game 1280, 720, Phaser.WEBGL, '', { preload: preload, create: create, update: update }