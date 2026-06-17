// Parameters
magnet_diameter = 20; //[10:40:1]
magnet_thickness = 5; //[2.5:10:0.5]
chamfer_size = 0.5; //[0.25:1.5:0.05]
polarity_mark_diameter = 4; //[2:10:0.5]
polarity_mark_depth = 0.4; //[0.2:1:0.05]
engraved_label_depth = 0.3; //[0.2:1:0.05]
engraved_label_width = 10; //[5:20:0.5]
engraved_label_height = 4; //[2:10:0.5]
overlap = 0.8; //[0.5:2:0.1]

// Magnet Body
module magnet_body() {
  cylinder(h=magnet_thickness, r=magnet_diameter/2, center=true);
}

// Edge Chamfer
module edge_chamfer() {
  cylinder(h=magnet_thickness + 2*chamfer_size, r=magnet_diameter/2 + chamfer_size, center=true);
}

// Polarity Marking
module polarity_marking() {
  translate([magnet_diameter/2 - polarity_mark_diameter/2 - chamfer_size, 0, magnet_thickness/2 - polarity_mark_depth/2])
    cylinder(h=polarity_mark_depth + overlap, r=polarity_mark_diameter/2, center=true);
}

// Engraved Label
module engraved_label() {
  translate([0, 0, magnet_thickness/2 - engraved_label_depth/2])
    cube([engraved_label_width, engraved_label_height, engraved_label_depth + overlap], center=true);
}

// Magnet with Chamfer
module magnet_with_chamfer() {
  intersection() {
    magnet_body();
    edge_chamfer();
  }
}

// Final Magnet
module magnet_final() {
  difference() {
    magnet_with_chamfer();
    polarity_marking();
    engraved_label();
  }
}

// Render the final magnet
color([0.8, 0.6, 0.2]) // Brass-like color
magnet_final();