$fn = 180;

// Dimensions (mm)
bore_d = 5.0;
od_d   = 16.0;
width  = 5.0;

flange_d = 18.0;
flange_t = 1.0;          // flange thickness (typical)
flange_z = width - flange_t; // flange at one end

// Simple visual detailing (non-critical)
shield_recess_d = 14.2;
shield_recess_t = 0.35;

module flanged_bearing() {
  difference() {
    union() {
      // Main outer ring body
      cylinder(d=od_d, h=width);

      // Flange on one side
      translate([0,0,flange_z])
        cylinder(d=flange_d, h=flange_t);
    }

    // Bore
    translate([0,0,-0.1])
      cylinder(d=bore_d, h=width + flange_t + 0.2);

    // Shallow shield recesses (both sides) for appearance
    translate([0,0,-0.01])
      cylinder(d=shield_recess_d, h=shield_recess_t + 0.02);

    translate([0,0,width - shield_recess_t - 0.01])
      cylinder(d=shield_recess_d, h=shield_recess_t + 0.02);
  }
}

flanged_bearing();