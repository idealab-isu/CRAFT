// Parameters
bore_diameter_mm = 3.0; //[1.5:6.0:0.1]
outer_diameter_mm = 7.0; //[3.5:14.0:0.1]
length_mm = 10.0; //[5.0:20.0:0.1]
bore_radius_mm = 1.5; //[0.75:3.0:0.05]
outer_radius_mm = 3.5; //[1.75:7.0:0.05]
casing_thickness_mm = 0.7; //[0.4:1.4:0.05]
bore_clearance_mm = 0.1; //[0.0:0.3:0.01]
overlap_mm = 1.0; //[0.5:2.0:0.1]
screw_shank_radius_mm = 0.8; //[0.5:1.6:0.05]
screw_length_mm = 8.0; //[4.0:16.0:0.5]
screw_head_radius_mm = 1.6; //[1.0:3.2:0.05]
screw_head_height_mm = 1.6; //[0.8:3.2:0.05]
washer_radius_mm = 2.2; //[1.5:4.4:0.05]
washer_thickness_mm = 0.6; //[0.3:1.2:0.05]

// Linear Bearing (LM3UU) - complete geometry (single solid with bore)
module linear_bearing() {
  color([0.85, 0.85, 0.8])
  difference() {
    // Outer body
    cylinder(r=outer_radius_mm, h=length_mm, center=true);

    // Through bore (slightly longer to guarantee cut)
    cylinder(r=bore_radius_mm + bore_clearance_mm,
             h=length_mm + 2*overlap_mm, center=true);
  }
}

// Screw and Washer - positioned to INTERSECT the bearing by overlap_mm
module screw_and_washer() {
  // Bearing OD in +X is at x = +outer_radius_mm.
  // Place washer so its inner face is inside the bearing by overlap_mm.
  washer_center_x = outer_radius_mm + washer_thickness_mm/2 - overlap_mm;

  // Place shank so its left face is inside the washer by overlap_mm.
  shank_center_x  = (washer_center_x + washer_thickness_mm/2) + screw_length_mm/2 - overlap_mm;

  // Place head so its left face is inside the shank by overlap_mm.
  head_center_x   = (shank_center_x + screw_length_mm/2) + screw_head_height_mm/2 - overlap_mm;

  color("Silver")
  union() {
    // Washer
    translate([washer_center_x, 0, 0])
      rotate([0, 90, 0])
        cylinder(r=washer_radius_mm, h=washer_thickness_mm, center=true);

    // Screw shank
    translate([shank_center_x, 0, 0])
      rotate([0, 90, 0])
        cylinder(r=screw_shank_radius_mm, h=screw_length_mm, center=true);

    // Screw head
    translate([head_center_x, 0, 0])
      rotate([0, 90, 0])
        cylinder(r=screw_head_radius_mm, h=screw_head_height_mm, center=true);
  }
}

// Assembly: ensure everything is one connected solid and includes the missing linear bearing
module assembly() {
  union() {
    linear_bearing();     // REQUIRED: linear bearing present
    screw_and_washer();   // Intersects bearing/washer/shank/head by overlap_mm
  }
}

assembly();