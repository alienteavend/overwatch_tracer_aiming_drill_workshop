# Tracer aim training mod
# Code: 9AFE8

#!define debug_slots A
#!define active_scene B
#!define stat_track_on_target C
#!define stat_track_tick D
#!define current_timer E


#!define results AA
#!define RESULT_STATIC_TRACK_HEAD_INDEX 0


#!define PORTAL_1_TRACKING vect(17.260, 0.002, -17.671)
#!define CENTER_DUMMY_POS vect(1.634, 0.001, -1.494)
#!define CENTER_PLAYER_POS vect(9.649, 0, -1.787)
#!define MENU_PLAYER_POS vect(10.459, 0.002, -12.034)
#!define MENU_PLAYER_EYE_POS vect(19.325, 0, -12.126)

#!define PLAYER getPlayers(Team.1)[0]
#!define THEBOT getPlayers(Team.2)[0]



#!define SCENE_INVALID -1
#!define SCENE_STATIC_TRACK_HEAD 0

#!define SCENE_STATIC_TRACK_HEAD_TIME 2

# vect(17.260, 0.002, -17.671)
# vect(13.755, 0.001, -17.671)
# vect(9.502, 0.001, -17.449)
# vect(5.480, 0.001, -17.405)
# vect(1.786, 0.001, -17.445)

# Setup infinite time and leave it be
@Rule "GAME SETUP | INIT | INFINITE TIME"
@Event global
  setMatchTime(817)
  pauseMatchTime()

@Rule "PLAYER SETUP"
@Event eachPlayer
@Team 1
if eventPlayer.isInSpawnRoom():
  PLAYER.teleport(MENU_PLAYER_POS)
  PLAYER.setFacing(directionTowards(PLAYER.getEyePosition(), MENU_PLAYER_EYE_POS), Relativity.TO_WORLD)

@Rule "GAME SETUP INITIALIZE"
@Event global
  debug_slots = []

  createEffect(getAllPlayers(), Effect.RING, Color.GREEN, PORTAL_1_TRACKING, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  createInWorldText(getAllPlayers(), "Track non-moving", PORTAL_1_TRACKING + vect(0, 1, 0), 1, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.WHITE, SpecVisibility.NEVER)

  active_scene = SCENE_INVALID
  current_timer = 0

  results = [0]

@Rule "INTERACTION | SCENE 1"
@Event eachPlayer
if distance(eventPlayer.getPosition(), PORTAL_1_TRACKING) < 1 and eventPlayer.isCrouching():
  
  smallMessage(eventPlayer, "Static drill - Track the bot's head")
  if len(getPlayers(Team.2)) == 0:
    createDummy(Hero.ANA, Team.2, -1, CENTER_DUMMY_POS, directionTowards(CENTER_DUMMY_POS, PLAYER.getPosition()))
  wait(0.2)
  THEBOT.startFacing(directionTowards(THEBOT.getPosition(), PLAYER.getPosition()), 360, Relativity.TO_WORLD, FacingReeval.DIRECTION_AND_TURN_RATE)
  # Reinit stats
  stat_track_tick = 0
  stat_track_on_target = 0
  
  # Handle player
  PLAYER.disallowButton(Button.PRIMARY_FIRE)
  PLAYER.teleport(CENTER_PLAYER_POS)
  PLAYER.setFacing(directionTowards(PLAYER.getEyePosition(), THEBOT.getEyePosition()), Relativity.TO_WORLD)
  current_timer = 0.001
  hudText(PLAYER, "", "" ,"Track rate: {}".format(stat_track_on_target/stat_track_tick * 100),HudPosition.TOP, 3, Color.GREEN, Color.GREEN, Color.GREEN, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
  hudText(PLAYER, "", "Timer for round", "{} / {}".format(SCENE_STATIC_TRACK_HEAD_TIME, current_timer), HudPosition.RIGHT, 0, Color.YELLOW, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER )

  # Timer setup
  wait(2)
  smallMessage(PLAYER, "START")
  chase(current_timer, SCENE_STATIC_TRACK_HEAD_TIME, rate=1, ChaseReeval.DESTINATION_AND_RATE)

  wait()
  active_scene = SCENE_STATIC_TRACK_HEAD

@Rule "SCENE 1 END : TIMER"
@Event global
if current_timer >= SCENE_STATIC_TRACK_HEAD_TIME:
  active_scene = SCENE_INVALID
  stopChasingVariable(current_timer)
  PLAYER.teleport(MENU_PLAYER_POS)
  PLAYER.setFacing(directionTowards(PLAYER.getEyePosition(), MENU_PLAYER_EYE_POS), Relativity.TO_WORLD)
  results[RESULT_STATIC_TRACK_HEAD_INDEX] = stat_track_on_target/stat_track_tick * 100
  wait()
  bigMessage(PLAYER, "Tracking result: {}".format(results[RESULT_STATIC_TRACK_HEAD_INDEX]))
  destroyAllHudTexts()
  hudText(PLAYER, "Tracking: {}".format(results[RESULT_STATIC_TRACK_HEAD_INDEX]), "", "", HudPosition.LEFT, 0, Color.YELLOW, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
  

@Rule "BOT | RESPAWN"
@Event playerDied
@Team 2
wait(3)
THEBOT.teleport(CENTER_DUMMY_POS)

@Rule "SCENE STATIC | TRACK HEAD | SCORES"
@Event eachPlayer
@Team 1
@Slot 0
if active_scene == SCENE_STATIC_TRACK_HEAD:
  do:
    stat_track_tick += 1
    if distance(vect(0, 0, 0), THEBOT.getEyePosition() - (eventPlayer.getEyePosition() + (abs(dotProduct(THEBOT.getEyePosition() - eventPlayer.getEyePosition(), eventPlayer.getFacingDirection()))) * eventPlayer.getFacingDirection())) <= 0.3:
      stat_track_on_target += 1

    wait()
  while RULE_CONDITION

@Rule "DEBUG | DISTANCE FROM PORTAL 1"
@Event eachPlayer
# hudText(eventPlayer, distance(eventPlayer.getPosition(), PORTAL_1_TRACKING), "", "", HudPosition.RIGHT, 0, Color.WHITE, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_SORT_ORDER_AND_STRING, SpecVisibility.NEVER)
# debug(distance(vect(0, 0, 0), THEBOT.getEyePosition() - (eventPlayer.getEyePosition() + (abs(dotProduct(THEBOT.getEyePosition() - eventPlayer.getEyePosition(), eventPlayer.getFacingDirection()))) * eventPlayer.getFacingDirection())))
# debug("Track rate: {}".format(stat_track_on_target/stat_track_tick * 100))

@Rule "DEBUG | SAVE POSITION"
@Event eachPlayer
@Team 1
@Slot 0
if eventPlayer.isCrouching() and eventPlayer.isFiringPrimaryFire():
    debug_slots.append(eventPlayer.getPosition())
