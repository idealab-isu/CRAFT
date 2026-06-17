// Parameters
cross_section_width_mm = 40; //[20:80:1]
cross_section_height_mm = 40; //[20:80:1]
length_mm = 100; //[50:200:1]
center = 1; //[0:1:1]
cornerHole = 1; //[0:1:1]
outer_corner_radius_mm = 1.5; //[0.5:3:0.1]
t_slot_opening_mm = 8.2; //[6:12:0.1]
t_slot_depth_mm = 10; //[6:16:0.5]
t_slot_neck_mm = 3.2; //[2:6:0.1]
t_slot_inner_width_mm = 12; //[8:18:0.5]
t_slot_inner_depth_mm = 6; //[3:10:0.5]
center_bore_diameter_mm = 8.2; //[4:16:0.1]
corner_hole_diameter_mm = 4.2; //[2:8:0.1]
corner_hole_inset_mm = 10; //[6:16:0.5]
cut_overlap_mm = 1; //[0.5:2:0.1]

// Extrusion Profile Body
module extrusion_profile_body() {
  color("Silver") {
    cube([cross_section_width_mm, cross_section_height_mm, length_mm], center=true);
  }
}

// Center Bore
module center_bore() {
  color("Black") {
    cylinder(h=length_mm + 2*cut_overlap_mm, r=center_bore_diameter_mm/2, center=true);
  }
}

// T-Slot Channels
module t_slot_channels() {
  color("DimGray") {
    union() {
      translate([cross_section_width_mm/2 - (t_slot_depth_mm + cut_overlap_mm)/2, 0, 0])
        cube([t_slot_depth_mm + cut_overlap_mm, t_slot_neck_mm, length_mm + 2*cut_overlap_mm], center=true);
      translate([cross_section_width_mm/2 - t_slot_depth_mm + (t_slot_inner_depth_mm + cut_overlap_mm)/2, 0, 0])
        cube([t_slot_inner_depth_mm + cut_overlap_mm, t_slot_inner_width_mm, length_mm + 2*cut_overlap_mm], center=true);
      translate([-cross_section_width_mm/2 + (t_slot_depth_mm + cut_overlap_mm)/2, 0, 0])
        cube([t_slot_depth_mm + cut_overlap_mm, t_slot_neck_mm, length_mm + 2*cut_overlap_mm], center=true);
      translate([-cross_section_width_mm/2 + t_slot_depth_mm - (t_slot_inner_depth_mm + cut_overlap_mm)/2, 0, 0])
        cube([t_slot_inner_depth_mm + cut_overlap_mm, t_slot_inner_width_mm, length_mm + 2*cut_overlap_mm], center=true);
      translate([0, cross_section_height_mm/2 - (t_slot_depth_mm + cut_overlap_mm)/2, 0])
        cube([t_slot_neck_mm, t_slot_depth_mm + cut_overlap_mm, length_mm + 2*cut_overlap_mm], center=true);
      translate([0, cross_section_height_mm/2 - t_slot_depth_mm + (t_slot_inner_depth_mm + cut_overlap_mm)/2, 0])
        cube([t_slot_inner_width_mm, t_slot_inner_depth_mm + cut_overlap_mm, length_mm + 2*cut_overlap_mm], center=true);
      translate([0, -cross_section_height_mm/2 + (t_slot_depth_mm + cut_overlap_mm)/2, 0])
        cube([t_slot_neck_mm, t_slot_depth_mm + cut_overlap_mm, length_mm + 2*cut_overlap_mm], center=true);
      translate([0, -cross_section_height_mm/2 + t_slot_depth_mm - (t_slot_inner_depth_mm + cut_overlap_mm)/2, 0])
        cube([t_slot_inner_width_mm, t_slot_inner_depth_mm + cut_overlap_mm, length_mm + 2*cut_overlap_mm], center=true);
    }
  }
}

// Corner Holes
module corner_holes() {
  color("Black") {
    union() {
      translate([cross_section_width_mm/2 - corner_hole_inset_mm, cross_section_height_mm/2 - corner_hole_inset_mm, 0])
        cylinder(h=length_mm + 2*cut_overlap_mm, r=corner_hole_diameter_mm/2, center=true);
      translate([-cross_section_width_mm/2 + corner_hole_inset_mm, cross_section_height_mm/2 - corner_hole_inset_mm, 0])
        cylinder(h=length_mm + 2*cut_overlap_mm, r=corner_hole_diameter_mm/2, center=true);
      translate([cross_section_width_mm/2 - corner_hole_inset_mm, -cross_section_height_mm/2 + corner_hole_inset_mm, 0])
        cylinder(h=length_mm + 2*cut_overlap_mm, r=corner_hole_diameter_mm/2, center=true);
      translate([-cross_section_width_mm/2 + corner_hole_inset_mm, -cross_section_height_mm/2 + corner_hole_inset_mm, 0])
        cylinder(h=length_mm + 2*cut_overlap_mm, r=corner_hole_diameter_mm/2, center=true);
    }
  }
}

// Extrusion Cross Section
module extrusion_cross_section() {
  difference() {
    extrusion_profile_body();
    center_bore();
    t_slot_channels();
    corner_holes();
  }
}

// Box Corner Profile Section
module box_corner_profile_section() {
  color("Silver") {
    cube([cross_section_width_mm/2, cross_section_height_mm/2, length_mm], center=true);
  }
}

// Box Corner Profile Sections
module box_corner_profile_sections() {
  union() {
    box_corner_profile_section();
    extrusion_cross_section();
  }
}

// Final Assembly
module assembly() {
  extrusion_cross_section();
  box_corner_profile_sections();
}

assembly();