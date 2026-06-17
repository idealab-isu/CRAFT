$fn=96;

// Simple antenna: base + mast + coil + tip
module antenna(
    base_d=28,
    base_h=10,
    mast_d=6,
    mast_h=120,
    tip_h=18,
    tip_d=2.2,
    coil_turns=10,
    coil_pitch=6,
    coil_wire_d=2.2,
    coil_radius=6.5,
    coil_z0=18
){
    // Base with slight chamfer
    module base(){
        difference(){
            union(){
                cylinder(d=base_d, h=base_h);
                translate([0,0,base_h-1.2])
                    cylinder(d1=base_d, d2=base_d-3, h=1.2);
            }
            // Mount hole
            translate([0,0,-0.1]) cylinder(d=4.2, h=base_h+0.2);
            // Counterbore
            translate([0,0,base_h-4]) cylinder(d=8.5, h=4.2);
        }
    }

    // Helical coil made by hulling spheres along a helix
    module coil(turns, pitch, wire_d, radius, z0){
        steps_per_turn = 28;
        n = max(8, floor(turns*steps_per_turn));
        for(i=[0:n-1]){
            t1 = i/n;
            t2 = (i+1)/n;
            a1 = 360*turns*t1;
            a2 = 360*turns*t2;
            z1 = z0 + pitch*turns*t1;
            z2 = z0 + pitch*turns*t2;
            hull(){
                translate([radius*cos(a1), radius*sin(a1), z1])
                    sphere(d=wire_d);
                translate([radius*cos(a2), radius*sin(a2), z2])
                    sphere(d=wire_d);
            }
        }
    }

    // Main assembly
    union(){
        base();

        // Mast
        translate([0,0,base_h])
            cylinder(d=mast_d, h=mast_h);

        // Coil around lower mast
        coil(coil_turns, coil_pitch, coil_wire_d, coil_radius, base_h + coil_z0);

        // Tip (tapered)
        translate([0,0,base_h+mast_h])
            cylinder(d1=mast_d*0.9, d2=tip_d, h=tip_h);

        // Small rounded end
        translate([0,0,base_h+mast_h+tip_h])
            sphere(d=tip_d*1.2);
    }
}

antenna();