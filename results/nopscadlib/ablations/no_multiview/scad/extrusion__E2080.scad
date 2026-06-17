// Parameters
cross_section_width_mm = 20; //[10:40:1]
cross_section_height_mm = 80; //[40:160:1]
length_mm = 100; //[50:200:1]
outer_fillet_r_mm = 1.5; //[0.5:3:0.1]
wall_thickness_mm = 2.0; //[1.2:4.0:0.1]
slot_opening_mm = 6.2; //[4.5:8.0:0.1]
slot_depth_mm = 6.0; //[4.0:9.0:0.1]
slot_cavity_width_mm = 11.0; //[8.0:14.0:0.1]
slot_cavity_depth_mm = 10.0; //[7.0:14.0:0.1]
center_bore_d_mm = 5.2; //[3.0:8.0:0.1]
corner_hole_d_mm = 4.2; //[2.5:6.0:0.1]
corner_hole_inset_mm = 6.0; //[4.0:9.0:0.1]
internal_channel_w_mm = 8.0; //[5.0:12.0:0.1]
internal_channel_h_mm = 8.0; //[5.0:12.0:0.1]
internal_channel_offset_y_mm = 20.0; //[10.0:30.0:0.5]

// Extrusion - complete geometry
module extrusion() {
  color([0.75, 0.75, 0.77]) {
    difference() {
      linear_extrude(height=length_mm, center=true) {
        polygon(points=[
          [-cross_section_width_mm/2 + outer_fillet_r_mm, -cross_section_height_mm/2],
          [cross_section_width_mm/2 - outer_fillet_r_mm, -cross_section_height_mm/2],
          [cross_section_width_mm/2, -cross_section_height_mm/2 + outer_fillet_r_mm],
          [cross_section_width_mm/2, cross_section_height_mm/2 - outer_fillet_r_mm],
          [cross_section_width_mm/2 - outer_fillet_r_mm, cross_section_height_mm/2],
          [-cross_section_width_mm/2 + outer_fillet_r_mm, cross_section_height_mm/2],
          [-cross_section_width_mm/2, cross_section_height_mm/2 - outer_fillet_r_mm],
          [-cross_section_width_mm/2, -cross_section_height_mm/2 + outer_fillet_r_mm]
        ]);
      }
      union() {
        // T-slot channels
        translate([0, cross_section_height_mm/2 - slot_depth_mm/2, 0])
          cube([slot_opening_mm, slot_depth_mm, length_mm], center=true);
        translate([0, cross_section_height_mm/2 - slot_depth_mm - slot_cavity_depth_mm/2, 0])
          cube([slot_cavity_width_mm, slot_cavity_depth_mm, length_mm], center=true);
        translate([0, -cross_section_height_mm/2 + slot_depth_mm/2, 0])
          cube([slot_opening_mm, slot_depth_mm, length_mm], center=true);
        translate([0, -cross_section_height_mm/2 + slot_depth_mm + slot_cavity_depth_mm/2, 0])
          cube([slot_cavity_width_mm, slot_cavity_depth_mm, length_mm], center=true);
        translate([-cross_section_width_mm/2 + slot_depth_mm/2, 0, 0])
          cube([slot_depth_mm, slot_opening_mm, length_mm], center=true);
        translate([-cross_section_width_mm/2 + slot_depth_mm + slot_cavity_depth_mm/2, 0, 0])
          cube([slot_cavity_depth_mm, slot_cavity_width_mm, length_mm], center=true);
        translate([cross_section_width_mm/2 - slot_depth_mm/2, 0, 0])
          cube([slot_depth_mm, slot_opening_mm, length_mm], center=true);
        translate([cross_section_width_mm/2 - slot_depth_mm - slot_cavity_depth_mm/2, 0, 0])
          cube([slot_cavity_depth_mm, slot_cavity_width_mm, length_mm], center=true);
      }
      // Internal voids
      union() {
        cube([cross_section_width_mm - 2*wall_thickness_mm, cross_section_height_mm - 2*wall_thickness_mm, length_mm], center=true);
        translate([0, internal_channel_offset_y_mm, 0])
          cube([internal_channel_w_mm, internal_channel_h_mm, length_mm], center=true);
        translate([0, -internal_channel_offset_y_mm, 0])
          cube([internal_channel_w_mm, internal_channel_h_mm, length_mm], center=true);
        cylinder(r=center_bore_d_mm/2, h=length_mm, center=true);
      }
      // Corner holes
      if (cornerHole) {
        union() {
          translate([-cross_section_width_mm/2 + corner_hole_inset_mm, cross_section_height_mm/2 - corner_hole_inset_mm, 0])
            cylinder(r=corner_hole_d_mm/2, h=length_mm, center=true);
          translate([cross_section_width_mm/2 - corner_hole_inset_mm, cross_section_height_mm/2 - corner_hole_inset_mm, 0])
            cylinder(r=corner_hole_d_mm/2, h=length_mm, center=true);
          translate([-cross_section_width_mm/2 + corner_hole_inset_mm, -cross_section_height_mm/2 + corner_hole_inset_mm, 0])
            cylinder(r=corner_hole_d_mm/2, h=length_mm, center=true);
          translate([cross_section_width_mm/2 - corner_hole_inset_mm, -cross_section_height_mm/2 + corner_hole_inset_mm, 0])
            cylinder(r=corner_hole_d_mm/2, h=length_mm, center=true);
        }
      }
    }
  }
}

