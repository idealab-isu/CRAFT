// Flanged ball bearing (single connected solid) with visible bearing features
// Target: 5.0mm bore, 13.0mm OD, 4.0mm width, 15.0mm flange OD

$fn = 180;

// --- Primary dimensions (mm) ---
bore_diameter_mm   = 5.0;    //[2.5:10.0:0.1]
outer_diameter_mm  = 13.0;   //[6.5:26.0:0.1]
width_mm           = 4.0;    //[2.0:8.0:0.1]
flange_diameter_mm = 15.0;   //[7.5:30.0:0.1]
flange_width_mm    = 1.0;    //[0.5:2.0:0.1]

// --- Visual bearing feature parameters (kept small/robust) ---
outer_rim_thickness_mm = 1.0;   //[0.6:2.0:0.1]  // outer ring wall thickness
inner_hub_thickness_mm = 1.0;   //[0.6:2.0:0.1]  // inner ring wall thickness
shield_thickness_mm    = 0.35;  //[0.2:0.8:0.05]
shield_radial_gap_mm   = 0.25;  //[0.1:0.6:0.05]
ball_diameter_mm       = 1.6;   //[0.8:3.2:0.1]
ball_count             = 8;     //[6:14:1]
cage_thickness_mm      = 0.45;  //[0.3:1.0:0.05]
cage_window_scale      = 1.25;  //[1.0:1.8:0.05]
chamfer_mm             = 0.25;  //[0.1:0.6:0.05]

eps = 0.03;

// --- Derived radii ---
r_bore   = bore_diameter_mm/2;
r_outer  = outer_diameter_mm/2;
r_flange = flange_diameter_mm/2;

// Race boundaries (ensure valid ordering)
r_inner_race_outer = r_bore + inner_hub_thickness_mm;
r_outer_race_inner = r_outer - outer_rim_thickness_mm;

// Ball path radius between races
r_ball_path = (r_inner_race_outer + r_outer_race_inner)/2;

// Groove sizing (visual)
groove_r = ball_diameter_mm*0.55;

// Keep everything sane
function clamp(x,a,b) = x < a ? a : (x > b ? b : x);

// Ensure the ball path is feasible
min_clear = ball_diameter_mm*0.55;
r_ball_path_safe = clamp(r_ball_path, r_inner_race_outer + min_clear, r_outer_race_inner - min_clear);

// Z placement for shields (slightly inset)
z_shield = width_mm/2 - shield_thickness_mm/2 - eps;

// Cage radii (thin ring around balls)
r_cage_inner = r_ball_path_safe - ball_diameter_mm*0.55;
r_cage_outer = r_ball_path_safe + ball_diameter_mm*0.55;

// --- Modules ---
module outer_body_and_flange() {
  union() {
    // Outer ring body
    cylinder(r=r_outer, h=width_mm, center=true);

    // Flange on -Z side, connected with overlap
    translate([0,0, -width_mm/2 + flange_width_mm/2 - eps])
      cylinder(r=r_flange, h=flange_width_mm, center=true);
  }
}

module inner_ring() {
  // Inner ring (hub) - full width to guarantee connectivity
  cylinder(r=r_inner_race_outer, h=width_mm, center=true);
}

module shields() {
  // Two thin shields connected to both rings (via overlap)
  for (sz = [-z_shield, z_shield]) {
    translate([0,0,sz])
      difference() {
        cylinder(r=r_outer - outer_rim_thickness_mm - shield_radial_gap_mm,
                 h=shield_thickness_mm, center=true);
        cylinder(r=r_inner_race_outer + shield_radial_gap_mm,
                 h=shield_thickness_mm + 2*eps, center=true);
      }
  }
}

module balls_fused() {
  // Balls fused into the solid (single connected solid requirement)
  for (i = [0:ball_count-1]) {
    rotate([0,0,i*360/ball_count])
      translate([r_ball_path_safe, 0, 0])
        sphere(r=ball_diameter_mm/2);
  }
}

module cage_fused() {
  // Simple cage ring with windows; fused to balls by slight overlap
  // (Windows are cutouts; cage remains connected as a ring)
  difference() {
    // Cage ring centered in Z
    cylinder(r=r_cage_outer, h=cage_thickness_mm, center=true);
    cylinder(r=r_cage_inner, h=cage_thickness_mm + 2*eps, center=true);

    // Windows around each ball position
    for (i = [0:ball_count-1]) {
      rotate([0,0,i*360/ball_count])
        translate([r_ball_path_safe, 0, 0])
          // Window is a box that removes material around each ball
          cube([ball_diameter_mm*cage_window_scale,
                ball_diameter_mm*cage_window_scale,
                cage_thickness_mm + 2*eps], center=true);
    }
  }
}

module bearing_solid() {
  // One connected solid: outer ring + flange + inner ring + shields + balls + cage
  union() {
    outer_body_and_flange();
    inner_ring();
    shields();
    balls_fused();
    cage_fused();
  }
}

module bearing_voids() {
  // Through bore (5mm)
  cylinder(r=r_bore, h=width_mm + flange_width_mm + 6, center=true);

  // Race pockets (visual) - shallow annular reliefs
  // Outer race relief
  difference() {
    cylinder(r=r_outer - outer_rim_thickness_mm*0.10,
             h=width_mm - 2*shield_thickness_mm, center=true);
    cylinder(r=r_outer_race_inner,
             h=width_mm - 2*shield_thickness_mm + 2*eps, center=true);
  }

  // Inner race relief
  difference() {
    cylinder(r=r_inner_race_outer,
             h=width_mm - 2*shield_thickness_mm, center=true);
    cylinder(r=r_bore + eps,
             h=width_mm - 2*shield_thickness_mm + 2*eps, center=true);
  }

  // Ball groove (torus-like) centered in Z
  rotate_extrude(angle=360)
    translate([r_ball_path_safe, 0, 0])
      circle(r=groove_r);

  // Outer edge chamfers (top and bottom of main body)
  translate([0,0, width_mm/2 - chamfer_mm/2])
    cylinder(r1=r_outer + 0.001, r2=r_outer - chamfer_mm, h=chamfer_mm, center=true);

  translate([0,0, -width_mm/2 + chamfer_mm/2])
    cylinder(r1=r_outer - chamfer_mm, r2=r_outer + 0.001, h=chamfer_mm, center=true);

  // Bore chamfers
  translate([0,0, width_mm/2 - chamfer_mm/2])
    cylinder(r1=r_bore + chamfer_mm, r2=r_bore, h=chamfer_mm, center=true);

  translate([0,0, -width_mm/2 + chamfer_mm/2])
    cylinder(r1=r_bore, r2=r_bore + chamfer_mm, h=chamfer_mm, center=true);
}

// --- Final model ---
difference() {
  bearing_solid();
  bearing_voids();
}