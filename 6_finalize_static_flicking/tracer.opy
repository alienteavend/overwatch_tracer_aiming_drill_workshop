# Tracer aim training mod
# Code: 2SVFW

# VARIABLES
#!define debug_slots A
#!define active_scene B
#!define stat_occurances C
#!define stat_ticks D
#!define current_timer E
#!define scenes F
#!define switch_scene G
#!define temp_sign_for_tp H
#!define is_bot_fresh I

#!define results AA
#!define RESULT_STATIC_TRACK_HEAD_INDEX 0
#!define RESULT_STATIC_FLICK_HEAD_INDEX 1

#!define tmp_timer_text_entity AB

# STATIC DRILLS: TRACK HEAD
#!define PORTAL_1_TRACKING vect(17.260, 0.002, -17.671)
#!define CENTER_DUMMY_POS vect(1.634, 0.001, -1.494)
#!define CENTER_PLAYER_POS vect(9.649, 0, -1.787)
#!define SCENE_STATIC_TRACK_HEAD_TIME 3

# STATIC DRILLS: FLICK BETWEEN TARGETS
#!define PORTAL_2_FLICKING vect(13.755, 0.001, -17.671)
#!define SCENE_STATIC_FLICK_TIME 5

# MENU RELATED
#!define MENU_PLAYER_POS vect(10.459, 0.002, -12.034)
#!define MENU_PLAYER_EYE_POS vect(19.325, 0, -12.126)

# GLOBAL
#!define PLAYER getPlayers(Team.1)[0]
#!define THEBOT getPlayers(Team.2)[0]

# SCENE ENUM
#!define SCENE_INVALID -1
#!define SCENE_STATIC_TRACK_HEAD 0
#!define SCENE_STATIC_FLICK_HEAD 1

# vect(17.260, 0.002, -17.671)
# vect(13.755, 0.001, -17.671)
# vect(9.502, 0.001, -17.671)
# vect(5.480, 0.001, -17.671)
# vect(1.786, 0.001, -17.671)

# Setup infinite time and leave it be
@Rule "GAME SETUP | INIT | INFINITE TIME"
@Event global
  setMatchTime(817)
  pauseMatchTime()

