// Parameters
bore_diameter_mm = 3.0; //[1.5:6.0:0.1]
outer_diameter_mm = 7.0; //[3.5:14.0:0.1]
length_mm = 10.0; //[5.0:20.0:0.1]
bore_radius_mm = bore_diameter_mm/2; //[0.75:3.0:0.05]
outer_radius_mm = outer_diameter_mm/2; //[1.75:7.0:0.05]
casing_thickness_mm = 0.7; //[0.35:1.4:0.05]
eps_overlap_mm = 1.0; //[0.5:2.0:0.1]
screw_shank_radius_mm = 1.0; //[0.6:2.0:0.05]
screw_length_mm = 8.0; //[4.0:16.0:0.5]
screw_head_radius_mm = 2.0; //[1.0:4.0:0.1]
screw_head_height_mm = 2.0; //[1.0:4.0:0.1]
washer_outer_radius_mm = 2.5; //[1.5:5.0:0.1]
washer_thickness_mm = 0.8; //[0.4:1.6:0.05]

// Linear Bearing (added/fixed): outer shell with through-bore
// NOTE: The original code accidentally subtracted almost the entire body,
// leaving no bearing. This creates a proper connected bearing shell.
module linear_bearing() {
  color("DimGray")
  difference() {
    // Outer body
    cylinder(r=outer_radius_mm, h=length_mm, center=true);

    // Inner bore (extend a bit to ensure clean cut)
    cylinder(r=bore_radius_mm, h=length_mm + 2*eps_overlap_mm, center=true);
  }
}

// Screw and Washer - positioned to intersect bearing by eps_overlap_mm
module screw_and_washer() {
  // Place screw along +X, starting slightly inside bearing OD for guaranteed connection
  // Bearing outer surface at x = outer_radius_mm
  // Shank spans [x0 - L/2, x0 + L/2] where x0 is its center.
  // Set left end = outer_radius_mm - eps_overlap_mm  => x0 = outer_radius_mm - eps_overlap_mm + L/2
  shank_center_x = outer_radius_mm - eps_overlap_mm + screw_length_mm/2;

  // Washer sits between shank and head with slight overlap
  washer_center_x = shank_center_x + screw_length_mm/2 + washer_thickness_mm/2 - eps_overlap_mm;

  // Head sits after washer with slight overlap
  head_center_x  = shank_center_x + screw_length_mm/2 + washer_thickness_mm + screw_head_height_mm/2 - 2*eps_overlap_mm;

  color("Silver")
  union() {
    // Screw shank
    translate([shank_center_x, 0, 0])
      rotate([0, 90, 0])
      cylinder(r=screw_shank_radius_mm, h=screw_length_mm, center=true);

    // Washer (ring)
    difference() {
      translate([washer_center_x, 0, 0])
        rotate([0, 90, 0])
        cylinder(r=washer_outer_radius_mm, h=washer_thickness_mm, center=true);

      translate([washer_center_x, 0, 0])
        rotate([0, 90, 0])
        cylinder(r=screw_shank_radius_mm + eps_overlap_mm/4,
                 h=washer_thickness_mm + 2*eps_overlap_mm, center=true);
    }

    // Screw head
    translate([head_center_x, 0, 0])
      rotate([0, 90, 0])
      cylinder(r=screw_head_radius_mm, h=screw_head_height_mm, center=true);
  }
}

// Assembly - ensure everything is one connected solid
module assembly() {
  union() {
    linear_bearing();      // bearing is now present and solid
    screw_and_washer();    // overlaps bearing by eps_overlap_mm
  }
}

assembly();