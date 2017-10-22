DEBUG = true

-- assets ----------------------------------------------------------------------
function load_assets()
  asset_player = love.graphics.newImage("assets/player.png")
  asset_terrain = load_spritesheet("assets/terrain.png", 40, 36)
end

-- love loop -------------------------------------------------------------------
function love.load(arg)
  utils = require "utils"
  love.graphics.setDefaultFilter("nearest", "nearest")
  load_assets()
  setup_game()
end

elapsed_time = 0
function love.update(dt)
  elapsed_time = elapsed_time + dt
  screen_width = love.graphics.getWidth()
  screen_height = love.graphics.getHeight()
  handle_input()
  update_game(dt)
end

function love.draw()
  draw_game()

  if (DEBUG) then
    love.graphics.print("fps: " .. love.timer.getFPS())
  end
end

function handle_input()
  input = {
    up = love.keyboard.isDown("z"),
    down = love.keyboard.isDown("s"),
    left = love.keyboard.isDown("q"),
    right = love.keyboard.isDown("d"),

    run = love.keyboard.isDown("r")
  }
end

-- game loop -------------------------------------------------------------------
function setup_game ()
  editor = false

  world = create_empty_world(16, 16)

  player_box = create_box(0, 0, 16, 8)
  player_speed_x = 0
  player_speed_y = 0
  player_facing = {0, 1}

  default_speed = 4
  run_speed = 32
  player_max_speed = 4

  camera = {x = 0, y = 0, zoom = 2}

  objects = {
    create_box(-64, -64, 64, 64),
    create_box(64, -64, 64, 64),
    create_box(-64, 64, 64, 64),
    create_box(64, 64, 64, 64),
    create_box(64, 128 + 10, 64, 64),
    create_box(300, 128, 64, 64),
    create_box(89, 256, 64, 64),
    create_box(-26, 0, 16, 1024),
  }

  play_zone = create_box(0, 0, 512, 512)

  setup_editor()
end

function update_game (dt)
  if player_speed_x > 0 then
    player_speed_x = player_speed_x - 1
  end

  if player_speed_x < 0 then
    player_speed_x = player_speed_x + 1
  end

  if player_speed_y > 0 then
    player_speed_y = player_speed_y - 1
  end

  if player_speed_y < 0 then
    player_speed_y = player_speed_y + 1
  end

  if input.up then
    player_speed_y = player_speed_y - 2
    player_facing = {0, -1}
  end

  if input.down then
    player_speed_y = player_speed_y + 2
    player_facing = {0, 1}
  end

  if input.left then
    player_speed_x = player_speed_x - 2
    player_facing = {-1, 0}
  end

  if input.right then
    player_speed_x = player_speed_x + 2
    player_facing = {1, 0}
  end

  if input.run then player_max_speed = run_speed else player_max_speed = default_speed end

  if player_speed_x > player_max_speed then player_speed_x = player_speed_x - 1 end
  if player_speed_x < -player_max_speed then player_speed_x = player_speed_x + 1 end

  if player_speed_y > player_max_speed then player_speed_y = player_speed_y - 1 end
  if player_speed_y < -player_max_speed then player_speed_y = player_speed_y + 1 end

  -- colision detection

  for _,v in ipairs(objects) do
    if check_collision(player_box.x, player_box.y + player_speed_y, player_box.w, player_box.h, v.x, v.y, v.w, v.h) then
      player_speed_y = 0
    end

    if check_collision(player_box.x + player_speed_x, player_box.y, player_box.w, player_box.h, v.x, v.y, v.w, v.h) then
      player_speed_x = 0
    end

    -- this fix some problem with corner.
    if check_collision(player_box.x + player_speed_x, player_box.y + player_speed_y, player_box.w, player_box.h, v.x, v.y, v.w, v.h) then
      player_speed_x = 0
      player_speed_y = 0
    end
  end

  if not check_collision_box(box_translate(player_box, player_speed_x, player_speed_y), play_zone) then
    player_speed_x = 0
    player_speed_y = 0
  end

  player_box.x = player_box.x + player_speed_x
  player_box.y = player_box.y + player_speed_y

  camera.x = player_box.x - (screen_width / 2) / camera.zoom
  camera.y = player_box.y - (screen_height / 2) / camera.zoom

  player_attack_box = create_attack_reach(player_facing, create_box(player_box.x,player_box.y - 8, 16, 16), 25)

  if (editor) then
    update_editor(dt)
  end
end

function draw_game ()
  love.graphics.push()
  -- apply the camera
  love.graphics.translate(-camera.x * camera.zoom, -camera.y * camera.zoom)
  love.graphics.scale(camera.zoom, camera.zoom)

  --draw the world
  draw_world_level(world, asset_terrain, 0, 16 * 2)

  -- draw the player
  love.graphics.draw(asset_player, player_box.x - 8, player_box.y - 24, 0, 2)

  if DEBUG then
    local boxcenter = {y = player_box.h / 2 , x = player_box.w / 2}
    love.graphics.rectangle("line", player_box.x, player_box.y, player_box.w, player_box.h)
    love.graphics.line(player_box.x + boxcenter.x, player_box.y  + boxcenter.y, player_box.x + player_speed_x + boxcenter.x, player_box.y + player_speed_y + boxcenter.y)
    draw_box(player_attack_box, 255, 0, 0, 255)
  end

  for _,v in ipairs(objects) do
    draw_box(v, 0, 255, 0, 255)
  end

  draw_box(play_zone, 255, 0, 0, 100)

  love.graphics.pop()

  if (editor) then
    draw_editor()
  end
end

-- editor gui ------------------------------------------------------------------

function setup_editor()
  selected_tile = 0
  width_count = 4
end

function update_editor (dt)

end

function draw_editor ()
  for i=0, (asset_terrain.size.x - 1) * (asset_terrain.size.y - 1) do
    draw_sprite(asset_terrain, (i % width_count) * 32, (math.floor(i / width_count)) * 32 , 32, i)
  end
end
