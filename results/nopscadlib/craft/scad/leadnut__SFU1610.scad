// Leadscrew nut housing block: 16.0mm x 28.0mm x 42.5mm
// Single connected solid (housing only). All cuts are internal voids.

width = 16; //[8:32:0.5]
height = 28; //[14:56:0.5]
length = 42.5; //[21.25:85:0.5]

tolerance = 0.3; //[0.1:0.8:0.05]
nut_outer_diameter = 12; //[6:24:0.5]
nut_length = 18; //[9:36:0.5]

leadscrew_diameter = 8; //[4:16:0.5]
clearance_diameter = 8.6; //[4.4:17.2:0.1]

mount_hole_diameter = 3.5; //[2:7:0.1]
mount_hole_edge_offset = 3.5; //[2:7:0.1]

overlap = 1; //[0.5:2:0.1]

$fn = 64;

module housing() {
  difference() {
    // Main body
    cube([width, height, length], center=true);

    // Leadscrew clearance bore (along Z / length)
    cylinder(h=length + 2*overlap, r=clearance_diameter/2, center=true);

    // Nut cavity (along Y / height)
    // Ensure the cavity fully spans the body thickness in Y.
    rotate([90, 0, 0])
      cylinder(h=height + 2*overlap, r=(nut_outer_diameter + 2*tolerance)/2, center=true);

    // Mounting holes (along Z / length), 4 corners on the face
    for (x = [-1, 1], y = [-1, 1]) {
      translate([x*(width/2 - mount_hole_edge_offset),
                 y*(height/2 - mount_hole_edge_offset),
                 0])
        cylinder(h=length + 2*overlap, r=(mount_hole_diameter + 2*tolerance)/2, center=true);
    }
  }
}

housing();