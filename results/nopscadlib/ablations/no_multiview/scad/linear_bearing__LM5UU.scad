// Parameters
bore_diameter_mm = 5; //[2.5:10:0.1]
outer_diameter_mm = 10; //[5:20:0.1]
length_mm = 15; //[7.5:30:0.1]
outer_radius_mm = outer_diameter_mm/2; //[2.5:10:0.1]
bore_radius_mm = bore_diameter_mm/2; //[1.25:5:0.1]
fit_clearance_mm = 0.1; //[0:0.5:0.01]
connect_overlap_mm = 1; //[0.5:2:0.1]
screw_shank_diameter_mm = 3; //[1.5:6:0.1]
screw_length_mm = 12; //[6:24:0.1]
screw_head_diameter_mm = 6; //[3:12:0.1]
screw_head_height_mm = 2.5; //[1.25:5:0.1]
washer_outer_diameter_mm = 7; //[3.5:14:0.1]
washer_thickness_mm = 1; //[0.5:2:0.1]

$fn = 96;

// Linear Bearing - complete geometry (present + used in final union)
module linear_bearing() {
  // Keep as a solid body with a bore (difference), centered at origin
  difference() {
    cylinder(r=outer_radius_mm, h=length_mm, center=true);
    cylinder(r=bore_radius_mm + fit_clearance_mm,
             h=length_mm + 2*connect_overlap_mm, center=true);
  }
}

// Screw and Washer - positioned to physically intersect the bearing OD by connect_overlap_mm
module screw_and_washer() {
  // Axis of screw is along Y (after rotate), so we place its center in Y so it overlaps the bearing.
  // Bearing outer surface is at y = outer_radius_mm.
  // For a cylinder of length L centered at y0, its near end is at y0 - L/2.
  // Set near end to be inside bearing by connect_overlap_mm: y0 - L/2 = outer_radius_mm - connect_overlap_mm
  // => y0 = outer_radius_mm - connect_overlap_mm + L/2
  y_shank_center = outer_radius_mm - connect_overlap_mm + screw_length_mm/2;

  // Washer and head are short cylinders along Y; place them so they also overlap the bearing by connect_overlap_mm.
  y_washer_center = outer_radius_mm - connect_overlap_mm + washer_thickness_mm/2;
  y_head_center   = outer_radius_mm - connect_overlap_mm + washer_thickness_mm + screw_head_height_mm/2;

  union() {
    // Screw shank
    translate([0, y_shank_center, 0])
      rotate([90, 0, 0])
      cylinder(r=screw_shank_diameter_mm/2, h=screw_length_mm, center=true);

    // Washer
    translate([0, y_washer_center, 0])
      rotate([90, 0, 0])
      cylinder(r=washer_outer_diameter_mm/2, h=washer_thickness_mm, center=true);

    // Screw head
    translate([0, y_head_center, 0])
      rotate([90, 0, 0])
      cylinder(r=screw_head_diameter_mm/2, h=screw_head_height_mm, center=true);
  }
}

// Assembly - single connected solid via union(), with guaranteed overlap
module assembly() {
  union() {
    // Linear bearing (missing part fixed by ensuring it is included in the final union)
    color("Silver") linear_bearing();

    // Stepped shaft/post (screw + washer + head) attached with 1mm overlap into bearing OD
    color("DimGray") screw_and_washer();
  }
}

assembly();