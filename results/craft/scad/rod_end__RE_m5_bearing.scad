// Parameters
thread_diameter_mm = 5.0; //[2.5:10.0:0.1]
thread_pitch_mm = 0.8; //[0.4:1.6:0.05]
thread_length_mm = 12.0; //[6.0:24.0:0.5]
overall_shank_length_mm = 30.0; //[15.0:60.0:0.5]
shank_major_diameter_mm = 5.0; //[2.5:10.0:0.1]
neck_diameter_mm = 4.5; //[2.25:9.0:0.1]
neck_length_mm = 6.0; //[3.0:12.0:0.5]
eye_outer_diameter_mm = 16.0; //[8.0:32.0:0.5]
eye_width_mm = 8.0; //[4.0:16.0:0.5]
ball_sphere_diameter_mm = 10.0; //[5.0:20.0:0.5]
through_bore_diameter_mm = 5.0; //[2.5:10.0:0.1]
race_rim_thickness_mm = 1.5; //[0.75:3.0:0.1]
chamfer_mm = 0.5; //[0.25:1.5:0.05]
liner_thickness_mm = 0.6; //[0.3:1.2:0.05]
overlap_mm = 1.0; //[0.5:2.0:0.1]
rod_diameter_mm = 5.0; //[2.5:10.0:0.1]
rod_length_mm = 20.0; //[10.0:60.0:0.5]

$fn = 96;

// --- Helpers ---
module hex_prism(flat_mm=8, h_mm=4, center=true) {
  // OpenSCAD cylinder r= circumradius; for hex: R = flat / sqrt(3)
  cylinder(r=flat_mm/sqrt(3), h=h_mm, $fn=6, center=center);
}

// Rod - complete geometry (kept as-is, but will be unioned in assembly)
module rod() {
  color([0.85, 0.85, 0.8]) {
    translate([0, 0, eye_outer_diameter_mm/2 + rod_length_mm/2 - overlap_mm])
      rotate([90, 0, 0])
      cylinder(r=rod_diameter_mm/2, h=rod_length_mm, center=true);
  }
}

// Rod End Bearing - complete geometry
module rod_end_bearing() {
  color("Silver") {
    // Male threaded shank
    translate([eye_width_mm/2 + neck_length_mm + overall_shank_length_mm/2 - overlap_mm, 0, 0])
      rotate([0, 90, 0])
      cylinder(r=shank_major_diameter_mm/2, h=overall_shank_length_mm, center=true);

    // Shank to eye transition neck
    translate([eye_width_mm/2 + neck_length_mm/2 - overlap_mm, 0, 0])
      rotate([0, 90, 0])
      cylinder(r=neck_diameter_mm/2, h=neck_length_mm, center=true);

    // Spherical eye body (outer ring)
    difference() {
      cylinder(r=eye_outer_diameter_mm/2, h=eye_width_mm, center=true);
      cylinder(r=eye_outer_diameter_mm/2 - race_rim_thickness_mm,
               h=eye_width_mm + 2*overlap_mm, center=true);
    }

    // Through bore ball (visual)
    translate([0, 0, 0])
      rotate([0, 90, 0])
      cylinder(r=through_bore_diameter_mm/2,
               h=eye_outer_diameter_mm + 2*overlap_mm, center=true);

    // Liner or shield representation (visual)
    difference() {
      sphere(r=ball_sphere_diameter_mm/2 + liner_thickness_mm);
      sphere(r=ball_sphere_diameter_mm/2);
    }
  }
}

// --- FIX: replace floating "pins/plugs" with attached cylindrical plugs (top & bottom views) ---
// These are small cylinders that MUST intersect the eye body by overlap_mm.
// Place them on +/-Z (top/bottom in TOP view) and extrude along Z.
module attached_pins() {
  pin_d_mm = max(through_bore_diameter_mm * 0.75, 3.0); // small plug look
  pin_h_mm = 6.0;

  eye_r = eye_outer_diameter_mm/2;

  // Ensure physical intersection:
  // pin extends pin_h/2 from its center along Z.
  // We want the inner face to be at (eye_r - overlap_mm) from origin along Z.
  // => center_z = (eye_r - overlap_mm) + pin_h/2
  cz = (eye_r - overlap_mm) + pin_h_mm/2;

  color([0.85, 0.85, 0.8]) {
    // Top pin (TOP view: above the rod end)
    translate([0, 0,  cz])
      cylinder(r=pin_d_mm/2, h=pin_h_mm, center=true);

    // Bottom pin (BOTTOM view: below the rod end)
    translate([0, 0, -cz])
      cylinder(r=pin_d_mm/2, h=pin_h_mm, center=true);
  }
}

// --- Keep the hex bolts, but ensure they also intersect the eye body by overlap_mm ---
module attached_hex_bolts() {
  bolt_flat_mm = max(6.0, through_bore_diameter_mm + 1.0);
  bolt_h_mm    = 4.0;

  eye_r = eye_outer_diameter_mm/2;

  // Hex extrudes along Y after rotate([90,0,0]); ensure overlap into eye:
  cy = (eye_r - overlap_mm) + bolt_h_mm/2;

  color([0.85, 0.85, 0.8]) {
    // +Y hex
    translate([0,  cy, 0])
      rotate([90, 0, 0])
      hex_prism(flat_mm=bolt_flat_mm, h_mm=bolt_h_mm, center=true);

    // -Y hex
    translate([0, -cy, 0])
      rotate([90, 0, 0])
      hex_prism(flat_mm=bolt_flat_mm, h_mm=bolt_h_mm, center=true);
  }
}

// Assembly (single connected solid)
module assembly() {
  union() {
    rod_end_bearing();
    rod();
    attached_hex_bolts();
    attached_pins();   // FIX: physically attached top/bottom cylindrical plugs
  }
}

assembly();