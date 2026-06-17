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
    coil_pitch=4.2,
    tip_d=4,
    tip_h=18
){
    union() {
        // Base (with slight chamfer)
        difference() {
            cylinder(d=base_d, h=base_h);
            translate([0,0,1.2])
                cylinder(d=base_d-3, h=base_h); // creates a subtle rim
        }
        translate([0,0,0])
            cylinder(d=base_d-2, h=base_h);

        // Mast
        translate([0,0,base_h])
            cylinder(d=mast_d, h=mast_h);

        // Coil around upper mast section
        translate([0,0,base_h + mast_h*0.55])
            helical_coil(
                outer_d=coil_outer_d,
                wire_d=coil_wire_d,
                turns=coil_turns,
                pitch=coil_pitch
            );

        // Tip (tapered)
        translate([0,0,base_h + mast_h])
            cylinder(d1=mast_d, d2=tip_d, h=tip_h*0.55);
        translate([0,0,base_h + mast_h + tip_h*0.55])
            cylinder(d1=tip_d, d2=0.8, h=tip_h*0.45);
    }
}

// Helical coil made by hulling small spheres along a helix
module helical_coil(outer_d=14, wire_d=2.2, turns=10, pitch=4.2, steps_per_turn=28){
    r = outer_d/2 - wire_d/2;
    total_steps = max(8, floor(turns*steps_per_turn));
    step_angle = 360*turns/total_steps;
    step_z = pitch*turns/total_steps;

    for (i=[0:total_steps-1]) {
        hull() {
            translate([r*cos(i*step_angle), r*sin(i*step_angle), i*step_z])
                sphere(d=wire_d);
            translate([r*cos((i+1)*step_angle), r*sin((i+1)*step_angle), (i+1)*step_z])
                sphere(d=wire_d);
        }
    }
}

antenna();