@Rule "PLAYER SETUP"
@Event eachPlayer
@Team 1
hudText(PLAYER, "Static tracking: {}".format(results[RESULT_STATIC_TRACK_HEAD_INDEX]), "", "", HudPosition.LEFT, 0, Color.YELLOW, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
hudText(PLAYER, "Static flicking: {}".format(results[RESULT_STATIC_FLICK_HEAD_INDEX]), "", "", HudPosition.LEFT, 0, Color.YELLOW, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)


@Rule "GAME SETUP INITIALIZE"
@Event global
  debug_slots = []

  createEffect(getAllPlayers(), Effect.RING, Color.GREEN, PORTAL_1_TRACKING, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  createInWorldText(getAllPlayers(), "Track non-moving", PORTAL_1_TRACKING + vect(0, 1, 0), 1, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.WHITE, SpecVisibility.NEVER)

  createEffect(getAllPlayers(), Effect.RING, Color.GREEN, PORTAL_2_FLICKING, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  createInWorldText(getAllPlayers(), "Flick non-moving", PORTAL_2_FLICKING + vect(0, 1, 0), 1, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.WHITE, SpecVisibility.NEVER)

  active_scene = SCENE_INVALID
  switch_scene = SCENE_INVALID
  current_timer = 0

  results = [0, 0]
  scenes = [
    PORTAL_1_TRACKING,
    PORTAL_2_FLICKING
  ]
  is_bot_fresh = true

@Rule "INTERACTION | SCENE RINGS"
@Event eachPlayer
@Team 1
if any([distance(eventPlayer.getPosition(), i) < 1 and eventPlayer.isCrouching() for i in scenes]):
  switch_scene = scenes.index([i for i in scenes if distance(eventPlayer.getPosition(), i) < 1 and eventPlayer.isCrouching()][0])

@Rule "INTERACTION | SCENE 1"
@Event eachPlayer
@Team 1
if switch_scene == SCENE_STATIC_TRACK_HEAD:
  switch_scene = SCENE_INVALID
  smallMessage(eventPlayer, "Static drill - Track the bot's head")
  if len(getPlayers(Team.2)) == 0:
    createDummy(Hero.ANA, Team.2, -1, CENTER_DUMMY_POS, directionTowards(CENTER_DUMMY_POS, PLAYER.getPosition()))
  wait(0.2)
  THEBOT.teleport(CENTER_DUMMY_POS)
  THEBOT.startFacing(directionTowards(THEBOT.getPosition(), PLAYER.getPosition()), 360, Relativity.TO_WORLD, FacingReeval.DIRECTION_AND_TURN_RATE)

  # Handle player
  PLAYER.disallowButton(Button.PRIMARY_FIRE)
  PLAYER.teleport(CENTER_PLAYER_POS)
  PLAYER.setFacing(directionTowards(PLAYER.getEyePosition(), THEBOT.getEyePosition()), Relativity.TO_WORLD)
  current_timer = 0.001
  hudText(PLAYER, "", "Timer for round", "{} / {}".format(SCENE_STATIC_TRACK_HEAD_TIME, current_timer), HudPosition.RIGHT, 0, Color.YELLOW, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER )
  tmp_timer_text_entity = getLastCreatedText()
  # Reinit stats
  stat_ticks = 0
  stat_occurances = 0

  # Timer setup
  wait(2)
  smallMessage(PLAYER, "START")
  chase(current_timer, SCENE_STATIC_TRACK_HEAD_TIME, rate=1, ChaseReeval.DESTINATION_AND_RATE)

  wait()
  active_scene = SCENE_STATIC_TRACK_HEAD

@Rule "INTERACTION | SCENE 2"
@Event eachPlayer
@Team 1
if switch_scene == SCENE_STATIC_FLICK_HEAD:
  switch_scene = SCENE_INVALID
  smallMessage(PLAYER, "SCENE 2")
    
  if len(getPlayers(Team.2)) == 0:
    createDummy(Hero.ANA, Team.2, -1, CENTER_DUMMY_POS, directionTowards(CENTER_DUMMY_POS, PLAYER.getPosition()))
  wait(0.2)
  THEBOT.teleport(CENTER_DUMMY_POS)

  # Handle player
  PLAYER.disallowButton(Button.PRIMARY_FIRE)
  PLAYER.teleport(CENTER_PLAYER_POS)
  PLAYER.setFacing(directionTowards(PLAYER.getEyePosition(), THEBOT.getEyePosition()), Relativity.TO_WORLD)
  hudText(PLAYER, "", "Timer for round", "{} / {}".format(SCENE_STATIC_FLICK_TIME, current_timer), HudPosition.RIGHT, 0, Color.YELLOW, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER )
  tmp_timer_text_entity = getLastCreatedText()
  current_timer = 0.001

  # Reinit stats
  stat_ticks = 0
  stat_occurances = 0

  # Timer setup
  wait(2)
  smallMessage(PLAYER, "START")
  chase(current_timer, SCENE_STATIC_FLICK_TIME, rate=1, ChaseReeval.DESTINATION_AND_RATE)

  wait()
  active_scene = SCENE_STATIC_FLICK_HEAD


@Rule "SCENE 1 END : TIMER"
@Event global
if active_scene == SCENE_STATIC_TRACK_HEAD and current_timer >= SCENE_STATIC_TRACK_HEAD_TIME:
  active_scene = SCENE_INVALID
  stopChasingVariable(current_timer)
  PLAYER.teleport(MENU_PLAYER_POS)
  PLAYER.setFacing(directionTowards(PLAYER.getEyePosition(), MENU_PLAYER_EYE_POS), Relativity.TO_WORLD)
  results[RESULT_STATIC_TRACK_HEAD_INDEX] = stat_occurances/stat_ticks * 100
  wait()
  bigMessage(PLAYER, "Result: {}".format(results[RESULT_STATIC_TRACK_HEAD_INDEX]))
  destroyHudText(tmp_timer_text_entity)
  

@Rule "SCENE 2 END : TIMER"
@Event global
if active_scene == SCENE_STATIC_FLICK_HEAD and current_timer >= SCENE_STATIC_FLICK_TIME:
  active_scene = SCENE_INVALID
  stopChasingVariable(current_timer)
  PLAYER.teleport(MENU_PLAYER_POS)
  PLAYER.setFacing(directionTowards(PLAYER.getEyePosition(), MENU_PLAYER_EYE_POS), Relativity.TO_WORLD)
  # TODO
  results[RESULT_STATIC_FLICK_HEAD_INDEX] = stat_occurances/stat_ticks * 100
  wait()
  bigMessage(PLAYER, "Result: {}".format(results[RESULT_STATIC_FLICK_HEAD_INDEX]))
  destroyHudText(tmp_timer_text_entity)

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
    stat_ticks += 1
    if distance(vect(0, 0, 0), THEBOT.getEyePosition() - (eventPlayer.getEyePosition() + (abs(dotProduct(THEBOT.getEyePosition() - eventPlayer.getEyePosition(), eventPlayer.getFacingDirection()))) * eventPlayer.getFacingDirection())) <= 0.3:
      stat_occurances += 1
    wait()
  while RULE_CONDITION

@Rule "SCENE STATIC | FLICK HEAD | MOVE THE BOT AROUND"
@Event eachPlayer
@Team 1
@Slot 0
if active_scene == SCENE_STATIC_FLICK_HEAD:
  do:
    stat_ticks += 1
    temp_sign_for_tp = random.choice([1, -1])
    wait()
    THEBOT.teleport(CENTER_DUMMY_POS + temp_sign_for_tp * vect(random.uniform(0,3), 0, 0) + temp_sign_for_tp * vect(0, 0, random.uniform(0, 7)))
    wait()
    is_bot_fresh = true
    wait(1.5)
  while RULE_CONDITION

@Rule "SCENE STATIC | FLICK HEAD | SCORES"
@Event eachPlayer
@Team 1
@Slot 0
if active_scene == SCENE_STATIC_FLICK_HEAD:
  do:
    if is_bot_fresh and distance(vect(0, 0, 0), THEBOT.getEyePosition() - (eventPlayer.getEyePosition() + (abs(dotProduct(THEBOT.getEyePosition() - eventPlayer.getEyePosition(), eventPlayer.getFacingDirection()))) * eventPlayer.getFacingDirection())) <= 0.1:
      is_bot_fresh = false
      stat_occurances += 1
    wait()
  while RULE_CONDITION

@Rule "DEBUG | DISTANCE FROM PORTAL 1"
@Event eachPlayer
# hudText(eventPlayer, distance(eventPlayer.getPosition(), PORTAL_1_TRACKING), "", "", HudPosition.RIGHT, 0, Color.WHITE, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_SORT_ORDER_AND_STRING, SpecVisibility.NEVER)
# debug(distance(vect(0, 0, 0), THEBOT.getEyePosition() - (eventPlayer.getEyePosition() + (abs(dotProduct(THEBOT.getEyePosition() - eventPlayer.getEyePosition(), eventPlayer.getFacingDirection()))) * eventPlayer.getFacingDirection())))
# debug("Track rate: {}".format(stat_occurances/stat_ticks * 100))

@Rule "DEBUG | SAVE POSITION"
@Event eachPlayer
@Team 1
@Slot 0
if eventPlayer.isCrouching() and eventPlayer.isFiringPrimaryFire():
    debug_slots.append(eventPlayer.getPosition())

    
@Rule "DEBUG | SERVER LOAD"
@Event global
#if DEBUG:
debug("Server load average: {}".format(getAverageServerLoad() / 255 * 100))
debug("Server load peak: {}".format(getPeakServerLoad() / 255 * 100))
debug("Server load: {}".format(getServerLoad() / 255 * 100))