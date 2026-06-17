// Parameters
plate_length = 300; //[150:600:1]
plate_width = 200; //[100:400:1]
plate_thickness = 12; //[6:24:1]
micro_overlap = 1; //[0.5:2:0.1]

// Base shapes
module tooling_plate_body() {
  cube([plate_length, plate_width, plate_thickness], center=true);
}

module edge_chamfer() {
  cube([plate_length - micro_overlap, plate_width - micro_overlap, plate_thickness - micro_overlap], center=true);
}

module corner_radius() {
  cube([plate_length - micro_overlap, plate_width - micro_overlap, plate_thickness - micro_overlap], center=true);
}

module surface_finish_marking() {
  cube([plate_length - micro_overlap, plate_width - micro_overlap, plate_thickness - micro_overlap], center=true);
}

module engraved_label() {
  cube([plate_length - micro_overlap, plate_width - micro_overlap, plate_thickness - micro_overlap], center=true);
}

// Final geometry
module tooling_plate_complete() {
  union() {
    tooling_plate_body();
    edge_chamfer();
    corner_radius();
    surface_finish_marking();
    engraved_label();
  }
}

// Render the final output
color("Silver") tooling_plate_complete();