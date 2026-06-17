$fn = 160;

// Parametric pulley
// Units: mm
bore_d      = 5;     // center hole diameter
hub_d       = 18;    // hub outer diameter
hub_h       = 10;    // hub height (axial)
rim_d       = 40;    // outer diameter at rim
rim_h       = 14;    // rim height (axial)
flange_d    = 46;    // flange outer diameter
flange_t    = 2.2;   // flange thickness (each side)
groove_depth= 4.0;   // V-groove depth (radial)
groove_angle= 40;    // included angle of V-groove (degrees)
set_screw_d = 3;     // optional set screw hole diameter
set_screw_z = 0;     // 0 = centered on hub height
set_screw_on= true;

module pulley() {
    difference() {
        union() {
            // Rim body
            cylinder(d=rim_d, h=rim_h, center=true);

            // Flanges
            translate([0,0, rim_h/2 - flange_t/2])
                cylinder(d=flange_d, h=flange_t, center=true);
            translate([0,0,-rim_h/2 + flange_t/2])
                cylinder(d=flange_d, h=flange_t, center=true);

            // Hub
            cylinder(d=hub_d, h=hub_h, center=true);
        }

        // Bore
        cylinder(d=bore_d, h=max(rim_h, hub_h) + 2, center=true);

        // V-groove cut (rotate_extrude of a triangular notch)
        // Groove centered axially; depth is radial.
        // Half-angle:
        ha = groove_angle/2;
        // Groove half-width at rim surface:
        gw = groove_depth * tan(ha);
        // Place triangle so its base lies on rim OD and apex points inward.
        rotate_extrude(angle=360, convexity=10)
            polygon(points=[
                [rim_d/2 + 0.2, -gw],
                [rim_d/2 + 0.2,  gw],
                [rim_d/2 - groove_depth, 0]
            ]);

        // Optional set screw hole through hub (radial)
        if (set_screw_on) {
            translate([0,0,set_screw_z])
                rotate([0,90,0])
                    cylinder(d=set_screw_d, h=hub_d + 2, center=true);
        }
    }
}

pulley();