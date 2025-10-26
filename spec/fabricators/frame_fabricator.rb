Fabricator(:frame_base, class_name: :frame) do
  center_y { Faker::Number.decimal(l_digits: 8, r_digits: 4) }
  center_x { Faker::Number.decimal(l_digits: 8, r_digits: 4) }
  height { Faker::Number.decimal(l_digits: 8, r_digits: 4) }
  width { Faker::Number.decimal(l_digits: 8, r_digits: 4) }
end

Fabricator(:frame, from: :frame_base) do
  circles(count: 3, fabricator: :circle_base)
end
