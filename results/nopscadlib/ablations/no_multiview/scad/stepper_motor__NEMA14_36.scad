// Parameters
face_width = 35.2; //[17.6:70.4:0.1]
face_thickness = 3.0; //[1.5:6.0:0.1]
body_length = 36.0; //[18.0:72.0:0.1]
body_width = 35.2; //[17.6:70.4:0.1]
body_height = 35.2; //[17.6:70.4:0.1]
shaft_diameter = 5.0; //[2.5:10.0:0.1]
shaft_length = 20.0; //[10.0:40.0:0.1]
mounting_hole_spacing = 26.0; //[13.0:52.0:0.1]
mounting_hole_diameter = 3.5; //[2.0:6.0:0.1]
mounting_hole_depth = 6.0; //[3.0:12.0:0.1]
overlap = 1.0; //[0.5:2.0:0.1]
d_plug_length = 14.0; //[7.0:28.0:0.1]
d_plug_width = 10.0; //[5.0:20.0:0.1]
d_plug_rad = 2.0; //[1.0:4.0:0.1]
aux_plate_thickness = 2.0; //[1.0:5.0:0.1]
grill_width = 18.0; //[9.0:36.0:0.1]
grill_height = 18.0; //[9.0:36.0:0.1]
grill_hole_diameter = 3.0; //[1.5:6.0:0.1]
grill_gap = 2.0; //[1.0:5.0:0.1]
screw_shank_diameter = 3.0; //[2.0:6.0:0.1]
screw_length = 10.0; //[5.0:25.0:0.1]
screw_head_diameter = 5.5; //[3.0:12.0:0.1]
screw_head_height = 2.5; //[1.0:6.0:0.1]
washer_outer_diameter = 7.0; //[4.0:14.0:0.1]
washer_thickness = 1.0; //[0.5:2.5:0.1]
ttrack_plate_width = 16.0; //[8.0:32.0:0.1]
ttrack_plate_height = 10.0; //[5.0:20.0:0.1]
ttrack_hole_diameter = 4.0; //[2.0:8.0:0.1]
ttrack_hole_spacing = 10.0; //[5.0:20.0:0.1]
rail_plate_width = 16.0; //[8.0:32.0:0.1]
rail_plate_height = 10.0; //[5.0:20.0:0.1]
rail_hole_diameter = 4.0; //[2.0:8.0:0.1]
rail_hole_spacing = 10.0; //[5.0:20.0:0.1]

// D Plug D
module d_plug_D() {
  color("Silver") {
    linear_extrude(height=aux_plate_thickness) {
      polygon(points=[
        [-d_plug_length/2, -(d_plug_width/2 - d_plug_rad)],
        [-(d_plug_length/2 - d_plug_rad), -d_plug_width/2],
        [(d_plug_length/2 - d_plug_rad), -d_plug_width/2],
        [d_plug_length/2, -(d_plug_width/2 - d_plug_rad)],
        [d_plug_length/2, (d_plug_width/2 - d_plug_rad)],
        [(d_plug_length/2 - d_plug_rad), d_plug_width/2],
        [-(d_plug_length/2 - d_plug_rad), d_plug_width/2],
        [-d_plug_length/2, (d_plug_width/2 - d_plug_rad)]
      ]);
    }
  }
}

// Grill Hole Positions
module grill_hole_positions() {
  color("Black") {
    for (i = [0:2]) {
      translate([grill_width/4 * i, 0, 0])
        cylinder(r=grill_hole_diameter/2, h=aux_plate_thickness + 2*overlap, center=true);
      translate([grill_width/4 * i + grill_width/8, grill_height/2, 0])
        cylinder(r=grill_hole_diameter/2, h=aux_plate_thickness + 2*overlap, center=true);
    }
  }
}

// Screw and Washer
module screw_and_washer() {
  color("DimGray") {
    union() {
      translate([0, 0, screw_length/2 - overlap])
        cylinder(r=screw_shank_diameter/2, h=screw_length, center=true);
      translate([0, 0, screw_head_height/2 - overlap])
        cylinder(r=screw_head_diameter/2, h=screw_head_height, center=true);
      translate([0, 0, washer_thickness/2 - overlap])
        cylinder(r=washer_outer_diameter/2, h=washer_thickness, center=true);
    }
  }
}

// Ttrack Hole Positions
module ttrack_hole_positions() {
  color("Black") {
    for (i = [-1, 1]) {
      translate([i * ttrack_hole_spacing/2, 0, 0])
        cylinder(r=ttrack_hole_diameter/2, h=aux_plate_thickness + 2*overlap, center=true);
    }
  }
}

// Rail Hole Positions
module rail_hole_positions() {
  color("Black") {
    for (i = [-1, 1]) {
      translate([i * rail_hole_spacing/2, 0, 0])
        cylinder(r=rail_hole_diameter/2, h=aux_plate_thickness + 2*overlap, center=true);
    }
  }
}

// Motor Assembly
module assembly() {
  color("Black") {
    // Motor Body
    translate([0, 0, -(face_thickness/2 + body_length/2 - overlap)])
      cube([body_width, body_height, body_length], center=true);
    // Front Face
    translate([0, 0, 0])
      cube([face_width, face_width, face_thickness], center=true);
    // Shaft
    translate([0, 0, face_thickness/2 + shaft_length/2 - overlap])
      cylinder(r=shaft_diameter/2, h=shaft_length, center=true);
  }
  
  // Mounting Holes
  color("Silver") {
    for (x = [-1, 1], y = [-1, 1]) {
      translate([x * mounting_hole_spacing/2, y * mounting_hole_spacing/2, -(mounting_hole_depth/2 - overlap)])
        cylinder(r=mounting_hole_diameter/2, h=mounting_hole_depth, center=true);
    }
  }
  
  // D Plug D
  translate([0, 0, -(face_thickness/2 + aux_plate_thickness/2 - overlap)])
    d_plug_D();
  
  // Grill Plate with Holes
  translate([face_width/2 + grill_width/2 - overlap, 0, 0])
    difference() {
      cube([grill_width, grill_height, aux_plate_thickness], center=true);
      grill_hole_positions();
    }
  
  // Ttrack Plate with Holes
  translate([0, face_width/2 + ttrack_plate_height/2 - overlap, 0])
    difference() {
      cube([ttrack_plate_width, ttrack_plate_height, aux_plate_thickness], center=true);
      ttrack_hole_positions();
    }
  
  // Rail Plate with Holes
  translate([0, -(face_width/2 + rail_plate_height/2 - overlap), 0])
    difference() {
      cube([rail_plate_width, rail_plate_height, aux_plate_thickness], center=true);
      rail_hole_positions();
    }
  
  // Screw and Washer
  translate([0, 0, face_thickness/2 + screw_length/2 - overlap])
    screw_and_washer();
}

assembly();