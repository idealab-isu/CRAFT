$fn = 128;

// Rigid shaft coupling: 5mm to 8mm bore, 12.5mm OD, 25mm long
// Simple stepped-bore sleeve with a central divider.

od = 12.5;
len = 25.0;

bore1_d = 5.0;   // one side
bore2_d = 8.0;   // other side

divider_th = 1.5; // solid web between bores

module coupling() {
  difference() {
    cylinder(d=od, h=len);

    // Bore for 5mm shaft (from one end to divider)
    translate([0,0,-0.01])
      cylinder(d=bore1_d, h=(len - divider_th)/2 + 0.02);

    // Bore for 8mm shaft (from other end to divider)
    translate([0,0,len - (len - divider_th)/2 - 0.01])
      cylinder(d=bore2_d, h=(len - divider_th)/2 + 0.02);
  }
}

coupling();