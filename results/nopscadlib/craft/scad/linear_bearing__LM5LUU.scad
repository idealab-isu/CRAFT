// Parameters
bore_diameter_mm = 5; //[2.5:10:0.1]
outer_diameter_mm = 10; //[5:20:0.1]
length_mm = 28; //[14:56:0.5]
overlap_mm = 1; //[0.5:2:0.1]
lip_thickness_mm = 1; //[0.5:2:0.1]
lip_radial_mm = 0.6; //[0.3:1.5:0.1]
lip_clearance_mm = 0.2; //[0.05:0.5:0.05]
screw_shank_d_mm = 3; //[2:6:0.1]
screw_length_mm = 12; //[6:30:0.5]
screw_head_d_mm = 5.5; //[4:12:0.1]
screw_head_h_mm = 2.5; //[1.5:6:0.1]
washer_od_mm = 7; //[5:16:0.1]
washer_thickness_mm = 1; //[0.5:3:0.1]

// Linear Bearing (present + solid body with bore)
module linear_bearing() {
  color([0.85, 0.85, 0.8])
  union() {
    // Outer casing with through bore removed
    difference() {
      cylinder(r=outer_diameter_mm/2, h=length_mm, center=true);
      cylinder(r=bore_diameter_mm/2, h=length_mm + 2*overlap_mm, center=true);
    }

    // End seal lips (rings inside bore; overlap slightly with body)
    for (zsign = [-1, 1]) {
      translate([0, 0, zsign*(length_mm/2 - lip_thickness_mm/2 - overlap_mm/2)])
      difference() {
        cylinder(r=bore_diameter_mm/2 - lip_radial_mm, h=lip_thickness_mm + overlap_mm, center=true);
        cylinder(r=bore_diameter_mm/2 - lip_radial_mm - lip_clearance_mm,
                 h=lip_thickness_mm + overlap_mm + 2*overlap_mm, center=true);
      }
    }
  }
}

// Screw and Washer (single solid)
module screw_and_washer() {
  color("DimGray")
  union() {
    // Screw shank
    cylinder(r=screw_shank_d_mm/2, h=screw_length_mm, center=true);

    // Screw head (overlaps shank)
    translate([0, 0, screw_length_mm/2 + screw_head_h_mm/2 - overlap_mm])
      cylinder(r=screw_head_d_mm/2, h=screw_head_h_mm, center=true);

    // Washer (ring, overlaps head)
    difference() {
      translate([0, 0, screw_length_mm/2 + washer_thickness_mm/2 - overlap_mm])
        cylinder(r=washer_od_mm/2, h=washer_thickness_mm, center=true);
      translate([0, 0, screw_length_mm/2 + washer_thickness_mm/2 - overlap_mm])
        cylinder(r=screw_shank_d_mm/2 + lip_clearance_mm,
                 h=washer_thickness_mm + 2*overlap_mm, center=true);
    }
  }
}

// Assembly: all parts connected, single union, with guaranteed 1-2mm overlap
module assembly() {
  union() {
    // Linear bearing (required missing part) - main body
    linear_bearing();

    // Attach screw/washer to bearing OD with overlap.
    // After rotate([0,90,0]), screw's axis is along X and its X-extent is +/- screw_length_mm/2.
    // Place so the screw's left end is inside the bearing by overlap_mm:
    // left_end_x = x_pos - screw_length/2 = outer_diameter/2 - overlap
    // => x_pos = outer_diameter/2 + screw_length/2 - overlap
    translate([outer_diameter_mm/2 + screw_length_mm/2 - overlap_mm, 0, 0])
      rotate([0, 90, 0]) screw_and_washer();
  }
}

assembly();