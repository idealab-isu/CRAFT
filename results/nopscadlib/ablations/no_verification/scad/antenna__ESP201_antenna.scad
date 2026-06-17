// Parameters
mast_height = 150; //[75:300:1]
mast_diameter = 6; //[3:12:0.5]
base_diameter = 30; //[15:60:1]
base_thickness = 6; //[3:12:0.5]
flange_diameter = 40; //[20:80:1]
flange_thickness = 3; //[1.5:8:0.5]
hole_count = 3; //[2:8:1]
hole_diameter = 3.2; //[2:6:0.1]
hole_circle_diameter = 30; //[15:70:1]
top_tip_height = 8; //[0:20:0.5]
top_tip_diameter = 4; //[2:10:0.5]
cable_exit_diameter = 5; //[2:12:0.5]
rib_count = 12; //[0:24:1]
rib_radial_thickness = 0.8; //[0.3:2:0.1]
rib_tangential_width = 1.2; //[0.5:3:0.1]
rib_height = 18; //[5:40:1]
overlap = 1; //[0.5:2:0.1]

// Base cylinder
module base_cyl() {
  color("Silver")
  translate([0, 0, 0])
  cylinder(r=base_diameter/2, h=base_thickness, center=true);
}

// Flange cylinder
module flange_cyl() {
  color("Silver")
  translate([0, 0, -(base_thickness/2 + flange_thickness/2 - overlap)])
  cylinder(r=flange_diameter/2, h=flange_thickness, center=true);
}

// Mast cylinder
module mast_cyl() {
  color("DimGray")
  translate([0, 0, base_thickness/2 + mast_height/2 - overlap])
  cylinder(r=mast_diameter/2, h=mast_height, center=true);
}

// Top tip cone
module top_tip_cone() {
  color("DimGray")
  translate([0, 0, base_thickness/2 + mast_height - overlap + top_tip_height/2])
  cylinder(r1=top_tip_diameter/2, r2=0, h=top_tip_height, center=true);
}

// Mounting holes
module mount_hole(angle) {
  translate([hole_circle_diameter/2 * cos(angle), hole_circle_diameter/2 * sin(angle), -(base_thickness/2 + flange_thickness/2 - overlap)/2])
  cylinder(r=hole_diameter/2, h=base_thickness + flange_thickness + overlap*4, center=true);
}

// Cable exit hole
module cable_exit_hole() {
  translate([0, 0, -(base_thickness/2 + flange_thickness/2 - overlap)/2])
  cylinder(r=cable_exit_diameter/2, h=base_thickness + flange_thickness + overlap*4, center=true);
}

// Rib
module rib(angle) {
  translate([(mast_diameter/2 + rib_radial_thickness/2 - overlap) * cos(angle), (mast_diameter/2 + rib_radial_thickness/2 - overlap) * sin(angle), base_thickness/2 + rib_height/2 - overlap])
  rotate([0, 0, angle])
  cube([rib_radial_thickness, rib_tangential_width, rib_height], center=true);
}

// Assemble antenna
module antenna() {
  difference() {
    union() {
      union() {
        base_cyl();
        flange_cyl();
      }
      union() {
        mast_cyl();
        for (i = [0:30:330]) {
          rib(i);
        }
      }
      if (top_tip_height > 0) {
        top_tip_cone();
      }
    }
    union() {
      for (i = [0, 120, 240]) {
        mount_hole(i);
      }
      cable_exit_hole();
    }
  }
}

// Final output
antenna();