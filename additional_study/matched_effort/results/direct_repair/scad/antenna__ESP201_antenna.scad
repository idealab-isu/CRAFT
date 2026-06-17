$fn=96;

// Simple antenna model: base + mast + coil + tip
module antenna(
    base_d=28,
    base_h=10,
    mast_d=6,
    mast_h=120,
    coil_outer_d=14,
    coil_wire_d=2.2,
    coil_turns=10,
    coil_pitch=6,
    tip_h=18
){
    union() {
        // Base (slightly rounded)
        translate([0,0,base_h/2])
            minkowski() {
                cylinder(d=base_d-2, h=base_h-2, center=true);
                sphere(r=1);
            }

        // Mast
        translate([0,0,base_h])
            cylinder(d=mast_d, h=mast_h);

        // Coil around upper mast section
        translate([0,0,base_h + mast_h*0.45])
            helical_coil(
                outer_d=coil_outer_d,
                wire_d=coil_wire_d,
                turns=coil_turns,
                pitch=coil_pitch
            );

        // Tip (tapered)
        translate([0,0,base_h + mast_h])
            cylinder(d1=mast_d, d2=1.2, h=tip_h);
    }
}

// Helical coil made by hulling successive wire spheres along a helix
module helical_coil(outer_d=14, wire_d=2.2, turns=10, pitch=6, steps_per_turn=24){
    r = outer_d/2 - wire_d/2;
    total_steps = max(3, floor(turns*steps_per_turn));
    step_ang = 360*turns/total_steps;
    step_z = pitch*turns/total_steps;

    for (i=[0:total_steps-1]) {
        hull() {
            translate([ r*cos(i*step_ang), r*sin(i*step_ang), i*step_z ])
                sphere(d=wire_d);
            translate([ r*cos((i+1)*step_ang), r*sin((i+1)*step_ang), (i+1)*step_z ])
                sphere(d=wire_d);
        }
    }
}

// Render
antenna();