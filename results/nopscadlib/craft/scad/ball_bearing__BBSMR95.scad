// Ball bearing 5x9x2.5 (bore x OD x width) - single connected solid

// Parameters
bore_diameter_mm = 5.0;   //[2.5:10.0:0.1]
outer_diameter_mm = 9.0;  //[4.5:18.0:0.1]
width_mm = 2.5;           //[1.25:5.0:0.05]

// Visual/geometry controls
eps_mm = 0.05;            //[0.01:0.2:0.01]
rim_radial_mm = 0.8;      //[0.4:1.6:0.05]   // outer ring thickness (radial)
hub_radial_mm = 0.7;      //[0.35:1.4:0.05]  // inner ring thickness (radial)
shield_thickness_mm = 0.5;//[0.25:1.0:0.05]
ball_diameter_mm = 1.2;   //[0.6:2.4:0.05]
num_balls = 7;            //[5:12:1]
bridge_overlap_mm = 0.15; //[0.05:0.4:0.05]  // ensures one connected solid

$fn = 128;

// Derived radii
bore_r  = bore_diameter_mm/2;
outer_r = outer_diameter_mm/2;

// Ring radii
inner_ring_or = bore_r + hub_radial_mm;
outer_ring_ir = outer_r - rim_radial_mm;

// Ball path radius (center of balls)
ball_path_r = (inner_ring_or + outer_ring_ir)/2;

// Clamp ball size so it fits between rings
max_ball_d = max(0.2, 2*(outer_ring_ir - inner_ring_or) - 2*eps_mm);
ball_d = min(ball_diameter_mm, max_ball_d);
ball_r = ball_d/2;

// Shield radii (kept inside rings)
shield_or = outer_ring_ir - eps_mm;
shield_ir = inner_ring_or + eps_mm;

// Z placement for shields (flush with faces, slight overlap into rings)
shield_z = width_mm/2 - shield_thickness_mm/2 + bridge_overlap_mm;

// Outer ring
module outer_ring() {
  difference() {
    cylinder(r=outer_r, h=width_mm, center=true);
    cylinder(r=outer_ring_ir, h=width_mm + 2*eps_mm, center=true);
  }
}

// Inner ring
module inner_ring() {
  difference() {
    cylinder(r=inner_ring_or, h=width_mm, center=true);
    cylinder(r=bore_r, h=width_mm + 2*eps_mm, center=true);
  }
}

// Two shields (as solids) to visually read as a bearing; overlapped to ensure connectivity
module shields() {
  for (zsgn = [-1, 1]) {
    translate([0, 0, zsgn*shield_z])
      difference() {
        cylinder(r=shield_or, h=shield_thickness_mm, center=true);
        cylinder(r=shield_ir, h=shield_thickness_mm + 2*eps_mm, center=true);
      }
  }
}

// Balls (solids) arranged radially; slightly enlarged/overlapped to guarantee union connectivity
module balls() {
  // small radial overlap into both rings
  ball_r_conn = ball_r + bridge_overlap_mm;

  for (i = [0:num_balls-1]) {
    rotate([0, 0, i*360/num_balls])
      translate([ball_path_r, 0, 0])
        sphere(r=ball_r_conn);
  }
}

// Final assembly: ONE connected solid
module assembly() {
  union() {
    outer_ring();
    inner_ring();
    shields();
    balls();
  }
}

assembly();