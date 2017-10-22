function check_collision(x1, y1, w1, h1, x2, y2, w2, h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end

function check_collision_box(b1, b2)
  return b1.x < b2.x + b2.w and
         b2.x < b1.x + b1.w and
         b1.y < b2.y + b2.h and
         b2.y < b1.y + b1.h
end

function box_translate (box, dx, dy)
  return create_box(box.x + dx, box.y + dy, box.w, box.h)
end

function draw_box (box, r, g, b, a)
  love.graphics.setColor(r, g, b, a)
  love.graphics.rectangle("line", box.x, box.y, box.w, box.h)
  love.graphics.setColor(255, 255, 255, 255)
end

function create_box(x, y, w, h)
  return {x = x, y = y, w = w, h = h}
end

function create_attack_reach (facing, base_box, reach)
  if (facing[1] > 0) or (facing[2] > 0) then
    return create_box(base_box.x, base_box.y, base_box.w + math.abs(facing[1]) * reach, base_box.h + math.abs(facing[2]) * reach)
  else
    return create_box(base_box.x - math.abs(facing[1]) * reach, base_box.y - math.abs(facing[2]) * reach, base_box.w + math.abs(facing[1]) * reach, base_box.h + math.abs(facing[2]) * reach)
  end
end

function load_spritesheet (file, size_x, size_y)
  local spritesheet = {size = {x = size_x, y = size_y}, image = love.graphics.newImage(file), cell = {}}

  for x=0, size_x - 1 do
    spritesheet.cell[x] = {}
    for y=0, size_y - 1 do
      spritesheet.cell[y * size_x + x] = love.graphics.newQuad(x, y, 1, 1, size_x, size_y)
    end
  end

  return spritesheet
end

function draw_sprite(spritesheet, x, y, unit, id)
  love.graphics.draw(spritesheet.image, spritesheet.cell[id], x, y, 0, unit, unit)
end

function create_empty_world (size_x, size_y)
  local new_world = {size = {x = size_x, y = size_y}, cell = {}}
  for x=0, size_x-1 do
    new_world.cell[x] = {}
    for y=0, size_y-1 do
      new_world.cell[x][y] = {}
      for i=0,3 do
        new_world.cell[x][y][i] = 0
      end
    end
  end
  return new_world
end

function draw_world_level(world, spritesheet, level, unit)
  for x=0,world.size.x-1 do
    for y=0,world.size.y-1 do
      love.graphics.draw(spritesheet.image,
      spritesheet.cell[world.cell[x][y][level]], x * unit, y * unit, 0, unit, unit)
    end
  end
end

function to_world_space (x, y, cam)
  return {x = x / cam.zoom + cam.x,y = y / cam.zoom + cam.y}
end
