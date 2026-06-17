$fn = 180;

bore_d = 3.0;
od_d = 10.0;
width = 4.0;

flange_d = 11.5;
flange_th = 0.7;

ring_wall = 1.0;          // radial thickness of inner ring
shield_recess = 0.25;     // shallow recess for shields
shield_lip = 0.25;        // remaining lip thickness at faces

module flanged_bearing() {
  difference() {
    union() {
      // Main outer ring body
      cylinder(d=od_d, h=width);

      // Flange on one side (bottom)
      cylinder(d=flange_d, h=flange_th);
    }

    // Bore through
    translate([0,0,-0.5])
      cylinder(d=bore_d, h=width + flange_th + 1.0);

    // Inner ring clearance (creates separation between inner and outer rings)
    translate([0,0,-0.5])
      cylinder(d=bore_d + 2*ring_wall, h=width + flange_th + 1.0);

    // Ball race cavity (torus-like via rotate_extrude)
    // Positioned within the main ring height (not into flange)
    race_z0 = flange_th;
    race_h = width;
    race_center_z = race_z0 + race_h/2;

    race_r = (od_d/2 + (bore_d/2 + ring_wall)) / 2;
    race_tube_r = 0.75;

    translate([0,0,race_center_z])
      rotate_extrude()
        translate([race_r,0,0])
          circle(r=race_tube_r);

    // Shield recesses on both faces of the main ring
    // Top face recess
    translate([0,0,flange_th + (width - shield_recess)])
      cylinder(d=od_d - 0.6, h=shield_recess + 0.01);

    // Bottom face recess (above flange)
    translate([0,0,flange_th - 0.01])
      cylinder(d=od_d - 0.6, h=shield_recess + 0.01);
  }

  // Inner ring (separate solid)
  color([0.75,0.75,0.78])
  translate([0,0,flange_th])
    difference() {
      cylinder(d=bore_d + 2*ring_wall, h=width);
      translate([0,0,-0.5])
        cylinder(d=bore_d, h=width + 1.0);
    }
}

flanged_bearing();