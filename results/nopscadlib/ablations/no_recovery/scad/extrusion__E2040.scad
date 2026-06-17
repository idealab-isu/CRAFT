// Parameters
cross_section_width_mm = 20; //[10:40:1]
cross_section_height_mm = 40; //[20:80:1]
length_mm = 100; //[50:200:1]
wall_thickness_mm = 2; //[1:4:0.25]
slot_opening_width_mm = 6; //[4:8:0.25]
slot_depth_mm = 6; //[4:10:0.25]
slot_neck_width_mm = 10; //[8:14:0.25]
center_bore_diameter_mm = 6; //[0:10:0.25]
web_thickness_mm = 2; //[1:4:0.25]
overlap_mm = 1; //[0.5:2:0.1]

// Extrusion - complete geometry
module extrusion() {
  color("Silver") {
    difference() {
      linear_extrude(height=length_mm, center=true) {
        square([cross_section_width_mm, cross_section_height_mm], center=true);
      }
      translate([0, 0, 0])
        linear_extrude(height=length_mm + 2*overlap_mm, center=true) {
          square([cross_section_width_mm - 2*wall_thickness_mm, cross_section_height_mm - 2*wall_thickness_mm], center=true);
        }
    }
  }
}

// Extrusion Cross Section - complete geometry
module extrusion_cross_section() {
  color("DimGray") {
    union() {
      linear_extrude(height=length_mm, center=true) {
        square([cross_section_width_mm - 2*wall_thickness_mm + 2*overlap_mm, web_thickness_mm], center=true);
      }
      linear_extrude(height=length_mm, center=true) {
        square([web_thickness_mm, cross_section_height_mm - 2*wall_thickness_mm + 2*overlap_mm], center=true);
      }
    }
  }
}

// Box Corner Profile Section - complete geometry
module box_corner_profile_section() {
  color("Black") {
    difference() {
      cube([slot_depth_mm + 2*overlap_mm, slot_opening_width_mm, length_mm + 2*overlap_mm], center=true);
      translate([cross_section_width_mm/2 - slot_depth_mm/2 + overlap_mm, 0, 0])
        cube([slot_depth_mm + 2*overlap_mm, slot_neck_width_mm, length_mm + 2*overlap_mm], center=true);
    }
  }
}

// Box Corner Profile Sections - complete geometry
module box_corner_profile_sections() {
  color("Black") {
    difference() {
      cube([slot_opening_width_mm, slot_depth_mm + 2*overlap_mm, length_mm + 2*overlap_mm], center=true);
      translate([0, cross_section_height_mm/2 - slot_depth_mm/2 + overlap_mm, 0])
        cube([slot_neck_width_mm, slot_depth_mm + 2*overlap_mm, length_mm + 2*overlap_mm], center=true);
    }
  }
}

// Assembly
module assembly() {
  extrusion();
  extrusion_cross_section();
  translate([cross_section_width_mm/2 - slot_depth_mm/2 + overlap_mm, 0, 0]) box_corner_profile_section();
  translate([0, cross_section_height_mm/2 - slot_depth_mm/2 + overlap_mm, 0]) box_corner_profile_sections();
}

assembly();