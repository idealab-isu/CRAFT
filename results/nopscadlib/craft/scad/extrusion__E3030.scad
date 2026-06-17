// Parameters
cross_section_width_mm = 30; //[15:60:0.5]
cross_section_height_mm = 30; //[15:60:0.5]
length_mm = 100; //[50:200:1]
t_slot_opening_mm = 8.2; //[6:12:0.1]
t_slot_depth_mm = 7.5; //[4:12:0.1]
t_slot_inner_width_mm = 12; //[8:18:0.1]
t_slot_inner_depth_mm = 3.5; //[2:8:0.1]
center_bore_diameter_mm = 5.2; //[3:10:0.1]
corner_hole_diameter_mm = 4.2; //[2.5:8:0.1]
corner_hole_inset_mm = 7.5; //[5:12:0.1]
cut_overlap_mm = 1; //[0.5:2:0.1]

// Extrusion - complete detailed geometry
module extrusion() {
  color("Silver") {
    difference() {
      // Main body
      cube([cross_section_width_mm, cross_section_height_mm, length_mm], center=true);
      
      // Center bore
      translate([0, 0, 0])
        cylinder(r=center_bore_diameter_mm/2, h=length_mm + 2*cut_overlap_mm, center=true);
      
      // T-slot channels
      union() {
        // X-axis slots
        translate([cross_section_width_mm/2 - (t_slot_depth_mm + cut_overlap_mm)/2, 0, 0])
          cube([t_slot_depth_mm + cut_overlap_mm, t_slot_opening_mm, length_mm + 2*cut_overlap_mm], center=true);
        translate([cross_section_width_mm/2 - t_slot_depth_mm - (t_slot_inner_depth_mm + cut_overlap_mm)/2, 0, 0])
          cube([t_slot_inner_depth_mm + cut_overlap_mm, t_slot_inner_width_mm, length_mm + 2*cut_overlap_mm], center=true);
        translate([-cross_section_width_mm/2 + (t_slot_depth_mm + cut_overlap_mm)/2, 0, 0])
          cube([t_slot_depth_mm + cut_overlap_mm, t_slot_opening_mm, length_mm + 2*cut_overlap_mm], center=true);
        translate([-cross_section_width_mm/2 + t_slot_depth_mm + (t_slot_inner_depth_mm + cut_overlap_mm)/2, 0, 0])
          cube([t_slot_inner_depth_mm + cut_overlap_mm, t_slot_inner_width_mm, length_mm + 2*cut_overlap_mm], center=true);
        
        // Y-axis slots
        translate([0, cross_section_height_mm/2 - (t_slot_depth_mm + cut_overlap_mm)/2, 0])
          cube([t_slot_opening_mm, t_slot_depth_mm + cut_overlap_mm, length_mm + 2*cut_overlap_mm], center=true);
        translate([0, cross_section_height_mm/2 - t_slot_depth_mm - (t_slot_inner_depth_mm + cut_overlap_mm)/2, 0])
          cube([t_slot_inner_width_mm, t_slot_inner_depth_mm + cut_overlap_mm, length_mm + 2*cut_overlap_mm], center=true);
        translate([0, -cross_section_height_mm/2 + (t_slot_depth_mm + cut_overlap_mm)/2, 0])
          cube([t_slot_opening_mm, t_slot_depth_mm + cut_overlap_mm, length_mm + 2*cut_overlap_mm], center=true);
        translate([0, -cross_section_height_mm/2 + t_slot_depth_mm + (t_slot_inner_depth_mm + cut_overlap_mm)/2, 0])
          cube([t_slot_inner_width_mm, t_slot_inner_depth_mm + cut_overlap_mm, length_mm + 2*cut_overlap_mm], center=true);
      }
      
      // Corner holes
      union() {
        translate([cross_section_width_mm/2 - corner_hole_inset_mm, cross_section_height_mm/2 - corner_hole_inset_mm, 0])
          cylinder(r=corner_hole_diameter_mm/2, h=length_mm + 2*cut_overlap_mm, center=true);
        translate([-cross_section_width_mm/2 + corner_hole_inset_mm, cross_section_height_mm/2 - corner_hole_inset_mm, 0])
          cylinder(r=corner_hole_diameter_mm/2, h=length_mm + 2*cut_overlap_mm, center=true);
        translate([-cross_section_width_mm/2 + corner_hole_inset_mm, -cross_section_height_mm/2 + corner_hole_inset_mm, 0])
          cylinder(r=corner_hole_diameter_mm/2, h=length_mm + 2*cut_overlap_mm, center=true);
        translate([cross_section_width_mm/2 - corner_hole_inset_mm, -cross_section_height_mm/2 + corner_hole_inset_mm, 0])
          cylinder(r=corner_hole_diameter_mm/2, h=length_mm + 2*cut_overlap_mm, center=true);
      }
    }
  }
}

