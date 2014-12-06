class Player
  constructor: (x, y) ->
    @player = game.add.sprite(x, y, 'player')

  update: () ->
    if (cursors.left.isDown)
      @player.body.velocity.x = -150
    else if (cursors.right.isDown)
      @player.body.velocity.x = 150
    else
      @player.body.velocity.x = 0

    if (cursors.up.isDown)
      @player.body.velocity.y = -150
    else if (cursors.down.isDown)
      @player.body.velocity.y = 150
    else
      @player.body.velocity.y = 0