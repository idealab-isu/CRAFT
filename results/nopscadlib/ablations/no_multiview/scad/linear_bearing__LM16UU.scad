// Parameters
bore_diameter_mm = 16; //[8:32:0.5]
outer_diameter_mm = 28; //[14:56:0.5]
length_mm = 37; //[18.5:74:0.5]
bore_radius_mm = bore_diameter_mm/2; //[4:16:0.25]
outer_radius_mm = outer_diameter_mm/2; //[7:28:0.25]
casing_wall_thickness_mm = 2.2; //[1.1:4.4:0.1]
seal_length_mm = 3; //[1.5:6:0.25]
seal_radial_thickness_mm = 1.2; //[0.6:2.4:0.1]
groove_width_mm = 2.2; //[1.1:4.4:0.1]
groove_depth_mm = 0.6; //[0.3:1.2:0.05]
groove_spacing_mm = 26; //[13:52:0.5]
overlap_mm = 1; //[0.5:2:0.1]
screw_shank_diameter_mm = 5; //[2.5:10:0.5]
screw_length_mm = 12; //[6:24:0.5]
screw_head_diameter_mm = 9; //[4.5:18:0.5]
screw_head_height_mm = 3.5; //[1.75:7:0.25]
washer_outer_diameter_mm = 10; //[5:20:0.5]
washer_thickness_mm = 1.2; //[0.6:2.4:0.1]

$fn = 96;

// Linear Bearing - complete geometry
module linear_bearing() {
  color("DimGray")
  union() {
    // Bearing casing with grooves
    difference() {
      cylinder(r=outer_radius_mm, h=length_mm, center=true);
      cylinder(r=bore_radius_mm, h=length_mm + 2*overlap_mm, center=true);

      // External grooves (cut into OD)
      scale([(outer_radius_mm - groove_depth_mm)/outer_radius_mm,
             (outer_radius_mm - groove_depth_mm)/outer_radius_mm, 1]) {
        translate([0, 0, groove_spacing_mm/2])
          cylinder(r=outer_radius_mm, h=groove_width_mm, center=true);
        translate([0, 0, -groove_spacing_mm/2])
          cylinder(r=outer_radius_mm, h=groove_width_mm, center=true);
      }
    }

    // End seals (slightly overlapping into the casing)
    difference() {
      translate([0, 0, -length_mm/2 + seal_length_mm/2 + overlap_mm])
        cylinder(r=bore_radius_mm + seal_radial_thickness_mm, h=seal_length_mm, center=true);
      translate([0, 0, -length_mm/2 + seal_length_mm/2 + overlap_mm])
        cylinder(r=bore_radius_mm, h=seal_length_mm + 2*overlap_mm, center=true);
    }

    difference() {
      translate([0, 0,  length_mm/2 - seal_length_mm/2 - overlap_mm])
        cylinder(r=bore_radius_mm + seal_radial_thickness_mm, h=seal_length_mm, center=true);
      translate([0, 0,  length_mm/2 - seal_length_mm/2 - overlap_mm])
        cylinder(r=bore_radius_mm, h=seal_length_mm + 2*overlap_mm, center=true);
    }
  }
}

// Screw and Washer - attached to bearing OD with guaranteed overlap
module screw_and_washer() {
  // Place screw axis along +X, starting slightly inside the bearing OD
  // so it intersects the bearing by overlap_mm.
  x_shank_center  = outer_radius_mm + screw_length_mm/2 - overlap_mm;
  x_head_center   = outer_radius_mm + screw_length_mm + screw_head_height_mm/2 - overlap_mm;
  x_washer_center = outer_radius_mm + screw_length_mm + washer_thickness_mm/2 - overlap_mm;

  color("Silver")
  union() {
    // Screw shank
    translate([x_shank_center, 0, 0])
      rotate([0, 90, 0])
      cylinder(r=screw_shank_diameter_mm/2, h=screw_length_mm, center=true);

    // Screw head
    translate([x_head_center, 0, 0])
      rotate([0, 90, 0])
      cylinder(r=screw_head_diameter_mm/2, h=screw_head_height_mm, center=true);

    // Washer
    translate([x_washer_center, 0, 0])
      rotate([0, 90, 0])
      cylinder(r=washer_outer_diameter_mm/2, h=washer_thickness_mm, center=true);
  }
}

// Assembly: ensure a single connected solid via union()
module assembly() {
  union() {
    linear_bearing();     // (added/ensured present)
    screw_and_washer();   // intersects bearing by overlap_mm
  }
}

assembly();