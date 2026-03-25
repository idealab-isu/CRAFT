// Parameters
bore_diameter_mm = 4.0; //[2.0:8.0:0.1]
outer_diameter_mm = 8.0; //[4.0:16.0:0.1]
length_mm = 23.0; //[12.0:46.0:0.5]
connect_overlap_mm = 1.0; //[0.5:2.0:0.1]

screw_shank_diameter_mm = 3.0; //[2.0:6.0:0.1]
screw_length_mm = 10.0; //[5.0:25.0:0.5]
screw_head_diameter_mm = 5.5; //[3.0:12.0:0.1]
screw_head_height_mm = 2.5; //[1.0:6.0:0.1]

washer_outer_diameter_mm = 7.0; //[4.0:16.0:0.1]
washer_thickness_mm = 1.0; //[0.5:3.0:0.1]
washer_hole_diameter_mm = 3.2; //[2.2:6.5:0.1]

// Linear bearing (MISSING PART FIX: ensure it exists and is included in final union)
module linear_bearing() {
  color("DimGray")
  difference() {
    // Outer casing
    cylinder(r=outer_diameter_mm/2, h=length_mm, center=true);
    // Inner bore (slightly longer to ensure clean through-hole)
    cylinder(r=bore_diameter_mm/2, h=length_mm + 2*connect_overlap_mm, center=true);
  }
}

// Screw + washer + small flanged cylindrical piece (all physically attached)
module screw_and_washer_attached() {
  bearing_r = outer_diameter_mm/2;

  // Place the screw axis along +X, starting slightly inside the bearing OD
  // so the shank intersects the bearing by connect_overlap_mm.
  shank_center_x = bearing_r - connect_overlap_mm + screw_length_mm/2;

  // Washer sits at the far end of the shank, overlapping the shank by connect_overlap_mm
  washer_center_x = (bearing_r - connect_overlap_mm + screw_length_mm) - washer_thickness_mm/2;

  // Flanged cylindrical piece (modeled as a short hub + flange) attached to washer/shank
  flange_thk = washer_thickness_mm;
  hub_len    = screw_head_height_mm;
  hub_d      = screw_head_diameter_mm;
  flange_d   = washer_outer_diameter_mm;

  // Hub starts at the shank end and overlaps into the shank by connect_overlap_mm
  hub_center_x = (bearing_r - connect_overlap_mm + screw_length_mm) + hub_len/2 - connect_overlap_mm;

  // Flange sits at the far end of the hub and overlaps into the hub by connect_overlap_mm
  flange_center_x = (bearing_r - connect_overlap_mm + screw_length_mm + hub_len) - flange_thk/2 - connect_overlap_mm;

  color("Silver")
  union() {
    // Screw shank (connected to bearing by overlap)
    translate([shank_center_x, 0, 0])
      rotate([0, 90, 0])
      cylinder(r=screw_shank_diameter_mm/2, h=screw_length_mm, center=true);

    // Washer (connected to shank by overlap)
    difference() {
      translate([washer_center_x, 0, 0])
        rotate([0, 90, 0])
        cylinder(r=washer_outer_diameter_mm/2, h=washer_thickness_mm, center=true);

      translate([washer_center_x, 0, 0])
        rotate([0, 90, 0])
        cylinder(r=washer_hole_diameter_mm/2, h=washer_thickness_mm + 2*connect_overlap_mm, center=true);
    }

    // Small flanged cylindrical piece (CONNECTED; no floating)
    // Hub
    translate([hub_center_x, 0, 0])
      rotate([0, 90, 0])
      cylinder(r=hub_d/2, h=hub_len, center=true);

    // Flange
    translate([flange_center_x, 0, 0])
      rotate([0, 90, 0])
      cylinder(r=flange_d/2, h=flange_thk, center=true);
  }
}

// Assembly: single connected solid via union()
// Structural fix: ensure the linear bearing is present AND physically connected to the screw.
// The screw already intersects the bearing by connect_overlap_mm, so union() makes one solid.
module assembly() {
  union() {
    linear_bearing();              // REQUIRED missing part added/kept
    screw_and_washer_attached();   // Attached with overlap into bearing OD
  }
}

assembly();