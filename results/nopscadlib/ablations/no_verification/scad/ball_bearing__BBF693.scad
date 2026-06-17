// Flanged ball bearing (single connected solid)
// Target: 3.0mm bore, 8.0mm OD, 3.0mm width, 9.5mm flange OD

$fn = 128;

// Parameters
bore_diameter_mm   = 3.0;   //[1.5:6:0.1]
outer_diameter_mm  = 8.0;   //[4:16:0.1]
width_mm           = 3.0;   //[1.5:6:0.1]
flange_diameter_mm = 9.5;   //[4.75:19:0.1]
flange_width_mm    = 0.8;   //[0.4:1.6:0.05]

// Visual/feature parameters (kept within geometry limits)
race_radial_thickness_mm = 1.0;  //[0.6:2.4:0.05]
ball_diameter_mm         = 1.0;  //[0.6:2.4:0.05]
ball_count               = 8;    //[6:16:1]

// Small overlaps to guarantee watertight union/difference
overlap_mm = 0.05; //[0.01:0.3:0.01]

// Derived radii
bore_r   = bore_diameter_mm/2;
outer_r  = outer_diameter_mm/2;
flange_r = flange_diameter_mm/2;

// Clamp helper
function clamp(x, a, b) = x < a ? a : (x > b ? b : x);

// Ensure races fit between bore and OD
race_t = clamp(race_radial_thickness_mm, 0.3, (outer_r - bore_r)/2 - 0.05);

// Ball path radius (between races)
ball_path_r = (bore_r + race_t + (outer_r - race_t)) / 2;

// Ball size limited by available radial gap
max_ball_d = 2 * ((outer_r - race_t) - (bore_r + race_t)) - 0.10;
ball_d = clamp(ball_diameter_mm, 0.4, max_ball_d);
ball_r = ball_d/2;

// Z placement for flange (on one side)
flange_z = -width_mm/2 + flange_width_mm/2 - overlap_mm;

// Outer race + flange (solid)
module outer_race_with_flange() {
  union() {
    // Outer race ring
    difference() {
      cylinder(r=outer_r, h=width_mm, center=true);
      cylinder(r=outer_r - race_t, h=width_mm + 2*overlap_mm, center=true);
    }

    // Flange ring (connected with slight overlap)
    translate([0, 0, flange_z])
      difference() {
        cylinder(r=flange_r, h=flange_width_mm, center=true);
        cylinder(r=outer_r - overlap_mm, h=flange_width_mm + 2*overlap_mm, center=true);
      }
  }
}

// Inner race (solid)
module inner_race() {
  difference() {
    cylinder(r=bore_r + race_t, h=width_mm, center=true);
    cylinder(r=bore_r, h=width_mm + 2*overlap_mm, center=true);
  }
}

// Balls (solid spheres) placed on a circular path
module balls() {
  for (i = [0:ball_count-1]) {
    rotate([0, 0, i * 360/ball_count])
      translate([ball_path_r, 0, 0])
        sphere(r=ball_r);
  }
}

// Assembly as ONE connected solid:
// Add a thin hidden web ring at mid-radius to ensure connectivity between races and balls.
module bearing_connected_solid() {
  web_r1 = bore_r + race_t + 0.02;
  web_r2 = outer_r - race_t - 0.02;
  web_h  = min(0.20, width_mm - 0.20);

  union() {
    outer_race_with_flange();
    inner_race();
    balls();

    // Connectivity web (thin ring) to guarantee single connected manifold
    if (web_r2 > web_r1 && web_h > 0)
      difference() {
        cylinder(r=web_r2, h=web_h, center=true);
        cylinder(r=web_r1, h=web_h + 2*overlap_mm, center=true);
      }
  }
}

bearing_connected_solid();