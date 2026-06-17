$fn = 64;

// -------------------- Parameters --------------------
shell_width = 30;            //[15:60:1]
shell_height = 12;           //[6:24:1]
shell_depth = 15;            //[8:30:1]
shell_wall_thickness = 1.5;  //[0.8:3:0.1]

flange_width = 40;           //[20:80:1]
flange_height = 16;          //[8:32:1]
flange_thickness = 2.5;      //[1.2:6:0.1]

mount_hole_diameter = 3.2;   //[2:6:0.1]
mount_hole_spacing = 33;     //[20:66:1]

rear_exit_diameter = 8;      //[4:16:0.5]
rear_exit_length = 10;       //[5:25:1]

pin_diameter = 1;            //[0.6:2:0.1]
pin_length = 6;              //[3:12:1]
pin_pitch_x = 2.8;           //[2:5:0.1]
pin_pitch_y = 2.2;           //[1.5:4:0.1]
pin_cols = 5;                //[3:10:1]
pin_rows = 2;                //[1:3:1]

jackscrew_diameter = 5;      //[3:10:0.5]
jackscrew_length = 6;        //[3:15:1]

strain_relief_diameter = 12; //[8:24:0.5]
strain_relief_length = 8;    //[4:20:1]

overlap = 1;                 //[0.5:2:0.1]
fillet_radius = 0.6;         //[0.2:2:0.1]

// -------------------- Derived / helpers --------------------
eps = 0.01;
front_z = -(shell_depth/2);
back_z  =  (shell_depth/2);

// -------------------- Geometry helpers --------------------
module d_profile_2d(w, h) {
  // D-shape: flat on left, round on right
  union() {
    translate([-w/2, -h/2]) square([w - h/2, h], center=false);
    translate([w/2 - h/2, 0]) circle(r=h/2);
  }
}

module d_shell_solid() {
  linear_extrude(height=shell_depth, center=true, convexity=10)
    d_profile_2d(shell_width, shell_height);
}

module d_shell_cavity() {
  // Inner cavity open at front, leaving a back wall thickness
  inner_w = max(0.1, shell_width  - 2*shell_wall_thickness);
  inner_h = max(0.1, shell_height - 2*shell_wall_thickness);
  inner_d = max(0.1, shell_depth  - shell_wall_thickness);

  // Place cavity so its FRONT is flush with shell front (open), and it stops short of back wall
  // Cavity spans: [front_z, front_z + inner_d]
  translate([0, 0, front_z + inner_d/2])
    linear_extrude(height=inner_d + eps, center=true, convexity=10)
      d_profile_2d(inner_w, inner_h);
}

module flange_plate() {
  // Flange attached to front face with overlap into shell
  translate([0, 0, front_z - flange_thickness/2 + overlap])
    cube([flange_width, flange_height, flange_thickness], center=true);
}

module mount_holes() {
  // Through-holes in flange (along Z)
  hole_z = front_z - flange_thickness/2 + overlap;
  for (sx = [-1, 1])
    translate([sx*mount_hole_spacing/2, 0, hole_z])
      cylinder(d=mount_hole_diameter, h=flange_thickness + 2*overlap, center=true);
}

module jackscrews() {
  // Solid posts on front side, connected to flange with overlap
  // Jackscrew spans: [front_z - flange_thickness + overlap, front_z - flange_thickness + overlap - jackscrew_length]
  js_center_z = (front_z - flange_thickness + overlap) - jackscrew_length/2;
  for (sx = [-1, 1])
    translate([sx*mount_hole_spacing/2, 0, js_center_z])
      cylinder(d=jackscrew_diameter, h=jackscrew_length, center=true);
}

module rear_cable_exit_outer() {
  // Connected to back face with overlap
  translate([0, 0, back_z + rear_exit_length/2 - overlap])
    cylinder(d=rear_exit_diameter, h=rear_exit_length, center=true);
}

module rear_cable_exit_inner() {
  // Cable passage (subtracted)
  inner_d = max(0.1, rear_exit_diameter - 2*shell_wall_thickness);
  translate([0, 0, back_z + rear_exit_length/2 - overlap])
    cylinder(d=inner_d, h=rear_exit_length + 2*overlap, center=true);
}

module strain_relief_outer() {
  // Strain relief connected to rear exit with overlap
  // Rear exit ends at: back_z + rear_exit_length - overlap
  sr_center_z = (back_z + rear_exit_length - overlap) + strain_relief_length/2 - overlap;
  translate([0, 0, sr_center_z])
    cylinder(d=strain_relief_diameter, h=strain_relief_length, center=true);
}

module strain_relief_inner() {
  // Continuous cable passage through strain relief
  inner_d = max(0.1, rear_exit_diameter - 2*shell_wall_thickness);
  sr_center_z = (back_z + rear_exit_length - overlap) + strain_relief_length/2 - overlap;
  translate([0, 0, sr_center_z])
    cylinder(d=inner_d, h=strain_relief_length + 2*overlap, center=true);
}

module pin_array() {
  // Pins protrude out of the front opening; base overlaps into shell
  // Pin spans: [front_z + overlap - pin_length, front_z + overlap]
  pin_center_z = (front_z + overlap) - pin_length/2;

  for (row = [0:pin_rows-1]) {
    for (col = [0:pin_cols-1]) {
      xoff = -(pin_cols-1)*pin_pitch_x/2 + col*pin_pitch_x + (row%2)*pin_pitch_x/2;
      yoff = (row - (pin_rows-1)/2) * pin_pitch_y;
      translate([xoff, yoff, pin_center_z])
        cylinder(d=pin_diameter, h=pin_length, center=true);
    }
  }
}

// -------------------- Assembly --------------------
module connector_solid() {
  difference() {
    union() {
      // D-shell with cavity (open at front)
      difference() {
        d_shell_solid();
        d_shell_cavity();
      }

      // Flange attached to front
      flange_plate();

      // Rear exit + strain relief attached to back
      rear_cable_exit_outer();
      strain_relief_outer();

      // Pins and jackscrews attached to front
      pin_array();
      jackscrews();
    }

    // Subtractions
    mount_holes();
    rear_cable_exit_inner();
    strain_relief_inner();
  }
}

// Fillet (kept as one connected solid)
minkowski() {
  connector_solid();
  sphere(r=fillet_radius);
}