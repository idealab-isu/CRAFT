// Parameters
pipe_length = 150; //[75:300:1]
outer_diameter = 40; //[20:80:1]
wall_thickness = 2; //[1:4:0.5]
chamfer_length = 1.5; //[0.5:4:0.5]
chamfer_radial = 1; //[0.5:3:0.5]
overlap = 0.8; //[0.5:2:0.1]

// Base Shapes
module pipe_body() {
  cylinder(h=pipe_length, r=outer_diameter/2, center=true);
}

module inner_bore() {
  cylinder(h=pipe_length + 2*overlap, r=outer_diameter/2 - wall_thickness, center=true);
}

module end_chamfer_top() {
  translate([0, 0, pipe_length/2 - (chamfer_length + overlap)/2])
    cylinder(h=chamfer_length + overlap, r1=outer_diameter/2 + chamfer_radial, r2=outer_diameter/2 - chamfer_radial, center=true);
}

module end_chamfer_bottom() {
  translate([0, 0, -pipe_length/2 + (chamfer_length + overlap)/2])
    cylinder(h=chamfer_length + overlap, r1=outer_diameter/2 - chamfer_radial, r2=outer_diameter/2 + chamfer_radial, center=true);
}

module markings_text() {
  cube([overlap, overlap, overlap], center=true);
}

// Operations
module end_chamfers() {
  union() {
    end_chamfer_top();
    end_chamfer_bottom();
  }
}

module pipe_with_bore() {
  difference() {
    pipe_body();
    inner_bore();
  }
}

module pipe_with_bore_and_chamfers() {
  difference() {
    pipe_with_bore();
    end_chamfers();
  }
}

// Final Output
module complete_model() {
  union() {
    pipe_with_bore_and_chamfers();
    markings_text();
  }
}

// Render the complete model
complete_model();