json.(frame, :id, :center_x, :center_y, :width, :height, :circles_count)

if frame.circles_count.zero?
  json.highest_circle_position nil
  json.lowest_circle_position nil
  json.leftmost_circle_position nil
  json.rightmost_circle_position nil
else
  json.highest_circle_position do
    json.(frame.highest_circle, :center_x, :center_y)
  end

  json.lowest_circle_position do
    json.(frame.lowest_circle, :center_x, :center_y)
  end

  json.leftmost_circle_position do
    json.(frame.leftmost_circle, :center_x, :center_y)
  end

  json.rightmost_circle_position do
    json.(frame.leftmost_circle, :center_x, :center_y)
  end
end

json.(frame, :created_at, :updated_at)
