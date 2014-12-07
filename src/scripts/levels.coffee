window.Game = {} unless window.Game?

window.Game.levels = [
  {
    data: [
      1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
      1, -1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0, 1, 1, 0, 0, 1,
      1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1,
      1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 1, 0, 1,-1, 1, 1, 1, 0, 1,
      1, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1,
      1, 0, 0, 1, 1, 1, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 1,
      1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0,-1, 0, 1, 0, 0, 0, 0, 0, 1,
      1, 1, 1, 1, 0, 1, 1, 1, 0, 1, 0, 1, 1, 1,-1, 1, 1, 1, 0, 1,
      1, 0, 0, 0, 0, 0, 0, 1, 0, 1,-1, 1, 0, 0, 0, 1, 0, 0, 0, 1,
      1, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 1,
      1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
    ]
    trap: null
    start: (state) ->
      state.monsterEntities.push(new Game.Monster(2, 4, 'slime', 20, 1))
      state.player.sprite.body.collideWorldBounds = false
      Game.Helpers.spideyPlaceChestOnTile(state, 17, 8)
      state.player.sprite.position =
       Game.Helpers.getEntityPositionForTile(4, 13)
      state.player.forceMove(new Game.ForceMoveDirectionUp(256, () =>
        state.player.inputActive = false
        state.getTile(4, 10).state(Game.TILE_STATES.Raised)
        next = () =>
          state.player.forceMove(new Game.ForceMoveDirectionDown(0, ->
            state.player.sprite.body.collideWorldBounds = true))

          @trap = new Game.Trap()
          @trap.attachTo(state.getTile(1, 1))
          state.entities.push(@trap)
          
          state.getTile(1,1).state(Game.TILE_STATES.Normal)
        setTimeout(next, 1250)))
    cleanup: (state) ->
      Game.Helpers.zeroTimeout () =>
        @trap.sprite.destroy();
  }, {
    data: [
      1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
      1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 1,
      1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1,
      1, 0, 0, 0,-1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 1, 1, 1, 1,
      1, 1, 0, 1,-1, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1,
      1, 0, 0, 0, 0, 0,-1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 1,-1, 1, 1,
      1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0,-1, 0, 0, 0, 0, 1,
      1,-1, 0, 0, 0, 0, 0,-1, 0, 0, 0, 1, 0, 0,-1, 0, 1, 1, 1, 1,
      1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1,
      1, 0, 0, 0,-1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 1,
      1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
    ]
    start: (state) ->
      Game.Helpers.spideyPlaceChestOnTile(state, 2, 2)
    cleanup: null
  }, {
    data: [
      1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
      1, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 1,
      1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1,
      1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 1,
      1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1,
      1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1,
      1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1,
      1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1,
      1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1,
      1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
      1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
    ]
    start: (state) ->
    cleanup: null
  }
]
