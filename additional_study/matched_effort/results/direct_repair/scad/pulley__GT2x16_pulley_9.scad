$fn = 180;

// Timing pulley (simplified GT2-like tooth form)
// User spec: 16 teeth, 9.65mm pitch diameter
teeth = 16;
pitch_d = 9.65;                 // mm
pitch_r = pitch_d/2;

pulley_width = 10;              // mm
hub_thickness = 0;              // set >0 if you want a hub
bore_d = 5;                     // mm (edit as needed)

// Tooth geometry (simplified, not a manufacturer-accurate profile)
tooth_height = 1.2;             // radial height above pitch circle
tooth_root_depth = 0.6;         // radial depth below pitch circle
tooth_tip_width = 1.2;          // tangential width at tooth tip
tooth_root_width = 2.0;         // tangential width at tooth root
tooth_round = 0.25;             // rounding radius for tooth corners

// Derived
pitch_circ = PI * pitch_d;
tooth_pitch = pitch_circ / teeth;
base_r = pitch_r - tooth_root_depth;
outer_r = pitch_r + tooth_height;

module rounded_trapezoid_2d(wb, wt, h, r=0.2){
    // Centered on X, base at y=0, top at y=h
    // Create trapezoid then offset for rounding
    offset(r=r)
        offset(delta=-r)
            polygon(points=[
                [-wb/2, 0],
                [ wb/2, 0],
                [ wt/2, h],
                [-wt/2, h]
            ]);
}

module tooth_3d(){
    // Tooth centered at origin, extends in +Y (radially outward)
    linear_extrude(height=pulley_width, center=true, convexity=10)
        translate([0, pitch_r])  // place base around pitch circle
            rounded_trapezoid_2d(tooth_root_width, tooth_tip_width, tooth_height + tooth_root_depth, tooth_round);
}

module pulley_body(){
    // Main cylinder from base_r to outer_r, then subtract valleys by cutting between teeth
    // We'll build as outer cylinder and subtract root cylinder to create a ring,
    // then add teeth on top of pitch circle and finally cut bore.
    difference(){
        union(){
            // Ring body up to pitch circle (root to pitch)
            cylinder(r=pitch_r, h=pulley_width, center=true);
            // Teeth
            for(i=[0:teeth-1]){
                rotate([0,0,i*360/teeth])
                    tooth_3d();
            }
            // Optional hub
            if(hub_thickness > 0)
                translate([0,0,(pulley_width+hub_thickness)/2])
                    cylinder(r=outer_r*0.9, h=hub_thickness, center=true);
        }
        // Cut inner to root radius to create tooth valleys
        cylinder(r=base_r, h=pulley_width+2, center=true);

        // Bore
        cylinder(d=bore_d, h=pulley_width+hub_thickness+4, center=true);
    }
}

pulley_body();