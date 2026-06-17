// Parameters
bore_diameter_mm = 5; //[2.5:10:0.1]
outer_diameter_mm = 10; //[5:20:0.1]
length_mm = 28; //[14:56:0.5]
wall_thickness_mm = 2.5; //[1.25:5:0.1]
fit_clearance_mm = 0.2; //[0.05:0.5:0.05]
overlap_mm = 1; //[0.5:2:0.1]
screw_shank_diameter_mm = 3; //[2:6:0.1]
screw_length_mm = 8; //[4:16:0.5]
screw_head_diameter_mm = 6; //[4:12:0.1]
screw_head_height_mm = 2.5; //[1.5:5:0.1]
washer_outer_diameter_mm = 8; //[5:16:0.1]
washer_thickness_mm = 1; //[0.5:2.5:0.1]

// Derived radii
bearing_r = outer_diameter_mm/2;
bore_r    = (bore_diameter_mm + fit_clearance_mm)/2;

// Linear Bearing - complete geometry (the required missing part)
module linear_bearing() {
  color([0.85, 0.85, 0.8])
  difference() {
    // Outer casing
    cylinder(h=length_mm, r=bearing_r, center=true);
    // Inner bore (slightly longer to ensure clean cut)
    cylinder(h=length_mm + 2*overlap_mm, r=bore_r, center=true);
  }
}

// Screw and Washer - attached to the bearing with guaranteed overlap
module screw_and_washer_attached() {
  // Attach along +X, with 1-2mm overlap into the bearing OD
  // Place the shank so its inner end penetrates the bearing by overlap_mm.
  shank_center_x = bearing_r + screw_length_mm/2 - overlap_mm;

  // Place washer and head further out from the bearing, still on the same axis.
  washer_center_x = bearing_r + washer_thickness_mm/2 - overlap_mm;
  head_center_x   = bearing_r + washer_thickness_mm + screw_head_height_mm/2 - overlap_mm;

  color("DimGray")
  union() {
    // Screw shank
    translate([shank_center_x, 0, 0])
      rotate([0, 90, 0])
      cylinder(h=screw_length_mm, r=screw_shank_diameter_mm/2, center=true);

    // Washer (between head and bearing)
    translate([washer_center_x, 0, 0])
      rotate([0, 90, 0])
      cylinder(h=washer_thickness_mm, r=washer_outer_diameter_mm/2, center=true);

    // Screw head
    translate([head_center_x, 0, 0])
      rotate([0, 90, 0])
      cylinder(h=screw_head_height_mm, r=screw_head_diameter_mm/2, center=true);
  }
}

// Assembly: single connected solid
module assembly() {
  union() {
    linear_bearing();
    screw_and_washer_attached();
  }
}

assembly();