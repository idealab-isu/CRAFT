// Parameters
bore_diameter_mm = 8; //[4:16:0.1]
outer_diameter_mm = 15; //[8:30:0.1]
length_mm = 24; //[12:48:0.1]
centered = 1; //[0:1:1]
include_seals = 1; //[0:1:1]
include_grooves = 0; //[0:1:1]
groove_count = 0; //[0:2:1]
groove_diameter_mm = 14; //[10:29:0.1]
groove_length_mm = 1.6; //[0.8:4:0.1]
groove_spacing_mm = 18; //[8:40:0.1]
casing_wall_thickness_mm = 1.2; //[0.6:3:0.1]
seal_radial_thickness_mm = 1.2; //[0.6:3:0.1]
seal_axial_thickness_mm = 1.2; //[0.6:3:0.1]
eps_mm = 0.2; //[0.05:0.5:0.05]
overlap_mm = 1; //[0.5:2:0.1]
screw_shank_diameter_mm = 4; //[2:8:0.1]
screw_length_mm = 16; //[8:40:0.5]
screw_head_diameter_mm = 7; //[4:14:0.1]
screw_head_height_mm = 3; //[1.5:8:0.1]
washer_outer_diameter_mm = 10; //[6:20:0.1]
washer_thickness_mm = 1; //[0.5:3:0.1]

// Linear Bearing - complete geometry
module linear_bearing() {
  color([0.85, 0.85, 0.8]) {
    // Outer casing
    difference() {
      cylinder(r=outer_diameter_mm/2, h=length_mm, center=true);
      cylinder(r=bore_diameter_mm/2, h=length_mm + 2*eps_mm, center=true);
    }
    
    // End seal rings
    if (include_seals) {
      union() {
        translate([0, 0, length_mm/2 - seal_axial_thickness_mm/2 + overlap_mm])
          difference() {
            cylinder(r=bore_diameter_mm/2 + seal_radial_thickness_mm, h=seal_axial_thickness_mm, center=true);
            cylinder(r=bore_diameter_mm/2, h=seal_axial_thickness_mm + 2*eps_mm, center=true);
          }
        translate([0, 0, -length_mm/2 + seal_axial_thickness_mm/2 - overlap_mm])
          difference() {
            cylinder(r=bore_diameter_mm/2 + seal_radial_thickness_mm, h=seal_axial_thickness_mm, center=true);
            cylinder(r=bore_diameter_mm/2, h=seal_axial_thickness_mm + 2*eps_mm, center=true);
          }
      }
    }
    
    // External grooves
    if (include_grooves && groove_count > 0) {
      difference() {
        cylinder(r=outer_diameter_mm/2, h=length_mm, center=true);
        for (i = [0:groove_count-1]) {
          translate([0, 0, (i - (groove_count-1)/2) * groove_spacing_mm])
            difference() {
              cylinder(r=outer_diameter_mm/2 + eps_mm, h=groove_length_mm, center=true);
              cylinder(r=groove_diameter_mm/2, h=groove_length_mm + 2*eps_mm, center=true);
            }
        }
      }
    }
  }
}

// Screw and Washer - complete geometry
module screw_and_washer() {
  color("Silver") {
    // Washer
    translate([outer_diameter_mm/2 + washer_outer_diameter_mm/2 - overlap_mm, 0, 0])
      difference() {
        cylinder(r=washer_outer_diameter_mm/2, h=washer_thickness_mm, center=true);
        cylinder(r=screw_shank_diameter_mm/2 + eps_mm, h=washer_thickness_mm + 2*eps_mm, center=true);
      }
    
    // Screw shank
    translate([outer_diameter_mm/2 + washer_outer_diameter_mm/2 - overlap_mm, 0, washer_thickness_mm/2 + screw_length_mm/2 - overlap_mm])
      cylinder(r=screw_shank_diameter_mm/2, h=screw_length_mm, center=true);
    
    // Screw head
    translate([outer_diameter_mm/2 + washer_outer_diameter_mm/2 - overlap_mm, 0, washer_thickness_mm/2 + screw_length_mm - overlap_mm + screw_head_height_mm/2])
      cylinder(r=screw_head_diameter_mm/2, h=screw_head_height_mm, center=true);
  }
}

// Assembly
module assembly() {
  linear_bearing();
  screw_and_washer();
}

assembly();