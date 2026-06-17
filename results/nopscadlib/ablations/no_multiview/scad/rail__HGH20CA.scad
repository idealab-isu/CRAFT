// Parameters
rail_length = 100.0; //[50.0:200.0:1]
rail_width = 20.0; //[10.0:40.0:0.5]
rail_height = 17.5; //[8.75:35.0:0.5]
overlap = 1.0; //[0.5:2.0:0.1]
chamfer_len = 1.5; //[0.75:3.0:0.1]
fillet_radius = 0.8; //[0.4:1.6:0.1]
hole_diameter = 0.0; //[0.0:6.0:0.1]
marking_depth = 0.0; //[0.0:1.0:0.05]

// Base Shapes
module rail_body() {
  translate([0, 0, 0])
    cube([rail_width, rail_length, rail_height], center=true);
}

module end_chamfer_wedge() {
  linear_extrude(height=chamfer_len, center=true)
    polygon(points=[
      [-rail_width/2 - overlap, -rail_height/2 - overlap],
      [rail_width/2 + overlap, -rail_height/2 - overlap],
      [rail_width/2 + overlap, rail_height/2 + overlap],
      [-rail_width/2 - overlap, rail_height/2 + overlap],
      [-rail_width/2 - overlap, -rail_height/2 - overlap]
    ]);
}

module fillet_sphere() {
  sphere(r=fillet_radius, center=true);
}

module mounting_hole_cyl() {
  rotate([90, 0, 0])
    cylinder(r=hole_diameter/2, h=rail_height + 2*overlap, center=true);
}

module engraved_markings_void() {
  translate([0, 0, rail_height/2 - marking_depth/2])
    cube([rail_width - 2*overlap, rail_length - 2*overlap, marking_depth], center=true);
}

// Operations
module edge_fillets() {
  minkowski() {
    rail_body();
    fillet_sphere();
  }
}

module end_chamfer_front_pos() {
  translate([0, rail_length/2 - chamfer_len/2 + overlap, 0])
    end_chamfer_wedge();
}

module end_chamfer_back_pos() {
  translate([0, -rail_length/2 + chamfer_len/2 - overlap, 0])
    end_chamfer_wedge();
}

module end_chamfers() {
  difference() {
    edge_fillets();
    end_chamfer_front_pos();
    end_chamfer_back_pos();
  }
}

module mounting_holes_pos() {
  translate([0, 0, 0])
    mounting_hole_cyl();
}

module mounting_holes() {
  difference() {
    end_chamfers();
    mounting_holes_pos();
  }
}

module engraved_markings() {
  difference() {
    mounting_holes();
    engraved_markings_void();
  }
}

// Final Output
engraved_markings();