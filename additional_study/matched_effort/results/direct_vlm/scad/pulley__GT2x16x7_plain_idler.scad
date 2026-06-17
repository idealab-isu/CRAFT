$fn = 160;

// Pulley parameters
outer_d      = 40;   // overall flange diameter
groove_d     = 30;   // diameter at groove bottom (belt rides near this)
width        = 16;   // total pulley width
flange_th    = 2.5;  // thickness of each flange
bore_d       = 8;    // center bore diameter
hub_d        = 18;   // hub diameter
hub_len      = 10;   // hub length (centered)
set_screw_d  = 3;    // optional set screw hole diameter
set_screw_on = true;

module pulley() {
  difference() {
    union() {
      // Main body with V-groove profile via rotate_extrude
      rotate_extrude(convexity=10)
        polygon(points=[
          [bore_d/2, -width/2],
          [outer_d/2, -width/2],
          [outer_d/2, -width/2 + flange_th],
          [groove_d/2, 0],
          [outer_d/2,  width/2 - flange_th],
          [outer_d/2,  width/2],
          [bore_d/2,   width/2]
        ]);

      // Hub (centered)
      translate([0,0,0])
        cylinder(d=hub_d, h=hub_len, center=true);
    }

    // Bore through
    cylinder(d=bore_d, h=width + 2, center=true);

    // Optional set screw (radial)
    if (set_screw_on) {
      translate([0,0,0])
        rotate([0,90,0])
          translate([0,0,hub_d/2])
            cylinder(d=set_screw_d, h=hub_d + 2, center=true);
    }
  }
}

pulley();