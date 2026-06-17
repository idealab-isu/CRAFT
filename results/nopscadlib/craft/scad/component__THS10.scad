// Parameters
body_L = 50; //[25:100:1]
body_W = 50; //[25:100:1]
body_H = 20; //[10:40:1]

// Small overlap to guarantee a single connected solid
overlap = 0.5;

// Main body module
module main_body() {
  cube([body_L, body_W, body_H], center=true);
}

// Final model: one solid, non-degenerate, visible geometry
union() {
  main_body();

  // External boss on top face (clearly visible and connected with overlap)
  boss_r = min(body_L, body_W) * 0.12;
  boss_h = max(2, body_H * 0.35);

  translate([0, 0, body_H/2 + boss_h/2 - overlap])
    cylinder(r=boss_r, h=boss_h, center=true, $fn=64);
}