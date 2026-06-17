// Parameters
bore_diameter_mm = 40; //[20:80:0.1]
outer_diameter_mm = 52; //[26:104:0.1]
width_mm = 7; //[3.5:14:0.1]
shield_type = 0; //[0:2:1]
flange_diameter_mm = 0; //[0:104:0.1]
flange_width_mm = 0; //[0:14:0.1]
eps_mm = 0.6; //[0.2:2:0.1]
outer_race_radial_thickness_mm = 2.2; //[1.1:4.4:0.1]
inner_race_radial_thickness_mm = 2.2; //[1.1:4.4:0.1]
ball_diameter_mm = 3.2; //[1.6:6.4:0.1]
ball_count = 10; //[6:20:1]
shield_thickness_mm = 0.4; //[0.2:1.2:0.05]
shield_radial_overlap_mm = 1.0; //[0.5:2.0:0.1]

// Connectivity overlap (1-2mm) to guarantee fusion
connect_overlap_mm = 1.2;

// Bearing Ball
module bearing_ball() {
  sphere(r=ball_diameter_mm/2, $fn=32);
}

// Ball Bearing
module ball_bearing() {

  // Key radii
  r_bore   = bore_diameter_mm/2;
  r_outer  = outer_diameter_mm/2;

  r_inner_race_od = r_bore + inner_race_radial_thickness_mm;
  r_outer_race_id = r_outer - outer_race_radial_thickness_mm;

  // Ball path radius (midway between inner race OD and outer race ID)
  r_ball_path = (r_inner_race_od + r_outer_race_id)/2;

  // --- Structural fix: add a "connector cage" that physically intersects:
  // 1) the balls
  // 2) the inner race (slight overlap)
  // 3) the outer race (slight overlap)
  //
  // This guarantees the balls are not floating and everything becomes one connected solid.
  //
  // Make the cage thick enough to reach into both races by ~connect_overlap_mm.
  cage_r_in  = (r_inner_race_od - connect_overlap_mm); // overlaps inner race OD
  cage_r_out = (r_outer_race_id + connect_overlap_mm); // overlaps outer race ID

  // Ensure cage is valid even with extreme parameters
  cage_r_in  = min(cage_r_in,  cage_r_out - 0.5);
  cage_r_out = max(cage_r_out, cage_r_in  + 0.5);

  // Axial thickness: ensure it intersects balls (balls are centered at z=0)
  cage_h = min(width_mm, ball_diameter_mm + 2*connect_overlap_mm);

  union() {

    // Races + optional features + connector cage are all in the same union
    color("DimGray") {

      // Outer Race
      difference() {
        cylinder(r=r_outer, h=width_mm, center=true, $fn=96);
        cylinder(r=r_outer_race_id, h=width_mm + 2*eps_mm, center=true, $fn=96);
      }

      // Inner Race
      difference() {
        cylinder(r=r_inner_race_od, h=width_mm, center=true, $fn=96);
        cylinder(r=r_bore, h=width_mm + 2*eps_mm, center=true, $fn=96);
      }

      // Flange (if applicable) - positioned to overlap outer race by connect_overlap_mm
      if (flange_diameter_mm > 0 && flange_width_mm > 0) {
        flange_z = (width_mm/2 - flange_width_mm/2) - connect_overlap_mm; // overlap into race
        difference() {
          translate([0, 0, flange_z])
            cylinder(r=flange_diameter_mm/2, h=flange_width_mm, center=true, $fn=96);
          translate([0, 0, flange_z])
            cylinder(r=r_outer_race_id, h=flange_width_mm + 2*eps_mm, center=true, $fn=96);
        }
      }

      // Shields or Seals (if applicable) - positioned to overlap outer race by connect_overlap_mm
      if (shield_type > 0) {
        shield_z = (width_mm/2 - shield_thickness_mm/2) - connect_overlap_mm;

        difference() {
          translate([0, 0,  shield_z])
            cylinder(r=r_outer_race_id + shield_radial_overlap_mm, h=shield_thickness_mm, center=true, $fn=96);
          translate([0, 0,  shield_z])
            cylinder(r=r_inner_race_od - shield_radial_overlap_mm, h=shield_thickness_mm + 2*eps_mm, center=true, $fn=96);
        }
        difference() {
          translate([0, 0, -shield_z])
            cylinder(r=r_outer_race_id + shield_radial_overlap_mm, h=shield_thickness_mm, center=true, $fn=96);
          translate([0, 0, -shield_z])
            cylinder(r=r_inner_race_od - shield_radial_overlap_mm, h=shield_thickness_mm + 2*eps_mm, center=true, $fn=96);
        }
      }

      // Connector cage ring (structural connector)
      // Overlaps inner race OD and outer race ID by ~connect_overlap_mm.
      difference() {
        cylinder(r=cage_r_out, h=cage_h, center=true, $fn=128);
        cylinder(r=cage_r_in,  h=cage_h + 2*eps_mm, center=true, $fn=128);
      }
    }

    // Bearing Balls (now guaranteed to intersect the connector cage ring)
    // Also slightly "push" balls radially into the cage by a tiny amount to avoid tangency-only contact.
    color("Silver") {
      ball_push_mm = 0.4; // small extra intersection margin (keeps design visually the same)
      for (i = [0:ball_count-1]) {
        rotate([0, 0, i*360/ball_count])
          translate([r_ball_path + ball_push_mm, 0, 0])
            bearing_ball();
      }
    }
  }
}

// Assembly
module assembly() {
  ball_bearing();
}

assembly();