// Parameters
plate_length = 300; //[150:600:1]
plate_width = 200; //[100:400:1]
plate_thickness = 12; //[6:24:1]
edge_chamfer = 0.5; //[0.25:2:0.25]
corner_radius = 6; //[3:12:0.5]
chamfer_length = 2; //[1:6:0.5]
mount_hole_diameter = 10; //[4:20:0.5]
mount_hole_edge_margin = 20; //[10:50:1]
mount_hole_count_x = 4; //[2:10:1]
mount_hole_count_y = 3; //[2:10:1]
hole_clearance_z = 2; //[1:6:0.5]

// Main tooling plate with corner rounding and edge chamfer
module tooling_plate() {
  difference() {
    // Base plate
    color("Silver")
    cube([plate_length, plate_width, plate_thickness], center=true);

    // Corner rounding
    for (x = [-1, 1], y = [-1, 1]) {
      translate([x * (plate_length/2 - corner_radius), y * (plate_width/2 - corner_radius), 0])
        difference() {
          cube([corner_radius*2, corner_radius*2, plate_thickness + hole_clearance_z], center=true);
          cylinder(r=corner_radius, h=plate_thickness + hole_clearance_z, center=true);
        }
    }

    // Edge chamfers
    for (x = [-1, 1]) {
      translate([x * (plate_length/2 - chamfer_length/2), 0, plate_thickness/2 - edge_chamfer/2])
        cube([chamfer_length, plate_width, edge_chamfer], center=true);
      translate([x * (plate_length/2 - chamfer_length/2), 0, -plate_thickness/2 + edge_chamfer/2])
        cube([chamfer_length, plate_width, edge_chamfer], center=true);
    }
    for (y = [-1, 1]) {
      translate([0, y * (plate_width/2 - chamfer_length/2), plate_thickness/2 - edge_chamfer/2])
        cube([plate_length, chamfer_length, edge_chamfer], center=true);
      translate([0, y * (plate_width/2 - chamfer_length/2), -plate_thickness/2 + edge_chamfer/2])
        cube([plate_length, chamfer_length, edge_chamfer], center=true);
    }
  }
}

// Mounting holes pattern
module mounting_holes() {
  color("Black")
  for (i = [0:mount_hole_count_x-1], j = [0:mount_hole_count_y-1]) {
    translate([
      -plate_length/2 + mount_hole_edge_margin + i * (plate_length - 2*mount_hole_edge_margin) / (mount_hole_count_x - 1),
      -plate_width/2 + mount_hole_edge_margin + j * (plate_width - 2*mount_hole_edge_margin) / (mount_hole_count_y - 1),
      0
    ])
    cylinder(r=mount_hole_diameter/2, h=plate_thickness + hole_clearance_z, center=true);
  }
}

// Final assembly
difference() {
  tooling_plate();
  mounting_holes();
}