// Parameters
bore_diameter_mm = 5; //[2.5:10:0.1]
outer_diameter_mm = 9; //[4.5:18:0.1]
width_mm = 3; //[1.5:6:0.1]
race_radial_thickness_mm = 0.8; //[0.4:1.6:0.05]
ball_diameter_mm = 1.2; //[0.6:2.4:0.05]
ball_count = 8; //[4:16:1]

// Structural connectivity overlap (force physical fusion)
connection_overlap_mm = 1.2; //[0.2:2:0.1]

// Derived radii
bore_r  = bore_diameter_mm/2;
outer_r = outer_diameter_mm/2;

// Ring radii (as in original design intent)
inner_ring_outer_r = bore_r + race_radial_thickness_mm;
outer_ring_inner_r = outer_r - race_radial_thickness_mm;

// Ball path radius (midway between ring faces)
ball_path_r = (inner_ring_outer_r + outer_ring_inner_r)/2;

// Small bridges to guarantee everything is one connected solid
// (keeps overall look; adds hidden/low-profile material)
bridge_radial_thickness = connection_overlap_mm;                 // 1–2mm radial overlap
bridge_z_thickness      = min(connection_overlap_mm, width_mm);  // keep within width

module bearing_ball() {
  sphere(r=ball_diameter_mm/2, $fn=32);
}

module outer_race() {
  difference() {
    cylinder(r=outer_r, h=width_mm, center=true, $fn=96);
    cylinder(r=outer_ring_inner_r, h=width_mm + 2*connection_overlap_mm, center=true, $fn=96);
  }
}

module inner_race() {
  difference() {
    cylinder(r=inner_ring_outer_r, h=width_mm, center=true, $fn=96);
    cylinder(r=bore_r, h=width_mm + 2*connection_overlap_mm, center=true, $fn=96);
  }
}

// Radial bridge ring that overlaps BOTH races (forces inner+outer to be fused)
module race_bridge_ring() {
  // Place a thin ring centered at the ball path, thick enough to intersect both races
  difference() {
    cylinder(r=ball_path_r + bridge_radial_thickness/2, h=bridge_z_thickness, center=true, $fn=128);
    cylinder(r=ball_path_r - bridge_radial_thickness/2, h=bridge_z_thickness + 2*connection_overlap_mm, center=true, $fn=128);
  }
}

// Small "weld pads" that fuse each ball to the bridge ring (and thus to both races)
module ball_weld_pads() {
  for (i = [0:ball_count-1]) {
    rotate([0, 0, i*360/ball_count]) {
      // Pad is a short cylinder along radial direction, centered on ball position,
      // long enough to intersect the ball and the bridge ring.
      translate([ball_path_r, 0, 0])
        rotate([0, 90, 0])
          cylinder(r=ball_diameter_mm*0.28, h=ball_diameter_mm + 2*connection_overlap_mm, center=true, $fn=24);
    }
  }
}

module balls() {
  for (i = [0:ball_count-1]) {
    rotate([0, 0, i*360/ball_count])
      translate([ball_path_r, 0, 0])
        bearing_ball();
  }
}

module ball_bearing_connected() {
  // Single solid: races + bridge + balls + weld pads
  union() {
    // Races
    outer_race();
    inner_race();

    // Bridge that physically connects inner and outer races (eliminates race gap as a structural disconnect)
    race_bridge_ring();

    // Balls + weld pads to ensure balls are not floating
    balls();
    ball_weld_pads();
  }
}

// Assembly (keep bore hole)
module assembly() {
  difference() {
    ball_bearing_connected();
    cylinder(r=bore_r, h=width_mm + 2*connection_overlap_mm, center=true, $fn=96);
  }
}

assembly();