// Parameters
body_length = 50; //[25:100:1]
body_width  = 30; //[15:60:1]
body_height = 10; //[5:20:1]

// Small overlap to guarantee a single connected solid
overlap = 0.5;

// Main Body Module
module main_body() {
  cube([body_length, body_width, body_height], center=true);
}

// Connected component: main body + a top rib + two side bosses (all connected)
module component() {
  rib_h = max(2, body_height*0.4);
  rib_w = body_width * 0.35;
  rib_l = body_length * 0.6;

  boss_r = max(2, min(body_width, body_height) * 0.18);
  boss_h = max(2, body_height * 0.6);

  union() {
    main_body();

    // Rib sits on top of the body with slight overlap
    translate([0, 0, body_height/2 + rib_h/2 - overlap])
      cube([rib_l, rib_w, rib_h], center=true);

    // Two cylindrical bosses on the left/right sides, centered in Z, overlapping into the body
    for (sx = [-1, 1]) {
      translate([sx * (body_length/2 + boss_h/2 - overlap), 0, 0])
        rotate([0, 90, 0])
          cylinder(h=boss_h, r=boss_r, center=true, $fn=48);
    }
  }
}

// Final Model
component();