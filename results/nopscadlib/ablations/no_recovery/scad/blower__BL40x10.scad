// Parameters
overall_width_mm = 40; //[20:80:0.5]
overall_length_mm = 40; //[20:80:0.5]
overall_depth_mm = 9.5; //[5:20:0.1]
wall_thickness_mm = 1.2; //[0.8:2.4:0.1]
top_plate_thickness_mm = 1.0; //[0.6:2.0:0.1]
base_plate_thickness_mm = 1.0; //[0.6:2.0:0.1]
clearance_overlap_mm = 0.8; //[0.5:2.0:0.1]
inlet_bore_d_mm = 18; //[10:28:0.5]
inlet_lip_height_mm = 1.2; //[0.6:3.0:0.1]
outlet_width_mm = 12; //[8:20:0.5]
outlet_height_mm = 6; //[4:9:0.5]
outlet_length_mm = 10; //[6:25:0.5]
impeller_outer_d_mm = 26; //[18:34:0.5]
impeller_hub_d_mm = 10; //[6:16:0.5]
impeller_height_mm = 6.5; //[4:8.5:0.1]
blade_count = 25; //[12:40:1]
blade_ring_thickness_mm = 1.2; //[0.8:2.5:0.1]
mount_hole_d_mm = 3.2; //[2.5:4.5:0.1]
mount_hole_edge_offset_mm = 4.0; //[2.5:8.0:0.5]
mount_hole_y_pitch_mm = 24; //[16:32:0.5]
volute_outer_r_mm = 17; //[12:22:0.5]
volute_inner_r_mm = 10; //[7:16:0.5]
volute_center_x_offset_mm = 2.0; //[0:6:0.5]

// Blower - complete geometry
module blower() {
  color([0.15, 0.15, 0.17]) {
    difference() {
      union() {
        // Blower outer block
        translate([0, 0, 0])
          cube([overall_width_mm, overall_length_mm, overall_depth_mm], center=true);
        // Outlet outer duct
        translate([(overall_width_mm/2 + outlet_length_mm/2 - clearance_overlap_mm),
                   (overall_length_mm/2 - outlet_width_mm/2 - wall_thickness_mm),
                   (overall_depth_mm/2 - top_plate_thickness_mm - outlet_height_mm/2)])
          cube([outlet_length_mm, outlet_width_mm, outlet_height_mm], center=true);
        // Inlet lip cylinder
        translate([volute_center_x_offset_mm, 0,
                   (overall_depth_mm/2 + inlet_lip_height_mm/2 - clearance_overlap_mm)])
          cylinder(r=(inlet_bore_d_mm/2 + wall_thickness_mm), h=inlet_lip_height_mm, center=true);
      }
      // Internal cavity
      hull() {
        translate([volute_center_x_offset_mm, 0, (base_plate_thickness_mm - top_plate_thickness_mm)/2])
          cylinder(r=volute_outer_r_mm, h=(overall_depth_mm - top_plate_thickness_mm - base_plate_thickness_mm), center=true);
        translate([volute_center_x_offset_mm, 0, (base_plate_thickness_mm - top_plate_thickness_mm)/2])
          cylinder(r=volute_inner_r_mm, h=(overall_depth_mm - top_plate_thickness_mm - base_plate_thickness_mm + 2*clearance_overlap_mm), center=true);
      }
      // Inlet bore cut
      translate([volute_center_x_offset_mm, 0, (overall_depth_mm/2 - top_plate_thickness_mm/2)])
        cylinder(r=inlet_bore_d_mm/2, h=(top_plate_thickness_mm + inlet_lip_height_mm + 2*clearance_overlap_mm), center=true);
      // Outlet inner cut
      translate([(overall_width_mm/2 + outlet_length_mm/2 - clearance_overlap_mm),
                 (overall_length_mm/2 - outlet_width_mm/2 - wall_thickness_mm),
                 (overall_depth_mm/2 - top_plate_thickness_mm - outlet_height_mm/2)])
        cube([(outlet_length_mm + 2*clearance_overlap_mm),
              (outlet_width_mm - 2*wall_thickness_mm),
              (outlet_height_mm - 2*wall_thickness_mm)], center=true);
      // Mount holes
      translate([(overall_width_mm/2 - mount_hole_edge_offset_mm), (mount_hole_y_pitch_mm/2), 0])
        cylinder(r=mount_hole_d_mm/2, h=(overall_depth_mm + 2*clearance_overlap_mm), center=true);
      translate([(overall_width_mm/2 - mount_hole_edge_offset_mm), (-mount_hole_y_pitch_mm/2), 0])
        cylinder(r=mount_hole_d_mm/2, h=(overall_depth_mm + 2*clearance_overlap_mm), center=true);
    }
  }
}

// Fan - complete geometry
module fan() {
  color([0.2, 0.2, 0.22]) {
    // Frame
    difference() {
      cube([overall_width_mm, overall_length_mm, 10], center=true);
      cylinder(d=overall_width_mm-4, h=12, center=true, $fn=32);
    }
    // Hub
    cylinder(d=impeller_hub_d_mm, h=8, center=true, $fn=24);
    // Blades - 7 curved blades
    for(i=[0:6]) rotate([0,0,i*360/7])
      hull() {
        translate([impeller_hub_d_mm/2+2,0,-3]) cylinder(r=2, h=6, $fn=8);
        translate([impeller_outer_d_mm/2-3,3,0]) rotate([0,12,20]) cylinder(r=2.5, h=5, $fn=8);
      }
  }
}

// Blower Fan - complete geometry
module blower_fan() {
  color([0.2, 0.2, 0.22]) {
    // Frame
    difference() {
      cube([overall_width_mm, overall_length_mm, 10], center=true);
      cylinder(d=overall_width_mm-4, h=12, center=true, $fn=32);
    }
    // Hub
    cylinder(d=impeller_hub_d_mm, h=8, center=true, $fn=24);
    // Blades - 7 curved blades
    for(i=[0:6]) rotate([0,0,i*360/7])
      hull() {
        translate([impeller_hub_d_mm/2+2,0,-3]) cylinder(r=2, h=6, $fn=8);
        translate([impeller_outer_d_mm/2-3,3,0]) rotate([0,12,20]) cylinder(r=2.5, h=5, $fn=8);
      }
  }
}

// Assembly
module assembly() {
  blower();
  translate([0, 0, overall_depth_mm/2 + 5]) fan();
  translate([0, 0, overall_depth_mm/2 + 15]) blower_fan();
}

assembly();