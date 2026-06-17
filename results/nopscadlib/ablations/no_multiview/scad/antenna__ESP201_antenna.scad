// Parameters
mast_h = 300; //[150:600:1]
mast_d = 8; //[4:16:0.5]
base_d = 40; //[20:80:1]
base_h = 12; //[6:24:1]
flange_d = 55; //[30:110:1]
flange_h = 4; //[2:10:0.5]
hole_count = 3; //[2:8:1]
hole_d = 4.2; //[2.5:8:0.1]
hole_circle_d = 45; //[25:90:1]
tip_cap_h = 10; //[5:25:1]
tip_cap_d = 10; //[6:20:0.5]
cable_hole_d = 6; //[3:12:0.5]
cable_hole_offset = 10; //[0:25:1]
rib_count = 12; //[6:24:1]
rib_depth = 1.2; //[0.5:3:0.1]
rib_width = 3; //[1:6:0.5]
rib_h = 10; //[4:20:1]
overlap = 1; //[0.5:2:0.1]

// Base Shapes
module flange_cyl() {
  translate([0, 0, flange_h/2])
    cylinder(r=flange_d/2, h=flange_h, center=true);
}

module base_cyl() {
  translate([0, 0, flange_h + base_h/2 - overlap])
    cylinder(r=base_d/2, h=base_h, center=true);
}

module mast_cyl() {
  translate([0, 0, flange_h + base_h - overlap + mast_h/2 - overlap])
    cylinder(r=mast_d/2, h=mast_h, center=true);
}

module tip_cap_sphere() {
  translate([0, 0, flange_h + base_h - overlap + mast_h - overlap + tip_cap_h/2])
    sphere(r=tip_cap_d/2, center=true);
}

module tip_cap_cyl() {
  translate([0, 0, flange_h + base_h - overlap + mast_h - overlap + tip_cap_h/2])
    cylinder(r=tip_cap_d/2, h=tip_cap_h, center=true);
}

module mount_hole(pos) {
  translate(pos)
    cylinder(r=hole_d/2, h=flange_h + base_h + overlap*2, center=true);
}

module cable_exit_hole() {
  translate([cable_hole_offset, 0, (flange_h + base_h)/2])
    cylinder(r=cable_hole_d/2, h=flange_h + base_h + overlap*2, center=true);
}

module rib(pos, rot) {
  translate(pos)
  rotate([0, 0, rot])
    cube([rib_depth, rib_width, rib_h], center=true);
}

// Operations
module tip_cap_union() {
  union() {
    tip_cap_cyl();
    tip_cap_sphere();
  }
}

module antenna_solid_union() {
  union() {
    flange_cyl();
    base_cyl();
    mast_cyl();
    tip_cap_union();
    for (i = [0:rib_count-1]) {
      rib([(base_d/2 + rib_depth/2 - overlap)*cos(i*360/rib_count),
           (base_d/2 + rib_depth/2 - overlap)*sin(i*360/rib_count),
           flange_h + rib_h/2 - overlap], i*360/rib_count);
    }
  }
}

module mount_holes_union() {
  union() {
    for (i = [0:hole_count-1]) {
      mount_hole([(hole_circle_d/2)*cos(i*360/hole_count),
                  (hole_circle_d/2)*sin(i*360/hole_count),
                  (flange_h + base_h)/2]);
    }
  }
}

module holes_union_all() {
  union() {
    mount_holes_union();
    cable_exit_hole();
  }
}

// Final Output
difference() {
  antenna_solid_union();
  holes_union_all();
}