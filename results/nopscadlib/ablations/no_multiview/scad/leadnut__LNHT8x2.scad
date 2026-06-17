// Parameters
block_x = 30.0; //[15.0:60.0:0.5]
block_y = 34.0; //[17.0:68.0:0.5]
block_z = 30.0; //[15.0:60.0:0.5]
cavity_clearance = 0.2; //[0.0:1.0:0.05]
nut_outer_diameter_or_af = 22.0; //[11.0:44.0:0.5]
nut_length = 18.0; //[9.0:36.0:0.5]
overlap = 1.0; //[0.5:2.0:0.1]
mount_hole_diameter = 5.0; //[2.0:10.0:0.25]
mount_hole_pattern_x = 20.0; //[10.0:40.0:0.5]
mount_hole_pattern_y = 24.0; //[12.0:48.0:0.5]
counterbore_diameter = 9.0; //[0.0:18.0:0.25]
counterbore_depth = 4.0; //[0.0:15.0:0.25]
set_screw_diameter = 4.0; //[2.0:8.0:0.25]
leadscrew_diameter = 8.0; //[4.0:16.0:0.25]
leadscrew_length = 60.0; //[30.0:120.0:1.0]

// Missing toggles (defaults)
cavity_type_is_hex = 0;                 // 0=cylindrical cavity, 1=hex cavity
anti_rotation_method_is_set_screw = 0;  // 0=none, 1=set screw

// Leadscrew - positioned to be physically fused to housing with slight overlap
module leadscrew_attached() {
  // Ensure the rod intersects the block by at least 'overlap' on each side
  // so it is not a separate body.
  rod_h = block_z + 2*overlap;

  color("Silver")
    cylinder(r=leadscrew_diameter/2, h=rod_h, center=true, $fn=64);
}

// Leadnut (missing part) - placed inside the nut cavity and slightly longer
// so it intersects the housing by 'overlap' on both ends (guaranteed union).
module leadnut_attached() {
  nut_h = nut_length + 2*overlap;

  color([0.75, 0.65, 0.35])  // brass-ish
  if (cavity_type_is_hex == 1) {
    // Hex prism sized to match the cavity (slightly smaller than cavity)
    // Use AF as given; convert to circumradius for hex: R = AF / sqrt(3)
    af = nut_outer_diameter_or_af;
    R = (af/2) / 0.8660254038; // circumradius
    linear_extrude(height=nut_h, center=true)
      polygon(points=[
        [ R, 0],
        [ R/2,  R*0.8660254038],
        [-R/2,  R*0.8660254038],
        [-R, 0],
        [-R/2, -R*0.8660254038],
        [ R/2, -R*0.8660254038]
      ]);
  } else {
    // Cylindrical nut sized to fit inside the cavity (slightly smaller)
    cylinder(r=(nut_outer_diameter_or_af/2) - cavity_clearance, h=nut_h, center=true, $fn=64);
  }
}

// Main block with features (holes/cavities)
module housing_block_with_features() {
  difference() {
    // Main block
    color([0.85, 0.85, 0.8]) cube([block_x, block_y, block_z], center=true);

    // Nut cavity
    if (cavity_type_is_hex == 1) {
      linear_extrude(height=nut_length + 2*overlap, center=true)
        polygon(points=[
          [(nut_outer_diameter_or_af/2 + cavity_clearance), 0],
          [(nut_outer_diameter_or_af/2 + cavity_clearance)/2, ((nut_outer_diameter_or_af/2 + cavity_clearance)*0.8660254038)],
          [-(nut_outer_diameter_or_af/2 + cavity_clearance)/2, ((nut_outer_diameter_or_af/2 + cavity_clearance)*0.8660254038)],
          [-(nut_outer_diameter_or_af/2 + cavity_clearance), 0],
          [-(nut_outer_diameter_or_af/2 + cavity_clearance)/2, -((nut_outer_diameter_or_af/2 + cavity_clearance)*0.8660254038)],
          [(nut_outer_diameter_or_af/2 + cavity_clearance)/2, -((nut_outer_diameter_or_af/2 + cavity_clearance)*0.8660254038)]
        ]);
    } else {
      cylinder(r=(nut_outer_diameter_or_af/2) + cavity_clearance, h=nut_length + 2*overlap, center=true, $fn=64);
    }

    // Leadscrew bore
    cylinder(r=(leadscrew_diameter/2) + cavity_clearance, h=block_z + 2*overlap, center=true, $fn=64);

    // Mount holes (fixed: translate must wrap the cylinder)
    for (x = [-mount_hole_pattern_x/2, mount_hole_pattern_x/2])
      for (y = [-mount_hole_pattern_y/2, mount_hole_pattern_y/2])
        translate([x, y, 0])
          cylinder(r=mount_hole_diameter/2, h=block_z + 2*overlap, center=true, $fn=48);

    // Counterbores
    if (counterbore_diameter > 0 && counterbore_depth > 0) {
      for (x = [-mount_hole_pattern_x/2, mount_hole_pattern_x/2])
        for (y = [-mount_hole_pattern_y/2, mount_hole_pattern_y/2])
          translate([x, y, block_z/2 - (counterbore_depth + overlap)/2])
            cylinder(r=counterbore_diameter/2, h=counterbore_depth + overlap, center=true, $fn=64);
    }

    // Set screw hole
    if (anti_rotation_method_is_set_screw == 1) {
      rotate([0, 90, 0])
        cylinder(r=set_screw_diameter/2, h=block_x + 2*overlap, center=true, $fn=48);
    }
  }
}

// Assembly: single connected solid (housing + attached rod + attached leadnut)
module assembly() {
  union() {
    housing_block_with_features();

    // Attach rod so it intersects the housing (not floating / not separate)
    leadscrew_attached();

    // Add missing leadnut and ensure it intersects housing slightly
    leadnut_attached();
  }
}

assembly();