// Extrusion Cross Section - detailed geometry
module extrusion_cross_section() {
  color("Silver") {
    difference() {
      // Main body
      cube([cross_section_width_mm, cross_section_height_mm, 1], center=true);
      
      // Center bore
      translate([0, 0, 0])
        cylinder(r=center_bore_diameter_mm/2, h=2, center=true);
      
      // T-slot channels
      union() {
        // X-axis slots
        translate([cross_section_width_mm/2 - (t_slot_depth_mm + cut_overlap_mm)/2, 0, 0])
          cube([t_slot_depth_mm + cut_overlap_mm, t_slot_opening_mm, 2], center=true);
        translate([cross_section_width_mm/2 - t_slot_depth_mm - (t_slot_inner_depth_mm + cut_overlap_mm)/2, 0, 0])
          cube([t_slot_inner_depth_mm + cut_overlap_mm, t_slot_inner_width_mm, 2], center=true);
        translate([-cross_section_width_mm/2 + (t_slot_depth_mm + cut_overlap_mm)/2, 0, 0])
          cube([t_slot_depth_mm + cut_overlap_mm, t_slot_opening_mm, 2], center=true);
        translate([-cross_section_width_mm/2 + t_slot_depth_mm + (t_slot_inner_depth_mm + cut_overlap_mm)/2, 0, 0])
          cube([t_slot_inner_depth_mm + cut_overlap_mm, t_slot_inner_width_mm, 2], center=true);
        
        // Y-axis slots
        translate([0, cross_section_height_mm/2 - (t_slot_depth_mm + cut_overlap_mm)/2, 0])
          cube([t_slot_opening_mm, t_slot_depth_mm + cut_overlap_mm, 2], center=true);
        translate([0, cross_section_height_mm/2 - t_slot_depth_mm - (t_slot_inner_depth_mm + cut_overlap_mm)/2, 0])
          cube([t_slot_inner_width_mm, t_slot_inner_depth_mm + cut_overlap_mm, 2], center=true);
        translate([0, -cross_section_height_mm/2 + (t_slot_depth_mm + cut_overlap_mm)/2, 0])
          cube([t_slot_opening_mm, t_slot_depth_mm + cut_overlap_mm, 2], center=true);
        translate([0, -cross_section_height_mm/2 + t_slot_depth_mm + (t_slot_inner_depth_mm + cut_overlap_mm)/2, 0])
          cube([t_slot_inner_width_mm, t_slot_inner_depth_mm + cut_overlap_mm, 2], center=true);
      }
      
      // Corner holes
      union() {
        translate([cross_section_width_mm/2 - corner_hole_inset_mm, cross_section_height_mm/2 - corner_hole_inset_mm, 0])
          cylinder(r=corner_hole_diameter_mm/2, h=2, center=true);
        translate([-cross_section_width_mm/2 + corner_hole_inset_mm, cross_section_height_mm/2 - corner_hole_inset_mm, 0])
          cylinder(r=corner_hole_diameter_mm/2, h=2, center=true);
        translate([-cross_section_width_mm/2 + corner_hole_inset_mm, -cross_section_height_mm/2 + corner_hole_inset_mm, 0])
          cylinder(r=corner_hole_diameter_mm/2, h=2, center=true);
        translate([cross_section_width_mm/2 - corner_hole_inset_mm, -cross_section_height_mm/2 + corner_hole_inset_mm, 0])
          cylinder(r=corner_hole_diameter_mm/2, h=2, center=true);
      }
    }
  }
}

// Box Corner Profile Section - detailed geometry
module box_corner_profile_section() {
  color("Silver") {
    difference() {
      // Main body
      cube([cross_section_width_mm, cross_section_height_mm, 1], center=true);
      
      // Corner holes
      union() {
        translate([cross_section_width_mm/2 - corner_hole_inset_mm, cross_section_height_mm/2 - corner_hole_inset_mm, 0])
          cylinder(r=corner_hole_diameter_mm/2, h=2, center=true);
        translate([-cross_section_width_mm/2 + corner_hole_inset_mm, cross_section_height_mm/2 - corner_hole_inset_mm, 0])
          cylinder(r=corner_hole_diameter_mm/2, h=2, center=true);
        translate([-cross_section_width_mm/2 + corner_hole_inset_mm, -cross_section_height_mm/2 + corner_hole_inset_mm, 0])
          cylinder(r=corner_hole_diameter_mm/2, h=2, center=true);
        translate([cross_section_width_mm/2 - corner_hole_inset_mm, -cross_section_height_mm/2 + corner_hole_inset_mm, 0])
          cylinder(r=corner_hole_diameter_mm/2, h=2, center=true);
      }
    }
  }
}

// Box Corner Profile Sections - detailed geometry
module box_corner_profile_sections() {
  color("Silver") {
    difference() {
      // Main body
      cube([cross_section_width_mm, cross_section_height_mm, 1], center=true);
      
      // Corner holes
      union() {
        translate([cross_section_width_mm/2 - corner_hole_inset_mm, cross_section_height_mm/2 - corner_hole_inset_mm, 0])
          cylinder(r=corner_hole_diameter_mm/2, h=2, center=true);
        translate([-cross_section_width_mm/2 + corner_hole_inset_mm, cross_section_height_mm/2 - corner_hole_inset_mm, 0])
          cylinder(r=corner_hole_diameter_mm/2, h=2, center=true);
        translate([-cross_section_width_mm/2 + corner_hole_inset_mm, -cross_section_height_mm/2 + corner_hole_inset_mm, 0])
          cylinder(r=corner_hole_diameter_mm/2, h=2, center=true);
        translate([cross_section_width_mm/2 - corner_hole_inset_mm, -cross_section_height_mm/2 + corner_hole_inset_mm, 0])
          cylinder(r=corner_hole_diameter_mm/2, h=2, center=true);
      }
    }
  }
}

// Assembly
module assembly() {
  extrusion();
  translate([0, 0, length_mm/2 + 1]) extrusion_cross_section();
  translate([0, 0, -length_mm/2 - 1]) box_corner_profile_section();
  translate([0, 0, -length_mm/2 - 2]) box_corner_profile_sections();
}

assembly();