// Parameters
rail_length = 100.0; //[50.0:200.0:1]
rail_width = 12.0; //[6.0:24.0:0.5]
rail_height = 8.0; //[4.0:16.0:0.5]
hole_diameter = 3.2; //[2.0:6.0:0.1]
hole_count = 4; //[2:8:1]
end_margin = 12.0; //[6.0:24.0:0.5]
chamfer_size = 1.0; //[0.5:3.0:0.1]
fillet_radius = 0.8; //[0.3:2.0:0.1]
engrave_depth = 0.3; //[0.1:1.0:0.1]
engrave_width = 6.0; //[3.0:10.0:0.5]
engrave_length = 20.0; //[10.0:40.0:1]
overlap = 1.0; //[0.5:2.0:0.1]

// Base Shapes
module rail_body() {
  cube([rail_width, rail_length, rail_height], center=true);
}

module mounting_holes() {
  cylinder(h=rail_height + 2*overlap, r=hole_diameter/2, center=true);
}

module end_chamfer_wedge() {
  cube([rail_width + 2*overlap, chamfer_size, chamfer_size], center=true);
}

module edge_fillet_sphere() {
  sphere(r=fillet_radius);
}

module engraved_markings() {
  cube([engrave_width, engrave_length, engrave_depth + 2*overlap], center=true);
}

// Operations
module edge_fillets() {
  minkowski() {
    rail_body();
    edge_fillet_sphere();
  }
}

module holes_all() {
  union() {
    translate([0, -rail_length/2 + end_margin, 0]) mounting_holes();
    translate([0, -rail_length/2 + end_margin + (rail_length - 2*end_margin)/3, 0]) mounting_holes();
    translate([0, -rail_length/2 + end_margin + 2*(rail_length - 2*end_margin)/3, 0]) mounting_holes();
    translate([0, rail_length/2 - end_margin, 0]) mounting_holes();
  }
}

module end_chamfers() {
  union() {
    translate([0, rail_length/2 - chamfer_size/2 + overlap/2, rail_height/2 - chamfer_size/2 + overlap/2])
      rotate([45, 0, 0]) end_chamfer_wedge();
    translate([0, -rail_length/2 + chamfer_size/2 - overlap/2, rail_height/2 - chamfer_size/2 + overlap/2])
      rotate([-45, 0, 0]) end_chamfer_wedge();
  }
}

module engrave_pos() {
  translate([0, 0, rail_height/2 - engrave_depth/2 + overlap/2]) engraved_markings();
}

// Final Rail
module rail_complete() {
  difference() {
    difference() {
      difference() {
        edge_fillets();
        holes_all();
      }
      end_chamfers();
    }
    engrave_pos();
  }
}

// Render the final rail
color([0.75, 0.75, 0.77]) rail_complete();