$fn = 180;

bore_d = 5.0;
od_d = 13.0;
width = 4.0;

flange_d = 15.0;
flange_th = 1.0;

chamfer = 0.35;

module flanged_bearing() {
  difference() {
    union() {
      // Main outer ring
      cylinder(d=od_d, h=width);

      // Flange (on one side)
      translate([0,0,width - flange_th])
        cylinder(d=flange_d, h=flange_th);
    }

    // Bore
    translate([0,0,-0.2])
      cylinder(d=bore_d, h=width + 0.4);

    // Small chamfers on bore edges (approx)
    translate([0,0,-0.01])
      cylinder(d1=bore_d + 2*chamfer, d2=bore_d, h=chamfer + 0.02);

    translate([0,0,width - chamfer - 0.01])
      cylinder(d1=bore_d, d2=bore_d + 2*chamfer, h=chamfer + 0.02);

    // Small chamfers on OD edges (approx)
    translate([0,0,-0.01])
      cylinder(d1=od_d, d2=od_d - 2*chamfer, h=chamfer + 0.02);

    translate([0,0,width - flange_th - chamfer - 0.01])
      cylinder(d1=od_d - 2*chamfer, d2=od_d, h=chamfer + 0.02);

    // Flange outer edge chamfer (approx)
    translate([0,0,width - chamfer - 0.01])
      cylinder(d1=flange_d, d2=flange_d - 2*chamfer, h=chamfer + 0.02);
  }
}

flanged_bearing();