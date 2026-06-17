// Parameters
shaft_diameter = 10; //[5:20:0.1]
shaft_clearance = 0.3; //[0.1:0.8:0.05]
base_length = 67; //[34:134:0.5]
base_width = 53; //[27:106:0.5]
base_thickness = 10; //[5:20:0.5]
overall_height = 36; //[20:72:0.5]
bearing_outer_diameter = 30; //[18:60:0.5]
bearing_width = 12; //[6:24:0.5]
housing_wall_thickness = 6; //[3:12:0.5]
mount_hole_diameter = 8; //[4:16:0.5]
mount_hole_clearance = 0.5; //[0.2:1.2:0.1]
mount_hole_spacing_length = 50; //[30:100:0.5]
mount_hole_spacing_width = 0; //[0:20:0.5]
mount_hole_type = 0; //[0:1:1]
fillet_radius = 1.5; //[0.5:4:0.5]
minkowski_quality_sphere_radius = 0.8; //[0.3:2:0.1]
connect_overlap = 1; //[0.5:2:0.1]
trapezoid_base = 18; //[9:36:0.5]
trapezoid_top = 10; //[5:20:0.5]
trapezoid_height = 14; //[7:28:0.5]
trapezoid_extrude = 20; //[10:40:0.5]

// Right Trapezoid
module right_trapezoid() {
  color("Silver") {
    translate([base_length/2 - trapezoid_extrude/2 + connect_overlap, 0, base_thickness/2 + trapezoid_height/2 - connect_overlap])
    rotate([0, 90, 0])
    linear_extrude(height=trapezoid_extrude, center=true) {
      polygon(points=[
        [0, 0],
        [trapezoid_base, 0],
        [trapezoid_top, trapezoid_height],
        [0, trapezoid_height]
      ]);
    }
  }
}

// Sbr Bearing Block Assembly
module sbr_bearing_block_assembly() {
  color("DimGray") {
    // Placeholder for detailed geometry
    cube([20, 20, 20], center=true);
  }
}

// Kp Pillow Block Assembly
module kp_pillow_block_assembly() {
  color("Black") {
    // Base Plate
    translate([0, 0, 0])
    cube([base_length, base_width, base_thickness], center=true);
    
    // Housing
    translate([0, 0, base_thickness/2 + (overall_height - base_thickness + connect_overlap)/2 - connect_overlap])
    cube([bearing_width + 2*housing_wall_thickness, bearing_outer_diameter + 2*housing_wall_thickness, overall_height - base_thickness + connect_overlap], center=true);
    
    // Bearing Seat Boss
    translate([0, 0, base_thickness/2 + (overall_height - base_thickness) - (bearing_outer_diameter/2) + connect_overlap])
    rotate([0, 90, 0])
    cylinder(r=bearing_outer_diameter/2, h=bearing_width, center=true);
  }
}

// Scs Bearing Block
module scs_bearing_block() {
  color("DimGray") {
    // Placeholder for detailed geometry
    cube([20, 20, 20], center=true);
  }
}

// Kp Pillow Block Hole Positions
module kp_pillow_block_hole_positions() {
  color("Silver") {
    // Mounting Holes
    translate([mount_hole_spacing_length/2, mount_hole_spacing_width, 0])
    cylinder(r=(mount_hole_diameter + mount_hole_clearance)/2, h=base_thickness + 2*connect_overlap, center=true);
    
    translate([-mount_hole_spacing_length/2, mount_hole_spacing_width, 0])
    cylinder(r=(mount_hole_diameter + mount_hole_clearance)/2, h=base_thickness + 2*connect_overlap, center=true);
  }
}

// Assembly
module assembly() {
  difference() {
    union() {
      kp_pillow_block_assembly();
      right_trapezoid();
    }
    kp_pillow_block_hole_positions();
    translate([0, 0, base_thickness/2 + (overall_height - base_thickness) - (bearing_outer_diameter/2) + connect_overlap])
    rotate([0, 90, 0])
    cylinder(r=(shaft_diameter + shaft_clearance)/2, h=base_length + 2*housing_wall_thickness, center=true);
  }
}

assembly();