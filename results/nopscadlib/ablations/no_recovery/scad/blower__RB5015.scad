// Parameters
overall_length_mm = 51.3; //[25.65:102.6:0.1]
overall_width_mm = 51; //[25.5:102:0.1]
overall_depth_mm = 15; //[7.5:30:0.1]
wall_thickness_mm = 1.6; //[0.8:3.2:0.1]
base_plate_thickness_mm = 1.8; //[0.9:3.6:0.1]
top_cover_thickness_mm = 1.4; //[0.7:2.8:0.1]
clearance_mm = 0.6; //[0.2:1.5:0.1]
overlap_mm = 1; //[0.5:2:0.1]
axis_offset_x_mm = 20.5; //[10.25:41:0.1]
axis_offset_y_mm = 25.5; //[12.75:51:0.1]
inlet_bore_diameter_mm = 22; //[11:44:0.1]
impeller_outer_diameter_mm = 38; //[19:48:0.1]
impeller_height_mm = 9.5; //[5:13:0.1]
hub_diameter_mm = 10; //[5:20:0.1]
hub_post_diameter_mm = 6; //[3:12:0.1]
hub_post_height_mm = 4.5; //[2:9:0.1]
blade_count = 21; //[9:35:1]
blade_thickness_mm = 1; //[0.6:2:0.1]
blade_radial_length_mm = 7.5; //[4:12:0.1]
outlet_height_mm = 9; //[5:13:0.1]
outlet_width_mm = 12; //[6:20:0.1]
outlet_length_mm = 14; //[7:28:0.1]
lug_diameter_mm = 8.5; //[5:14:0.1]
screw_hole_diameter_mm = 3.2; //[2:5:0.1]
lug_thickness_mm = 2.2; //[1.2:4.4:0.1]

