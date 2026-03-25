$fn=96;

pulley();

module pulley(
    od=60,          // outer diameter
    width=20,       // total width
    bore=8,         // center hole diameter
    hub_od=26,      // hub diameter
    hub_width=26,   // hub width (can exceed width; will be centered)
    flange_od=64,   // flange diameter
    flange_th=2,    // flange thickness each side
    groove_depth=6, // V-groove depth (radial)
    groove_angle=40,// included angle of V-groove
    set_screw_d=4,  // set screw hole diameter
    set_screw_z=0   // set screw height along Z
){
    difference(){
        union(){
            // Main rim with flanges
            rim_with_flanges(od=od, width=width, flange_od=flange_od, flange_th=flange_th);

            // Hub
            cylinder(d=hub_od, h=hub_width, center=true);
        }

        // Bore
        cylinder(d=bore, h=max(width,hub_width)+2, center=true);

        // V-groove cut
        v_groove_cut(od=od, width=width, flange_th=flange_th, groove_depth=groove_depth, groove_angle=groove_angle);

        // Set screw hole (radial through hub)
        translate([0,0,set_screw_z])
            rotate([0,90,0])
                cylinder(d=set_screw_d, h=hub_od+4, center=true);
    }
}

module rim_with_flanges(od=60, width=20, flange_od=64, flange_th=2){
    union(){
        // Core rim
        cylinder(d=od, h=width, center=true);

        // Flanges
        translate([0,0, width/2 - flange_th/2])
            cylinder(d=flange_od, h=flange_th, center=true);
        translate([0,0,-width/2 + flange_th/2])
            cylinder(d=flange_od, h=flange_th, center=true);
    }
}

module v_groove_cut(od=60, width=20, flange_th=2, groove_depth=6, groove_angle=40){
    // Create a revolved V profile and subtract it
    // Profile is centered at Z=0, spanning between flanges
    zspan = max(0.1, width - 2*flange_th);
    r_outer = od/2 + 0.2;
    r_inner = max(0.1, od/2 - groove_depth);

    // Half-angle
    ha = groove_angle/2;

    // For a given radial depth, compute half-width at outer radius
    // tan(ha) = (half_width) / (radial_depth)
    halfw = groove_depth * tan(ha);

    // Clamp halfw to available zspan
    halfw2 = min(halfw, zspan/2);

    rotate_extrude(convexity=10)
        polygon(points=[
            [r_outer, -zspan/2 - 1],
            [r_outer,  zspan/2 + 1],
            [r_outer,  halfw2],
            [r_inner,  0],
            [r_outer, -halfw2]
        ]);
}