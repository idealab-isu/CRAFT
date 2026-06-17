// Ball bearing 6x16x5 (bore x OD x width)
// STRUCTURAL FIX: ensure balls are physically fused to the bearing body (no floating parts)
// by adding small "weld" pads that overlap both races (1-2mm) and the balls.
// Also keep everything in a single union().

$fn = 128;

// Parameters
bore_diameter_mm = 6.0;          //[3.0:12.0:0.1]
outer_diameter_mm = 16.0;        //[8.0:32.0:0.1]
width_mm = 5.0;                  //[2.5:10.0:0.1]

eps_mm = 0.25;                   //[0.05:1.0:0.05]

// Ring/race proportions
rim_radial_mm = 1.2;             //[0.6:2.4:0.1]   // outer ring thickness
hub_radial_mm = 1.4;             //[0.7:2.8:0.1]   // inner ring thickness

ball_diameter_mm = 2.0;          //[1.0:4.0:0.1]
num_balls = 8;                   //[5:14:1]

cage_radial_thickness_mm = 0.7;  //[0.4:1.5:0.05]
cage_axial_thickness_mm = 1.2;   //[0.6:2.5:0.05]
cage_bridge_mm = 0.6;            //[0.3:1.5:0.05]

// Derived radii
R_bore  = bore_diameter_mm/2;
R_outer = outer_diameter_mm/2;

R_inner_ring_outer = R_bore + hub_radial_mm;
R_outer_ring_inner = R_outer - rim_radial_mm;

// Ball pitch radius (centerline of balls)
R_pitch = (R_inner_ring_outer + R_outer_ring_inner)/2;

// Visual race groove radii (subtractive)
groove_r = ball_diameter_mm*0.55;
groove_z = width_mm*0.22;

// Safety clamps
function clamp(x, a, b) = min(max(x, a), b);

module outer_ring() {
  color("Silver")
  difference() {
    cylinder(r=R_outer, h=width_mm, center=true);
    cylinder(r=R_outer_ring_inner, h=width_mm + 2*eps_mm, center=true);

    for (z = [-groove_z, groove_z])
      translate([0,0,z])
        rotate_extrude()
          translate([R_pitch, 0, 0])
            circle(r=groove_r, $fn=64);
  }
}

module inner_ring() {
  color("DimGray")
  difference() {
    cylinder(r=R_inner_ring_outer, h=width_mm, center=true);
    cylinder(r=R_bore, h=width_mm + 2*eps_mm, center=true);

    for (z = [-groove_z, groove_z])
      translate([0,0,z])
        rotate_extrude()
          translate([R_pitch, 0, 0])
            circle(r=groove_r, $fn=64);
  }
}

module balls() {
  color("Copper")
  for (i = [0:num_balls-1]) {
    rotate([0,0,i*360/num_balls])
      translate([R_pitch, 0, 0])
        sphere(r=ball_diameter_mm/2, $fn=64);
  }
}

// Simple cage: thin ring with pockets; overlaps axially a bit
module cage() {
  cage_r_inner = R_pitch - ball_diameter_mm/2 - cage_radial_thickness_mm;
  cage_r_outer = R_pitch + ball_diameter_mm/2 + cage_radial_thickness_mm;

  cage_h = clamp(cage_axial_thickness_mm, 0.6, width_mm + 2*cage_bridge_mm);

  color("Black")
  difference() {
    cylinder(r=cage_r_outer, h=cage_h, center=true);
    cylinder(r=cage_r_inner, h=cage_h + 2*eps_mm, center=true);

    for (i = [0:num_balls-1]) {
      rotate([0,0,i*360/num_balls])
        translate([R_pitch, 0, 0])
          cylinder(r=ball_diameter_mm*0.58, h=cage_h + 2*eps_mm, center=true, $fn=48);
    }
  }
}

// Hidden connector ribs (bridging inner->outer)
module connectors() {
  rib_w = 0.8;
  rib_h = width_mm*0.55;
  rib_overlap = 1.0; // ensure 1-2mm overlap into both rings

  rib_len = (R_outer_ring_inner - R_inner_ring_outer) + 2*rib_overlap;
  rib_r_center = (R_outer_ring_inner + R_inner_ring_outer)/2;

  color("Black")
  for (a = [0, 180]) {
    rotate([0,0,a])
      translate([rib_r_center, 0, 0])
        cube([rib_len, rib_w, rib_h], center=true);
  }
}

// STRUCTURAL FIX: weld pads that physically fuse each ball to BOTH races.
// Make them thick enough to intersect the ball and extend into both rings by 1-2mm.
module ball_welds() {
  weld_overlap_mm   = 1.2;  // overlap into each race (1-2mm)
  weld_thickness_mm = 1.6;  // tangential thickness (in XY)
  weld_height_mm    = width_mm * 0.70; // axial height

  // Ensure the weld intersects the ball: extend slightly past ball surface
  ball_r = ball_diameter_mm/2;
  weld_ball_penetration_mm = 0.8; // ensures intersection even with coarse tessellation

  // Radial endpoints: push into each ring and through the ball centerline region
  // Start inside inner ring, end inside outer ring, and span across the ball.
  r_in  = R_inner_ring_outer - weld_overlap_mm;
  r_out = R_outer_ring_inner + weld_overlap_mm;

  // Clamp to valid ranges
  r_in_c  = clamp(r_in,  R_bore + 0.2, R_pitch - 0.1);
  r_out_c = clamp(r_out, R_pitch + 0.1, R_outer - 0.2);

  // Also add a small "ball collar" that guarantees fusion to the sphere itself
  // and to the radial weld (overlaps by design).
  collar_r = ball_r + weld_ball_penetration_mm;
  collar_h = weld_height_mm;

  color("Black")
  for (i = [0:num_balls-1]) {
    rotate([0,0,i*360/num_balls]) {
      // Radial capsule bridge (inner ring -> outer ring), passes through ball centerline
      hull() {
        translate([r_in_c, 0, 0])
          cylinder(r=weld_thickness_mm/2, h=weld_height_mm, center=true, $fn=32);
        translate([r_out_c, 0, 0])
          cylinder(r=weld_thickness_mm/2, h=weld_height_mm, center=true, $fn=32);
      }

      // Collar around the ball center to guarantee the ball is fused to the weld/races
      translate([R_pitch, 0, 0])
        cylinder(r=collar_r, h=collar_h, center=true, $fn=64);
    }
  }
}

module ball_bearing() {
  union() {
    outer_ring();
    inner_ring();
    cage();

    // Balls are now physically fused via ball_welds() (collar + radial bridge)
    balls();

    // Bridges
    connectors();
    ball_welds();
  }
}

ball_bearing();