// Blower module
module blower() {
  color("DimGray") {
    // Base plate
    translate([0, 0, -overall_depth_mm/2 + base_plate_thickness_mm/2])
      cube([overall_length_mm, overall_width_mm, base_plate_thickness_mm], center=true);

    // Top cover plate
    translate([0, 0, overall_depth_mm/2 - top_cover_thickness_mm/2])
      cube([overall_length_mm, overall_width_mm, top_cover_thickness_mm], center=true);

    // Outer casing
    difference() {
      cube([overall_length_mm, overall_width_mm, overall_depth_mm - base_plate_thickness_mm - top_cover_thickness_mm + 2*overlap_mm], center=true);
      translate([0, 0, 0])
        cube([overall_length_mm - 2*wall_thickness_mm, overall_width_mm - 2*wall_thickness_mm, overall_depth_mm - base_plate_thickness_mm - top_cover_thickness_mm + 4*overlap_mm], center=true);
    }

    // Inlet bore
    translate([-overall_length_mm/2 + axis_offset_x_mm, -overall_width_mm/2 + axis_offset_y_mm, overall_depth_mm/2 - top_cover_thickness_mm/2])
      cylinder(r=inlet_bore_diameter_mm/2, h=top_cover_thickness_mm + 2*overlap_mm, center=true);

    // Outlet duct
    difference() {
      translate([overall_length_mm/2 + outlet_length_mm/2 - overlap_mm, -overall_width_mm/2 + axis_offset_y_mm, -overall_depth_mm/2 + base_plate_thickness_mm + (overall_depth_mm - base_plate_thickness_mm - top_cover_thickness_mm)/2])
        cube([outlet_length_mm, outlet_width_mm + 2*wall_thickness_mm, outlet_height_mm + 2*wall_thickness_mm], center=true);
      translate([overall_length_mm/2 + outlet_length_mm/2 - overlap_mm, -overall_width_mm/2 + axis_offset_y_mm, -overall_depth_mm/2 + base_plate_thickness_mm + (overall_depth_mm - base_plate_thickness_mm - top_cover_thickness_mm)/2])
        cube([outlet_length_mm + 2*overlap_mm, outlet_width_mm, outlet_height_mm], center=true);
    }

    // Hub post
    translate([-overall_length_mm/2 + axis_offset_x_mm, -overall_width_mm/2 + axis_offset_y_mm, -overall_depth_mm/2 + base_plate_thickness_mm + (hub_post_height_mm + overlap_mm)/2 - overlap_mm/2])
      cylinder(r=hub_post_diameter_mm/2, h=hub_post_height_mm + overlap_mm, center=true);

    // Hub
    translate([-overall_length_mm/2 + axis_offset_x_mm, -overall_width_mm/2 + axis_offset_y_mm, -overall_depth_mm/2 + base_plate_thickness_mm + hub_post_height_mm + impeller_height_mm/2 - overlap_mm])
      cylinder(r=hub_diameter_mm/2, h=impeller_height_mm, center=true);

    // Blades
    for (i = [0:blade_count-1]) {
      rotate([0, 0, i*360/blade_count])
        translate([-overall_length_mm/2 + axis_offset_x_mm + hub_diameter_mm/2 + blade_radial_length_mm/2 - overlap_mm, -overall_width_mm/2 + axis_offset_y_mm, -overall_depth_mm/2 + base_plate_thickness_mm + hub_post_height_mm + impeller_height_mm/2 - overlap_mm])
          cube([blade_radial_length_mm, blade_thickness_mm, impeller_height_mm], center=true);
    }

    // Mounting screw lugs
    translate([-overall_length_mm/2 + lug_diameter_mm/2, -overall_width_mm/2 + lug_diameter_mm/2, -overall_depth_mm/2 + lug_thickness_mm/2 - overlap_mm/2])
      cylinder(r=lug_diameter_mm/2, h=lug_thickness_mm, center=true);
    translate([overall_length_mm/2 - lug_diameter_mm/2, -overall_width_mm/2 + lug_diameter_mm/2, -overall_depth_mm/2 + lug_thickness_mm/2 - overlap_mm/2])
      cylinder(r=lug_diameter_mm/2, h=lug_thickness_mm, center=true);
    translate([-overall_length_mm/2 + lug_diameter_mm/2, overall_width_mm/2 - lug_diameter_mm/2, -overall_depth_mm/2 + lug_thickness_mm/2 - overlap_mm/2])
      cylinder(r=lug_diameter_mm/2, h=lug_thickness_mm, center=true);
    translate([overall_length_mm/2 - lug_diameter_mm/2, overall_width_mm/2 - lug_diameter_mm/2, -overall_depth_mm/2 + lug_thickness_mm/2 - overlap_mm/2])
      cylinder(r=lug_diameter_mm/2, h=lug_thickness_mm, center=true);

    // Mounting screw holes
    translate([-overall_length_mm/2 + lug_diameter_mm/2, -overall_width_mm/2 + lug_diameter_mm/2, 0])
      cylinder(r=screw_hole_diameter_mm/2, h=overall_depth_mm + 2*overlap_mm, center=true);
    translate([overall_length_mm/2 - lug_diameter_mm/2, -overall_width_mm/2 + lug_diameter_mm/2, 0])
      cylinder(r=screw_hole_diameter_mm/2, h=overall_depth_mm + 2*overlap_mm, center=true);
    translate([-overall_length_mm/2 + lug_diameter_mm/2, overall_width_mm/2 - lug_diameter_mm/2, 0])
      cylinder(r=screw_hole_diameter_mm/2, h=overall_depth_mm + 2*overlap_mm, center=true);
    translate([overall_length_mm/2 - lug_diameter_mm/2, overall_width_mm/2 - lug_diameter_mm/2, 0])
      cylinder(r=screw_hole_diameter_mm/2, h=overall_depth_mm + 2*overlap_mm, center=true);
  }
}

// Fan module
module fan() {
  color([0.15, 0.15, 0.17]) {
    // Frame
    difference() {
      cube([40, 40, 10], center=true);
      cylinder(d=36, h=12, center=true, $fn=32);
    }
    // Hub
    cylinder(d=16, h=8, center=true, $fn=24);
    // Blades
    for (i = [0:6]) {
      rotate([0, 0, i*360/7])
        hull() {
          translate([8, 0, -3]) cylinder(r=2, h=6, $fn=8);
          translate([16, 4, 0]) rotate([0, 12, 20]) cylinder(r=2.5, h=5, $fn=8);
        }
    }
  }
}

// Blower Fan module
module blower_fan() {
  color([0.15, 0.15, 0.17]) {
    // Frame
    difference() {
      cube([40, 40, 10], center=true);
      cylinder(d=36, h=12, center=true, $fn=32);
    }
    // Hub
    cylinder(d=16, h=8, center=true, $fn=24);
    // Blades
    for (i = [0:6]) {
      rotate([0, 0, i*360/7])
        hull() {
          translate([8, 0, -3]) cylinder(r=2, h=6, $fn=8);
          translate([16, 4, 0]) rotate([0, 12, 20]) cylinder(r=2.5, h=5, $fn=8);
        }
    }
  }
}

// Assembly module
module assembly() {
  blower();
  translate([0, 0, overall_depth_mm/2 + 5]) fan();
  translate([0, 0, overall_depth_mm/2 + 20]) blower_fan();
}

assembly();