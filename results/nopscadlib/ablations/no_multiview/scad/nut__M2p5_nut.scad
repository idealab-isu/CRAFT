// Parameters
thread_nominal_diameter_mm = 2.5; //[1.25:5:0.05]
thread_pitch_mm = 0.45; //[0.2:1:0.01]
across_flats_mm = 5.8; //[2.9:11.6:0.05]
thickness_mm = 2.2; //[1.1:4.4:0.05]
across_corners_mm = 6.697; //[3.3485:13.394:0.05]
outer_circumradius_mm = 3.348; //[1.674:6.696:0.01]
inner_hole_diameter_mm = 2.5; //[1.25:5:0.05]
chamfer_mm = 0.2; //[0.1:0.6:0.05]
tolerance_mm = 0; //[-0.2:0.3:0.01]
eps_mm = 0.02; //[0.01:0.1:0.01]

// Use 1–2mm overlap to guarantee connectivity between stacked parts
overlap_mm = 1.2; //[0.2:2:0.1]

washer_outer_diameter_mm = 6.5; //[3.25:13:0.1]
washer_thickness_mm = 0.6; //[0.3:1.2:0.05]

// Derived
hex_R = (across_flats_mm/2)/cos(30); // circumradius for $fn=6 cylinder

// Hexagonal Nut
module hex_nut() {
  difference() {
    // Single continuous nut body (no stacked/disconnected rings)
    cylinder(h=thickness_mm, r=hex_R, center=true, $fn=6);

    // Central hole (through)
    cylinder(h=thickness_mm + 2*overlap_mm, r=(inner_hole_diameter_mm + tolerance_mm)/2, center=true);

    // Chamfers cut from the same body (keeps one solid, avoids "separated top/bottom")
    // Top chamfer cutter
    translate([0, 0,  thickness_mm/2 - chamfer_mm/2 + eps_mm])
      cylinder(h=chamfer_mm + 2*eps_mm,
               r1=hex_R + 0.01,          // slightly larger to ensure clean cut
               r2=hex_R - chamfer_mm,
               center=true, $fn=6);

    // Bottom chamfer cutter
    translate([0, 0, -thickness_mm/2 + chamfer_mm/2 - eps_mm])
      cylinder(h=chamfer_mm + 2*eps_mm,
               r1=hex_R - chamfer_mm,
               r2=hex_R + 0.01,
               center=true, $fn=6);
  }
}

// Washer (attached to nut with guaranteed overlap)
module washer_attached() {
  // Place washer directly under nut and overlap into nut by overlap_mm
  // Nut bottom is at z = -thickness_mm/2
  // Washer top is at z = z_w + washer_thickness_mm/2
  // Enforce: washer top = nut bottom + overlap_mm  => z_w = -thickness_mm/2 + overlap_mm - washer_thickness_mm/2
  z_w = -thickness_mm/2 + overlap_mm - washer_thickness_mm/2;

  translate([0, 0, z_w])
    difference() {
      cylinder(h=washer_thickness_mm, r=washer_outer_diameter_mm/2, center=true);
      cylinder(h=washer_thickness_mm + 2*overlap_mm, r=(inner_hole_diameter_mm + tolerance_mm)/2, center=true);
    }
}

// Final Assembly: union into a single connected solid
module assembly() {
  union() {
    hex_nut();
    washer_attached();
  }
}

assembly();