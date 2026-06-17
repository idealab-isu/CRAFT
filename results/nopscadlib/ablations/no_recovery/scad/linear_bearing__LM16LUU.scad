// Parameters
bore_diameter_mm = 16; //[8:32:0.5]
outer_diameter_mm = 28; //[14:56:0.5]
length_mm = 70; //[35:140:1]
wall_thickness_mm = 6; //[3:12:0.5]
centered = 1; //[0:1:1]
has_external_grooves = 0; //[0:1:1]
groove_diameter_mm = 26; //[20:27.5:0.5]
groove_length_mm = 3; //[1:10:0.5]
groove_spacing_mm = 50; //[20:120:1]
seal_thickness_mm = 2; //[1:5:0.5]
seal_radial_thickness_mm = 2; //[1:5:0.5]
eps_mm = 0.5; //[0.2:2:0.1]
screw_shank_diameter_mm = 4; //[2:8:0.5]
screw_length_mm = 20; //[10:60:1]
screw_head_diameter_mm = 8; //[4:16:0.5]
screw_head_height_mm = 3; //[1.5:8:0.5]
washer_outer_diameter_mm = 10; //[6:24:0.5]
washer_thickness_mm = 1.5; //[0.8:4:0.1]

// Linear Bearing - complete geometry
module linear_bearing() {
  color("DimGray") {
    // Outer casing
    difference() {
      cylinder(h=length_mm, r=outer_diameter_mm/2, center=true);
      // Inner bore
      translate([0, 0, 0])
        cylinder(h=length_mm + 2*eps_mm, r=bore_diameter_mm/2, center=true);
    }
    // End seals
    union() {
      // Left seal
      translate([0, 0, -length_mm/2 + seal_thickness_mm/2 - eps_mm])
        difference() {
          cylinder(h=seal_thickness_mm, r=bore_diameter_mm/2 + seal_radial_thickness_mm, center=true);
          cylinder(h=seal_thickness_mm + 2*eps_mm, r=bore_diameter_mm/2, center=true);
        }
      // Right seal
      translate([0, 0, length_mm/2 - seal_thickness_mm/2 + eps_mm])
        difference() {
          cylinder(h=seal_thickness_mm, r=bore_diameter_mm/2 + seal_radial_thickness_mm, center=true);
          cylinder(h=seal_thickness_mm + 2*eps_mm, r=bore_diameter_mm/2, center=true);
        }
    }
    // Optional grooves
    if (has_external_grooves) {
      difference() {
        // Left groove
        translate([0, 0, -groove_spacing_mm/2])
          difference() {
            cylinder(h=groove_length_mm, r=outer_diameter_mm/2, center=true);
            cylinder(h=groove_length_mm + 2*eps_mm, r=groove_diameter_mm/2, center=true);
          }
        // Right groove
        translate([0, 0, groove_spacing_mm/2])
          difference() {
            cylinder(h=groove_length_mm, r=outer_diameter_mm/2, center=true);
            cylinder(h=groove_length_mm + 2*eps_mm, r=groove_diameter_mm/2, center=true);
          }
      }
    }
  }
}

// Screw and Washer - complete geometry
module screw_and_washer() {
  color("Silver") {
    // Screw shank
    translate([outer_diameter_mm/2 + screw_shank_diameter_mm/2 - eps_mm, 0, 0])
      rotate([0, 90, 0])
      cylinder(h=screw_length_mm, r=screw_shank_diameter_mm/2, center=true);
    // Screw head
    translate([outer_diameter_mm/2 + screw_length_mm + screw_head_height_mm/2 - eps_mm, 0, 0])
      rotate([0, 90, 0])
      cylinder(h=screw_head_height_mm, r=screw_head_diameter_mm/2, center=true);
    // Washer
    translate([outer_diameter_mm/2 + screw_length_mm - washer_thickness_mm/2 - eps_mm, 0, 0])
      rotate([0, 90, 0])
      difference() {
        cylinder(h=washer_thickness_mm, r=washer_outer_diameter_mm/2, center=true);
        cylinder(h=washer_thickness_mm + 2*eps_mm, r=screw_shank_diameter_mm/2, center=true);
      }
  }
}

// Assembly
module assembly() {
  linear_bearing();
  screw_and_washer();
}

assembly();