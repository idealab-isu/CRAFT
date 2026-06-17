// Parameters
rail_length = 100.0; //[50.0:200.0:1]
rail_width = 7.0; //[3.5:14.0:0.1]
rail_height = 5.0; //[2.5:10.0:0.1]
hole_diameter = 3.0; //[1.5:6.0:0.1]
hole_count = 4; //[2:8:1]
end_margin = 12.0; //[6.0:24.0:1]
hole_pitch = 25.0; //[10.0:50.0:1]
chamfer_length = 2.0; //[0.5:5.0:0.1]
fillet_radius = 0.6; //[0.2:1.5:0.1]
fillet_trim = 1.0; //[0.5:3.0:0.1]
overlap = 1.0; //[0.5:2.0:0.1]

// Rail Body
module rail_body() {
  color("Silver")
  translate([0, 0, 0])
    cube([rail_width, rail_length, rail_height], center=true);
}

// Mounting Holes
module mounting_hole(position_y) {
  translate([0, position_y, 0])
    rotate([90, 0, 0])
      cylinder(h=rail_height + 2*overlap, r=hole_diameter/2, center=true);
}

module mounting_holes() {
  union() {
    mounting_hole(-rail_length/2 + end_margin);
    mounting_hole(-rail_length/2 + end_margin + hole_pitch);
    mounting_hole(rail_length/2 - end_margin - hole_pitch);
    mounting_hole(rail_length/2 - end_margin);
  }
}

// End Chamfers
module end_chamfer(position_y) {
  translate([0, position_y, 0])
    rotate([0, 0, 45])
      cube([rail_width + 2*overlap, chamfer_length, rail_height + 2*overlap], center=true);
}

module end_chamfers() {
  difference() {
    edge_fillets();
    end_chamfer(rail_length/2 - chamfer_length/2 + overlap/2);
    end_chamfer(-rail_length/2 + chamfer_length/2 - overlap/2);
  }
}

// Edge Fillets
module edge_fillets() {
  minkowski() {
    translate([0, 0, 0])
      cube([rail_width - 2*fillet_trim, rail_length - 2*fillet_trim, rail_height - 2*fillet_trim], center=true);
    sphere(r=fillet_radius, center=true);
  }
}

// Complete Model
module complete_model() {
  difference() {
    end_chamfers();
    mounting_holes();
  }
}

// Final Output
complete_model();