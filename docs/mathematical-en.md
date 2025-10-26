
# Mathematical Formulas

This document explains the formulas used in the `Frame` and `Circle` models you shared.

## Frame formulas

A `Frame` is stored by its center `(center_x, center_y)`, plus `width` and `height`.
Each edge is half the size away from the center.

- **Half**
  `half = 2` (the code uses `BigDecimal(2)`)

- **Left edge**
  `left_edge = center_x - (width / 2)`

- **Right edge**
  `right_edge = center_x + (width / 2)`

- **Top edge**
  `top_edge = center_y - (height / 2)`

- **Bottom edge**
  `bottom_edge = center_y + (height / 2)`

---
## Circle  formulas

A `Circle` has a center `(center_x, center_y)` and a `radius`.

- **Left edge** = `center_x - radius`
- **Right edge** = `center_x + radius`
- **Top edge** = `center_y - radius`
- **Bottom edge** = `center_y + radius`

---

## Checking if a circle is inside a frame (`wraps?`)

We say the circle *fits entirely inside* the frame when **all** its edges are inside the frame edges:

```
circle.left_edge   >= frame.left_edge
AND circle.right_edge  <= frame.right_edge
AND circle.top_edge    >= frame.top_edge
AND circle.bottom_edge <= frame.bottom_edge
```

If any of those fail, the circle touches or crosses the frame boundary.

---

## Frame vs Frame collision (overlap)

Two axis-aligned rectangles (frames) overlap when their horizontal ranges intersect **and** their vertical ranges intersect.

Given frame A and frame B:

- Horizontal overlap condition:
  ```
  A.right_edge >= B.left_edge
  AND A.left_edge <= B.right_edge
  ```
- Vertical overlap condition:
  ```
  A.bottom_edge >= B.top_edge
  AND A.top_edge <= B.bottom_edge
  ```

If both horizontal and vertical conditions are true, the frames collide (they overlap or touch).

The SQL in `collides_with_existing_frame?` uses the same idea, written with center and width/height:
```
(center_x + width/2) >= :left_edge
AND (center_x - width/2) <= :right_edge
AND (center_y + height/2) >= :top_edge
AND (center_y - height/2) <= :bottom_edge
```
This checks if any existing frame intersects the new frame area.

---

## Circle vs Circle collision

To detect collision (touching or overlapping) between two circles, compare the distance between centers and the sum of their radii.

- Let dx = x1 - x2 and dy = y1 - y2
- Squared distance: `distance_sq = dx^2 + dy^2`
- Sum of radii: `sum_r = r1 + r2`

**Collision test (touch or overlap):**
```
distance_sq <= (sum_r)^2
```

The code uses:
```ruby
POWER(center_x - :cx, 2) + POWER(center_y - :cy, 2)
<= POWER(:r + radius, 2)
```
This returns true if the stored circle collides with the circle at `(:cx, :cy, :r)`.

---

## Circle inside another circle (area filter)

To check if one circle is fully inside another circle (a larger area), compare the distance between centers and the difference of radius:

- Difference of radius: `diff_r = R - r` where `R` (big) - `r` (small)

**Containment test:**
```
distance_sq <= (diff_r)^2
```

The model's `filter_by_area` implements:
```sql
POWER(center_x - :cx, 2) + POWER(center_y - :cy, 2)
<= POWER(:r - radius, 2)
```
This finds stored circles that are entirely inside the circle `(cx, cy, r)`.

---

## Squared distances

Using `dx^2 + dy^2` and comparing to `(sum_r)^2` avoids the costly square root operation.
Mathematically:
```
sqrt(dx^2 + dy^2) <= sum_r
⇔ dx^2 + dy^2 <= sum_r^2
```
Both give the same boolean result; comparing squares is faster and numerically stable.

---

## Quick examples

1. Frame center (0,0), width 100, height 100:
   - left = -50, right = +50, top = -50, bottom = +50

2. Circle A at (0,0) radius 10 → left = -10, right = +10, top = -10, bottom = +10
   A fits inside the frame above.

3. Circle B at (15, 0) radius 10:
   - distance between A and B centers = 15
   - sum_r = 20
   - 15^2 = 225 ≤ 20^2 = 400 → collision (they overlap)

4. Containment: big circle (0,0) r = 30, small circle at (5,0) r = 10:
   - distance = 5 → 5^2 = 25
   - diff_r = 20 → 20^2 = 400
   - 25 ≤ 400 → small is fully inside big

---

## Final notes

- The code uses `BigDecimal` for numeric precision — but the geometric logic is the same.

