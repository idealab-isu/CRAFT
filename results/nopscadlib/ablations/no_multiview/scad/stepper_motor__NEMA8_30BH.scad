// Parameters
face_width = 20.0; //[10.0:40.0:0.5]
body_length = 30.0; //[15.0:60.0:0.5]
body_width = 20.0; //[10.0:40.0:0.5]
body_height = 20.0; //[10.0:40.0:0.5]
front_face_thickness = 2.0; //[1.0:6.0:0.25]
shaft_diameter = 5.0; //[2.0:10.0:0.25]
shaft_length = 12.0; //[6.0:30.0:0.5]
mounting_hole_spacing = 16.0; //[8.0:32.0:0.5]
mounting_hole_diameter = 3.0; //[1.5:6.0:0.25]
overlap = 1.0; //[0.5:2.0:0.1]
hole_extra = 0.5; //[0.1:1.5:0.1]
d_plug_length = 10.0; //[5.0:20.0:0.5]
d_plug_width = 6.0; //[3.0:12.0:0.5]
d_plug_rad = 1.0; //[0.5:3.0:0.25]
aux_stub_size = 0.5; //[0.2:2.0:0.1]

// Modules for mandatory components
module d_plug_D() {
  color("DimGray") {
    linear_extrude(height=aux_stub_size, center=true) {
      polygon(points=[
        [-d_plug_length/2, -d_plug_width/2],
        [d_plug_length/2, -d_plug_width/2],
        [d_plug_length/2, d_plug_width/2],
        [-d_plug_length/2, d_plug_width/2]
      ]);
    }
  }
}

module grill_hole_positions() {
  color("Silver") {
    translate([0, 0, -(front_face_thickness/2 + body_length/2)])
      sphere(r=1);
  }
}

module screw_and_washer() {
  color("Black") {
    translate([0, 0, -(front_face_thickness/2 + body_length/2)])
      cylinder(r=aux_stub_size/2, h=aux_stub_size, center=true);
  }
}

module ttrack_hole_positions() {
  color("Silver") {
    translate([0, 0, -(front_face_thickness/2 + body_length/2)])
      cube([aux_stub_size, aux_stub_size, aux_stub_size], center=true);
  }
}

module rail_hole_positions() {
  color("Silver") {
    translate([0, 0, -(front_face_thickness/2 + body_length/2)])
      cube([aux_stub_size, aux_stub_size, aux_stub_size], center=true);
  }
}

// Main motor assembly
module motor_with_mounting_holes() {
  difference() {
    union() {
      // Front face
      color("Black") translate([0, 0, 0])
        cube([face_width, face_width, front_face_thickness], center=true);
      
      // Motor body
      translate([0, 0, -(front_face_thickness/2 + body_length/2 - overlap)])
        cube([body_width, body_height, body_length], center=true);
      
      // Output shaft
      color("Silver") translate([0, 0, front_face_thickness/2 + shaft_length/2 - overlap])
        cylinder(r=shaft_diameter/2, h=shaft_length, center=true);
      
      // Placeholder components
      d_plug_D();
      grill_hole_positions();
      screw_and_washer();
      ttrack_hole_positions();
      rail_hole_positions();
    }
    
    // Mounting holes
    for (x = [-1, 1], y = [-1, 1]) {
      translate([x * mounting_hole_spacing/2, y * mounting_hole_spacing/2, 0])
        cylinder(r=mounting_hole_diameter/2, h=front_face_thickness + hole_extra, center=true);
    }
  }
}

// Final assembly
module assembly() {
  motor_with_mounting_holes();
}

assembly();