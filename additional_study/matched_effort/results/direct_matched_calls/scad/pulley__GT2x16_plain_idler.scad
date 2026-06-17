$fn = 160;

// Parametric pulley
// Units: mm
bore_d      = 5;     // center hole diameter
hub_d       = 18;    // hub diameter
hub_h       = 10;    // hub height (overall pulley thickness)
rim_d       = 36;    // outer diameter at flanges
core_d      = 28;    // diameter at groove bottom (between flanges)
flange_t    = 2.2;   // flange thickness (each side)
groove_depth= (rim_d - core_d)/2; // radial depth
crown       = 0.6;   // slight crown on belt surface
set_screw_d = 3;     // optional set screw hole diameter
set_screw_z = 0;     // 0 = centered on hub height
key_flat    = 0;     // 0 = none; >0 makes a D-flat on bore (flat offset from center)

module d_bore(d=5, h=20, flat=0){
    if (flat <= 0) {
        cylinder(d=d, h=h, center=true);
    } else {
        // D-shaped bore: subtract a box to create a flat
        difference() {
            cylinder(d=d, h=h, center=true);
            translate([d/2 - flat, 0, 0])
                cube([d, d*2, h+2], center=true);
        }
    }
}

module pulley(){
    difference(){
        union(){
            // Hub
            cylinder(d=hub_d, h=hub_h, center=true);

            // Flanges
            translate([0,0, hub_h/2 - flange_t/2])
                cylinder(d=rim_d, h=flange_t, center=true);
            translate([0,0,-hub_h/2 + flange_t/2])
                cylinder(d=rim_d, h=flange_t, center=true);

            // Belt surface (between flanges) with slight crown
            // Use a rotated profile for a smooth groove/crown
            rotate_extrude(convexity=10)
                polygon(points=[
                    // r, z profile (z along height)
                    [core_d/2, -hub_h/2 + flange_t],
                    [core_d/2 + groove_depth*0.55, -hub_h/2 + flange_t + (hub_h-2*flange_t)*0.25],
                    [rim_d/2 - 0.2, 0],
                    [core_d/2 + groove_depth*0.55,  hub_h/2 - flange_t - (hub_h-2*flange_t)*0.25],
                    [core_d/2,  hub_h/2 - flange_t]
                ]);
            
            // Crown bump (very subtle) on the belt surface
            if (crown > 0)
                rotate_extrude(convexity=10)
                    polygon(points=[
                        [core_d/2 + groove_depth*0.35, - (hub_h/2 - flange_t)],
                        [core_d/2 + groove_depth*0.35 + crown, 0],
                        [core_d/2 + groove_depth*0.35,   (hub_h/2 - flange_t)]
                    ]);
        }

        // Bore
        d_bore(d=bore_d, h=hub_h+4, flat=key_flat);

        // Set screw hole (radial)
        if (set_screw_d > 0)
            translate([0,0,set_screw_z])
                rotate([0,90,0])
                    cylinder(d=set_screw_d, h=rim_d, center=true);
    }
}

pulley();