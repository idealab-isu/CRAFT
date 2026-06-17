// Parameters
magnet_diameter = 20; //[10:40:1]
magnet_thickness = 5; //[2.5:10:0.5]
chamfer_size = 0.5; //[0.25:1:0.05]
overlap = 1; //[0.5:2:0.1]
polarity_mark_diameter = 4; //[2:8:0.5]
polarity_mark_depth = 0.4; //[0.2:1:0.05]
label_depth = 0.3; //[0.1:0.8:0.05]
label_width = 10; //[5:20:0.5]
label_height = 4; //[2:10:0.5]

// Base Shapes
module magnet_body() {
  cylinder(h=magnet_thickness, r=magnet_diameter/2, center=true);
}

module edge_chamfer() {
  translate([0, 0, magnet_thickness/2 - chamfer_size/2 + overlap/2])
    cylinder(h=chamfer_size, r1=magnet_diameter/2, r2=0, center=true);
}

module polarity_marking() {
  translate([0, 0, magnet_thickness/2 - polarity_mark_depth/2])
    cylinder(h=polarity_mark_depth + overlap, r=polarity_mark_diameter/2, center=true);
}

module engraved_label() {
  translate([0, 0, magnet_thickness/2 - label_depth/2])
    cube([label_width, label_height, label_depth + overlap], center=true);
}

// Operations
module magnet_with_chamfer() {
  difference() {
    magnet_body();
    edge_chamfer();
  }
}

module magnet_with_mark() {
  difference() {
    magnet_with_chamfer();
    polarity_marking();
  }
}

module magnet_complete() {
  difference() {
    magnet_with_mark();
    engraved_label();
  }
}

// Final Output
color([0.8, 0.6, 0.2]) // Brass color for the magnet
magnet_complete();