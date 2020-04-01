# Tracer aim training mod

#!define debug_slots A

#!define PORTAL_1_TRACKING vect(6.163, 0.002, 2.483)
# vect(5.447, 0.001, -2.105)
# vect(5.563, 0.001, -6.298)
# vect(5.741, 0.001, -10.244)

# Setup infinite time and leave it be
@Rule "GAME SETUP | INIT | INFINITE TIME"
@Event global
  setMatchTime(817)
  pauseMatchTime()

@Rule "GAME SETUP INITIALIZE"
@Event global
  debug_slots = []

  createEffect(getAllPlayers(), Effect.RING, Color.GREEN, PORTAL_1_TRACKING, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  createInWorldText(getAllPlayers(), "Track non-moving", PORTAL_1_TRACKING + vect(0, 1, 0), 1, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.WHITE, SpecVisibility.NEVER)

@Rule "INTERACTION | SCENE 1"
@Event eachPlayer
if distance(eventPlayer.getPosition(), PORTAL_1_TRACKING) < 1 and eventPlayer.isCrouching():
  smallMessage(eventPlayer, "OK")


@Rule "DEBUG | DISTANCE FROM PORTAL 1"
@Event eachPlayer
hudText(eventPlayer, distance(eventPlayer.getPosition(), PORTAL_1_TRACKING), "", "", HudPosition.RIGHT, 0, Color.WHITE, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_SORT_ORDER_AND_STRING, SpecVisibility.NEVER)

# @Rule "DEBUG | SAVE POSITION"
# @Event eachPlayer
# @Team 1
# @Slot 0
# if eventPlayer.isCrouching() and eventPlayer.isFiringPrimaryFire():
#     debug_slots.append(eventPlayer.getPosition())
