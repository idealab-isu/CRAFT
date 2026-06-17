// Parameters
magnet_diameter = 8.0; //[4.0:16.0:0.1]
magnet_height = 4.2; //[2.1:8.4:0.1]
edge_chamfer_size = 0.4; //[0.2:0.8:0.05]
edge_fillet_radius = 0.25; //[0.1:0.6:0.05]
polarity_mark_diameter = 1.2; //[0.6:2.4:0.1]
polarity_mark_depth = 0.25; //[0.1:0.6:0.05]
overlap = 0.8; //[0.5:2.0:0.1]

// Base Shapes
module magnet_body() {
  cylinder(h=magnet_height, r=magnet_diameter/2, center=true);
}

module edge_chamfer() {
  translate([0, 0, magnet_height/2 - edge_chamfer_size/2 + overlap/2])
    cylinder(h=edge_chamfer_size, r1=magnet_diameter/2, r2=0, center=true);
}

module edge_fillet() {
  translate([0, 0, magnet_height/2 - edge_fillet_radius + overlap/2])
    rotate_extrude() translate([magnet_diameter/2 - edge_fillet_radius, 0, 0])
    circle(r=edge_fillet_radius);
}

module polarity_mark() {
  translate([0, 0, magnet_height/2 - polarity_mark_depth/2])
    cylinder(h=polarity_mark_depth + overlap, r=polarity_mark_diameter/2, center=true);
}

// Final Geometry
module magnet_complete() {
  difference() {
    magnet_body();
    edge_chamfer();
    edge_fillet();
    polarity_mark();
  }
}

// Render the final magnet
color([0.72, 0.45, 0.2]) // Copper color
magnet_complete();