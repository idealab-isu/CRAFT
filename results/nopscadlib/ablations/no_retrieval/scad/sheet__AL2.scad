// Parameters
plate_L = 300; //[150:600:1]
plate_W = 200; //[100:400:1]
plate_T = 12; //[6:24:1]
edge_chamfer = 0.5; //[0.25:2:0.25]
corner_radius = 6; //[3:20:1]
hole_d = 10; //[4:20:1]
hole_edge_offset = 25; //[10:60:1]
hole_pitch_x = 100; //[50:200:1]
hole_pitch_y = 75; //[40:150:1]
hole_count_x = 3; //[2:6:1]
hole_count_y = 2; //[2:6:1]
hole_clearance_z = 2; //[1:5:0.5]

// Base shapes
module tooling_plate_body() {
  cube([plate_L - 2*(corner_radius + edge_chamfer), 
        plate_W - 2*(corner_radius + edge_chamfer), 
        plate_T - 2*edge_chamfer], center=true);
}

module corner_radius_sphere() {
  sphere(r=corner_radius, center=true);
}

module edge_chamfer_sphere() {
  sphere(r=edge_chamfer, center=true);
}

module mounting_hole_cutter() {
  cylinder(h=plate_T + hole_clearance_z, r=hole_d/2, center=true);
}

module engraved_label() {
  cube([plate_L/5, plate_W/6, plate_T/20], center=true);
}

// Operations
module corner_radius() {
  minkowski() {
    tooling_plate_body();
    corner_radius_sphere();
  }
}

module edge_chamfer_or_radius() {
  minkowski() {
    corner_radius();
    edge_chamfer_sphere();
  }
}

module mounting_holes_pattern() {
  union() {
    for (i = [0:hole_count_x-1]) {
      for (j = [0:hole_count_y-1]) {
        translate([-(hole_pitch_x*(hole_count_x-1))/2 + i*hole_pitch_x, 
                   -(hole_pitch_y*(hole_count_y-1))/2 + j*hole_pitch_y, 
                   0]) 
        mounting_hole_cutter();
      }
    }
  }
}

module plate_with_holes() {
  difference() {
    edge_chamfer_or_radius();
    mounting_holes_pattern();
  }
}

module final_model() {
  union() {
    plate_with_holes();
    translate([0, 0, plate_T/2 - (plate_T/20)/2]) engraved_label();
  }
}

// Render the final model
color("Silver") final_model();