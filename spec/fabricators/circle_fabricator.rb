Fabricator(:circle_base, class_name: :circle) do
  center_y { Faker::Number.decimal(l_digits: 8, r_digits: 4) }
  center_x { Faker::Number.decimal(l_digits: 8, r_digits: 4) }
  radius { Faker::Number.decimal(l_digits: 8, r_digits: 4) }
end

Fabricator(:circle, from: :circle_base) do
  frame(fabricator: :frame_base)
end
