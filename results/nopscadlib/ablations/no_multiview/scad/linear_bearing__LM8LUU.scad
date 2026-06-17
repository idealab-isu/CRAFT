// Parameters
bore_diameter_mm = 8; //[4:16:0.1]
outer_diameter_mm = 15; //[8:30:0.1]
length_mm = 45; //[25:90:0.5]
bore_radius_mm = 4; //[2:8:0.1]
outer_radius_mm = 7.5; //[4:15:0.1]
casing_thickness_mm = 0.8; //[0.4:2:0.05]
groove_length_mm = 1.6; //[0.8:4:0.1]
groove_depth_mm = 0.6; //[0.2:1.5:0.05]
groove_spacing_mm = 30; //[10:70:0.5]
seal_thickness_mm = 1.5; //[0.8:3:0.1]
seal_outer_clearance_mm = 0.2; //[0.05:0.6:0.05]
seal_inner_clearance_mm = 0.15; //[0.05:0.5:0.05]
eps_mm = 0.2; //[0.05:0.5:0.05]
overlap_mm = 1; //[0.5:2:0.1]
screw_shank_diameter_mm = 3; //[2:6:0.1]
screw_length_mm = 12; //[6:30:0.5]
screw_head_diameter_mm = 5.5; //[4:12:0.1]
screw_head_height_mm = 2.5; //[1.5:6:0.1]
washer_outer_diameter_mm = 7; //[5:16:0.1]
washer_thickness_mm = 1; //[0.5:3:0.1]

// Linear Bearing - complete geometry
module linear_bearing() {
  color("Silver")
  union() {
    // Outer casing with bore and grooves removed
    difference() {
      cylinder(r=outer_diameter_mm/2, h=length_mm, center=true, $fn=64);

      // Inner bore
      cylinder(r=bore_diameter_mm/2, h=length_mm + 2*eps_mm, center=true, $fn=64);

      // Grooves
      translate([0, 0, groove_spacing_mm/2])
        cylinder(r=outer_diameter_mm/2 - groove_depth_mm, h=groove_length_mm, center=true, $fn=64);
      translate([0, 0, -groove_spacing_mm/2])
        cylinder(r=outer_diameter_mm/2 - groove_depth_mm, h=groove_length_mm, center=true, $fn=64);
    }

    // End seals (overlapped into the casing so they are physically connected)
    for (zsgn = [-1, 1]) {
      translate([0, 0, zsgn*(length_mm/2 - seal_thickness_mm/2 + overlap_mm)])
        difference() {
          cylinder(r=outer_diameter_mm/2 - casing_thickness_mm - seal_outer_clearance_mm,
                   h=seal_thickness_mm, center=true, $fn=64);
          cylinder(r=bore_diameter_mm/2 + seal_inner_clearance_mm,
                   h=seal_thickness_mm + 2*eps_mm, center=true, $fn=64);
        }
    }
  }
}

// Screw and Washer - FIXED: rotate cylinders so their axis is along X and chain-overlap all parts
module screw_and_washer_attached() {
  // Bearing outer surface at +X
  x_face = outer_diameter_mm/2;

  // Place parts so they INTERSECT (not just "near"):
  // Washer overlaps into bearing by overlap_mm
  x_washer = x_face + washer_thickness_mm/2 - overlap_mm;

  // Shank overlaps into washer by overlap_mm
  x_shank  = x_face + washer_thickness_mm + screw_length_mm/2 - 2*overlap_mm;

  // Head overlaps into shank by overlap_mm
  x_head   = x_face + washer_thickness_mm + screw_length_mm + screw_head_height_mm/2 - 3*overlap_mm;

  color("DimGray")
  union() {
    // Washer (axis along X)
    translate([x_washer, 0, 0])
      rotate([0, 90, 0])
        difference() {
          cylinder(r=washer_outer_diameter_mm/2, h=washer_thickness_mm, center=true, $fn=64);
          cylinder(r=screw_shank_diameter_mm/2 + eps_mm, h=washer_thickness_mm + 2*eps_mm, center=true, $fn=64);
        }

    // Screw shank (axis along X)
    translate([x_shank, 0, 0])
      rotate([0, 90, 0])
        cylinder(r=screw_shank_diameter_mm/2, h=screw_length_mm, center=true, $fn=64);

    // Screw head (axis along X)
    translate([x_head, 0, 0])
      rotate([0, 90, 0])
        cylinder(r=screw_head_diameter_mm/2, h=screw_head_height_mm, center=true, $fn=64);
  }
}

// Assembly (single connected solid)
module assembly() {
  union() {
    linear_bearing();
    screw_and_washer_attached();
  }
}

assembly();