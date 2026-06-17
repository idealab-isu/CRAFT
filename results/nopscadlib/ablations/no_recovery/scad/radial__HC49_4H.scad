// Parameters
R_main = 10.5; //[5.25:21:0.1]
H_main = 3.7; //[1.85:7.4:0.1]
R_secondary = 3.5; //[1.75:7:0.1]
H_secondary = 1.5; //[0.75:3:0.1]
overlap = 0.8; //[0.5:2:0.1]
R_hole = 1.6; //[0.8:3.2:0.1]
hole_extra = 1.0; //[0.5:3:0.1]
chamfer_h = 0.6; //[0.3:1.2:0.1]
chamfer_r = 0.8; //[0.4:1.6:0.1]
groove_count = 6; //[3:16:1]
groove_r = 0.6; //[0.3:1.2:0.1]
groove_depth = 0.7; //[0.3:1.5:0.1]

// Base Shapes
module main_radial_body() {
  translate([0, 0, 0])
    cylinder(r=R_main, h=H_main, center=true);
}

module secondary_radial_dimension() {
  translate([0, 0, H_main/2 + H_secondary/2 - overlap])
    cylinder(r=R_secondary, h=H_secondary, center=true);
}

module mounting_hole() {
  translate([0, 0, 0])
    cylinder(r=R_hole, h=H_main + H_secondary + 2*hole_extra, center=true);
}

module fillets_chamfers() {
  translate([0, 0, H_main/2 - chamfer_h/2])
    cylinder(r=R_main + chamfer_r, h=chamfer_h, center=true);
}

module decorative_groove_cutter_base() {
  translate([R_main - groove_depth, 0, 0])
    cylinder(r=groove_r, h=H_main + H_secondary + 2*hole_extra, center=true);
}

// Operations
module union_body_and_secondary() {
  union() {
    main_radial_body();
    secondary_radial_dimension();
  }
}

module difference_mounting_hole() {
  difference() {
    union_body_and_secondary();
    mounting_hole();
  }
}

module difference_chamfer_top_outer() {
  difference() {
    difference_mounting_hole();
    fillets_chamfers();
  }
}

module decorative_grooves() {
  difference() {
    difference_chamfer_top_outer();
    for (i = [0:groove_count-1]) {
      rotate([0, 0, i*360/groove_count])
        decorative_groove_cutter_base();
    }
  }
}

// Final Output
decorative_grooves();