// Extrusion Cross Section - complete geometry
module extrusion_cross_section() {
  color([0.85, 0.85, 0.8]) {
    difference() {
      linear_extrude(height=length_mm, center=true) {
        polygon(points=[
          [-cross_section_width_mm/2 + outer_fillet_r_mm, -cross_section_height_mm/2],
          [cross_section_width_mm/2 - outer_fillet_r_mm, -cross_section_height_mm/2],
          [cross_section_width_mm/2, -cross_section_height_mm/2 + outer_fillet_r_mm],
          [cross_section_width_mm/2, cross_section_height_mm/2 - outer_fillet_r_mm],
          [cross_section_width_mm/2 - outer_fillet_r_mm, cross_section_height_mm/2],
          [-cross_section_width_mm/2 + outer_fillet_r_mm, cross_section_height_mm/2],
          [-cross_section_width_mm/2, cross_section_height_mm/2 - outer_fillet_r_mm],
          [-cross_section_width_mm/2, -cross_section_height_mm/2 + outer_fillet_r_mm]
        ]);
      }
      // Internal voids
      union() {
        cube([cross_section_width_mm - 2*wall_thickness_mm, cross_section_height_mm - 2*wall_thickness_mm, length_mm], center=true);
        translate([0, internal_channel_offset_y_mm, 0])
          cube([internal_channel_w_mm, internal_channel_h_mm, length_mm], center=true);
        translate([0, -internal_channel_offset_y_mm, 0])
          cube([internal_channel_w_mm, internal_channel_h_mm, length_mm], center=true);
        cylinder(r=center_bore_d_mm/2, h=length_mm, center=true);
      }
      // Corner holes
      if (cornerHole) {
        union() {
          translate([-cross_section_width_mm/2 + corner_hole_inset_mm, cross_section_height_mm/2 - corner_hole_inset_mm, 0])
            cylinder(r=corner_hole_d_mm/2, h=length_mm, center=true);
          translate([cross_section_width_mm/2 - corner_hole_inset_mm, cross_section_height_mm/2 - corner_hole_inset_mm, 0])
            cylinder(r=corner_hole_d_mm/2, h=length_mm, center=true);
          translate([-cross_section_width_mm/2 + corner_hole_inset_mm, -cross_section_height_mm/2 + corner_hole_inset_mm, 0])
            cylinder(r=corner_hole_d_mm/2, h=length_mm, center=true);
          translate([cross_section_width_mm/2 - corner_hole_inset_mm, -cross_section_height_mm/2 + corner_hole_inset_mm, 0])
            cylinder(r=corner_hole_d_mm/2, h=length_mm, center=true);
        }
      }
    }
  }
}

// Box Corner Profile Section - complete geometry
module box_corner_profile_section() {
  color([0.4, 0.4, 0.43]) {
    cube([cross_section_width_mm/2, cross_section_width_mm/2, length_mm], center=true);
  }
}

// Box Corner Profile Sections - complete geometry
module box_corner_profile_sections() {
  color([0.4, 0.4, 0.43]) {
    cube([cross_section_width_mm/2, cross_section_width_mm/2, length_mm], center=true);
  }
}

// Assembly
module assembly() {
  extrusion();
  translate([cross_section_width_mm/2 - (cross_section_width_mm/2)/2, cross_section_height_mm/2 - (cross_section_width_mm/2)/2, 0])
    box_corner_profile_sections();
  translate([-cross_section_width_mm/2 + (cross_section_width_mm/2)/2, -cross_section_height_mm/2 + (cross_section_width_mm/2)/2, 0])
    box_corner_profile_section();
}

assembly();