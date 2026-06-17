// Parameters
pipe_length = 150; //[75:300:1]
outer_diameter = 32; //[16:64:0.5]
wall_thickness = 2; //[1:4:0.1]
chamfer_length = 1.5; //[0.5:3:0.1]
overlap = 1; //[0.5:2:0.1]

// Pipe Body
module pipe_body() {
  cylinder(h = pipe_length, r = outer_diameter / 2, center = true);
}

// Inner Bore
module inner_bore() {
  cylinder(h = pipe_length + 2 * overlap, r = outer_diameter / 2 - wall_thickness, center = true);
}

// End Chamfer
module end_chamfer_top() {
  translate([0, 0, pipe_length / 2 - chamfer_length / 2 + overlap / 2])
    cylinder(h = chamfer_length, r1 = outer_diameter / 2, r2 = 0, center = true);
}

module end_chamfer_bottom() {
  translate([0, 0, -pipe_length / 2 + chamfer_length / 2 - overlap / 2])
    rotate([180, 0, 0])
    cylinder(h = chamfer_length, r1 = outer_diameter / 2, r2 = 0, center = true);
}

// End Chamfers
module end_chamfers() {
  union() {
    end_chamfer_top();
    end_chamfer_bottom();
  }
}

// Pipe Shell without Chamfers
module pipe_shell_no_chamfer() {
  difference() {
    pipe_body();
    inner_bore();
  }
}

// Pipe Shell with Chamfers
module pipe_shell_with_chamfers() {
  difference() {
    pipe_shell_no_chamfer();
    end_chamfers();
  }
}

// Final Output
pipe_shell_with_chamfers();