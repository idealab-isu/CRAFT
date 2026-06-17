// Parameters
plate_length = 300; //[150:600:1]
plate_width = 200; //[100:400:1]
plate_thickness = 12; //[6:24:1]
corner_radius = 10; //[5:20:1]
edge_fillet_radius = 1.5; //[0.5:3:0.1]
chamfer_size = 2; //[0.5:6:0.5]
op_overlap = 1; //[0.5:2:0.5]

// Main tooling plate with rounded corners
module tooling_plate() {
  color("Silver")
  hull() {
    translate([0, 0, 0])
      cube([plate_length, plate_width, plate_thickness], center=true);
    translate([plate_length/2 - corner_radius, plate_width/2 - corner_radius, 0])
      cylinder(h=plate_thickness + 2*op_overlap, r=corner_radius, center=true);
    translate([-plate_length/2 + corner_radius, plate_width/2 - corner_radius, 0])
      cylinder(h=plate_thickness + 2*op_overlap, r=corner_radius, center=true);
    translate([-plate_length/2 + corner_radius, -plate_width/2 + corner_radius, 0])
      cylinder(h=plate_thickness + 2*op_overlap, r=corner_radius, center=true);
    translate([plate_length/2 - corner_radius, -plate_width/2 + corner_radius, 0])
      cylinder(h=plate_thickness + 2*op_overlap, r=corner_radius, center=true);
  }
}

// Edge fillet approximation
module edge_fillet() {
  minkowski() {
    tooling_plate();
    sphere(r=edge_fillet_radius, center=true);
  }
}

// Corner chamfers
module corner_chamfers() {
  union() {
    translate([plate_length/2 - chamfer_size/2 + op_overlap/2, plate_width/2 - chamfer_size/2 + op_overlap/2, 0])
      rotate([0, 0, 45])
      cube([chamfer_size, chamfer_size, plate_thickness + 2*op_overlap], center=true);
    translate([-plate_length/2 + chamfer_size/2 - op_overlap/2, plate_width/2 - chamfer_size/2 + op_overlap/2, 0])
      rotate([0, 0, 45])
      cube([chamfer_size, chamfer_size, plate_thickness + 2*op_overlap], center=true);
    translate([-plate_length/2 + chamfer_size/2 - op_overlap/2, -plate_width/2 + chamfer_size/2 - op_overlap/2, 0])
      rotate([0, 0, 45])
      cube([chamfer_size, chamfer_size, plate_thickness + 2*op_overlap], center=true);
    translate([plate_length/2 - chamfer_size/2 + op_overlap/2, -plate_width/2 + chamfer_size/2 - op_overlap/2, 0])
      rotate([0, 0, 45])
      cube([chamfer_size, chamfer_size, plate_thickness + 2*op_overlap], center=true);
  }
}

// Engraved label placeholder (omitted per no-text rule)
module engraved_label() {
  translate([0, 0, plate_thickness/2 - (plate_thickness/10)/2])
    cube([plate_length/4, plate_width/8, plate_thickness/10], center=true);
}

// Complete model
difference() {
  edge_fillet();
  corner_chamfers();
  engraved_label();
}