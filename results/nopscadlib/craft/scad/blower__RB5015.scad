// Parameters
length_mm = 51.3; //[25.65:102.6:0.1]
width_mm = 51.0; //[25.5:102.0:0.1]
depth_mm = 15.0; //[7.5:30.0:0.1]
wall_thickness_mm = 1.5; //[0.8:3.0:0.1]
top_thickness_mm = 1.0; //[0.5:2.0:0.1]
base_thickness_mm = 1.0; //[0.5:2.0:0.1]
inlet_bore_diameter_mm = 24.0; //[12.0:48.0:0.1]
outlet_width_mm = 18.0; //[9.0:36.0:0.1]
outlet_height_mm = 8.0; //[4.0:16.0:0.1]
outlet_offset_mm = 0.0; //[-10.0:10.0:0.1]
impeller_outer_diameter_mm = 46.0; //[23.0:92.0:0.1]
impeller_hub_diameter_mm = 16.0; //[8.0:32.0:0.1]
impeller_hub_height_mm = 10.0; //[5.0:20.0:0.1]
blade_count = 25; //[10:60:1]
blade_thickness_mm = 0.75; //[0.4:1.5:0.05]
mount_hole_diameter_mm = 3.2; //[2.0:6.0:0.1]
mount_hole_edge_margin_mm = 4.0; //[2.0:8.0:0.1]
eps_mm = 0.8; //[0.2:2.0:0.1]
axis_x_mm = 22.0; //[12.0:30.0:0.1]
axis_y_mm = 25.5; //[18.0:33.0:0.1]
casing_outer_radius_mm = 23.5; //[15.0:30.0:0.1]
casing_inner_radius_mm = 20.0; //[10.0:28.0:0.1]
lug_diameter_mm = 9.0; //[6.0:14.0:0.1]
lug_height_mm = 3.0; //[1.5:6.0:0.1]

// Blower Module
module blower() {
  color("Silver") {
    // Base Plate
    translate([0, 0, -depth_mm/2 + base_thickness_mm/2])
      cube([length_mm, width_mm, base_thickness_mm], center=true);
    
    // Top Cover Plate
    translate([0, 0, depth_mm/2 - top_thickness_mm/2])
      cube([length_mm, width_mm, top_thickness_mm], center=true);
    
    // Blower Casing Volute
    difference() {
      union() {
        translate([-length_mm/2 + axis_x_mm, -width_mm/2 + axis_y_mm, 0])
          cylinder(r=casing_outer_radius_mm, h=depth_mm - top_thickness_mm - base_thickness_mm, center=true);
        translate([(-length_mm/2 + axis_x_mm) + casing_outer_radius_mm + (length_mm/2 - (axis_x_mm - casing_outer_radius_mm) + outlet_height_mm)/2 - eps_mm, outlet_offset_mm, 0])
          cube([length_mm/2 - (axis_x_mm - casing_outer_radius_mm) + outlet_height_mm, outlet_width_mm, outlet_height_mm], center=true);
      }
      translate([-length_mm/2 + axis_x_mm, -width_mm/2 + axis_y_mm, 0])
        cylinder(r=casing_inner_radius_mm, h=depth_mm - top_thickness_mm - base_thickness_mm + 2*eps_mm, center=true);
      translate([(-length_mm/2 + axis_x_mm) + casing_inner_radius_mm + (length_mm/2 - (axis_x_mm - casing_inner_radius_mm) + outlet_height_mm)/2 - eps_mm, outlet_offset_mm, 0])
        cube([length_mm/2 - (axis_x_mm - casing_inner_radius_mm) + outlet_height_mm, outlet_width_mm - 2*wall_thickness_mm, outlet_height_mm - 2*wall_thickness_mm], center=true);
    }
    
    // Inlet Bore Opening
    translate([-length_mm/2 + axis_x_mm, -width_mm/2 + axis_y_mm, depth_mm/2 - top_thickness_mm/2])
      cylinder(r=inlet_bore_diameter_mm/2, h=top_thickness_mm + 2*eps_mm, center=true);
    
    // Motor Hub
    translate([-length_mm/2 + axis_x_mm, -width_mm/2 + axis_y_mm, -depth_mm/2 + base_thickness_mm + impeller_hub_height_mm/2 - eps_mm])
      cylinder(r=impeller_hub_diameter_mm/2, h=impeller_hub_height_mm, center=true);
    
    // Mounting Lugs
    translate([-length_mm/2 + mount_hole_edge_margin_mm, 0, -depth_mm/2 + base_thickness_mm/2 - lug_height_mm/2 + eps_mm])
      cylinder(r=lug_diameter_mm/2, h=lug_height_mm, center=true);
    translate([length_mm/2 - mount_hole_edge_margin_mm, 0, -depth_mm/2 + base_thickness_mm/2 - lug_height_mm/2 + eps_mm])
      cylinder(r=lug_diameter_mm/2, h=lug_height_mm, center=true);
    
    // Mounting Screw Holes
    translate([-length_mm/2 + mount_hole_edge_margin_mm, 0, -depth_mm/2 + base_thickness_mm/2 - lug_height_mm/2 + eps_mm])
      cylinder(r=mount_hole_diameter_mm/2, h=base_thickness_mm + lug_height_mm + 2*eps_mm, center=true);
    translate([length_mm/2 - mount_hole_edge_margin_mm, 0, -depth_mm/2 + base_thickness_mm/2 - lug_height_mm/2 + eps_mm])
      cylinder(r=mount_hole_diameter_mm/2, h=base_thickness_mm + lug_height_mm + 2*eps_mm, center=true);
  }
}

// Fan Module
module fan() {
  color([0.15, 0.15, 0.17]) {
    // Frame
    difference() {
      cube([length_mm, length_mm, 10], center=true);
      cylinder(d=length_mm-4, h=12, center=true, $fn=32);
    }
    // Hub
    cylinder(d=impeller_hub_diameter_mm, h=8, center=true, $fn=24);
    // Blades
    for(i=[0:6]) rotate([0, 0, i*360/7])
      hull() {
        translate([impeller_hub_diameter_mm/2 + 2, 0, 0]) cylinder(r=2, h=6, $fn=8);
        translate([impeller_outer_diameter_mm/2 - 3, 3, 0]) rotate([0, 10, 15]) cylinder(r=2.5, h=5, $fn=8);
      }
  }
}

// Blower Fan Module
module blower_fan() {
  blower();
  translate([0, 0, depth_mm/2 + 5]) fan();
}

// Assembly Module
module assembly() {
  blower_fan();
}

assembly();