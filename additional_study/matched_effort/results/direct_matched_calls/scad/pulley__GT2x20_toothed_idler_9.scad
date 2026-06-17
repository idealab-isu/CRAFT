$fn = 180;

// Simple parametric timing pulley approximation (GT2-like tooth form)
// 20 teeth, pitch diameter 12.22mm (given). Tooth profile is an approximation
// suitable for visualization/fit-testing; adjust parameters for your belt standard.

teeth = 20;
pitch_d = 12.22;          // mm (given)
pulley_w = 10;            // mm
bore_d = 5;               // mm

// Tooth geometry (approx)
tooth_height = 0.75;      // radial height above pitch circle (mm)
tooth_root_depth = 0.35;  // radial depth below pitch circle (mm)
tooth_tip_width = 0.70;   // tangential width at tip (mm)
tooth_root_width = 1.20;  // tangential width at root (mm)
tooth_round = 0.20;       // corner rounding radius (mm)

// Derived
pitch_r = pitch_d/2;
outer_r = pitch_r + tooth_height;
root_r  = max(0.1, pitch_r - tooth_root_depth);

module rounded_trapezoid_2d(wb, wt, h, r){
    // 2D trapezoid centered on X, base at y=0, top at y=h
    // then rounded via offset.
    offset(r=r)
        offset(delta=-r)
            polygon(points=[
                [-wb/2, 0],
                [ wb/2, 0],
                [ wt/2, h],
                [-wt/2, h]
            ]);
}

module tooth(){
    // Tooth centered at angle 0, extending radially outward from root_r to outer_r
    // Build in 2D (x tangential, y radial), then rotate into place.
    linear_extrude(height=pulley_w, center=true, convexity=10)
        translate([0, root_r])
            rounded_trapezoid_2d(tooth_root_width, tooth_tip_width, outer_r-root_r, tooth_round);
}

module pulley_body(){
    // Base cylinder up to root radius
    difference(){
        cylinder(r=root_r, h=pulley_w, center=true);
        cylinder(d=bore_d, h=pulley_w+2, center=true);
    }
}

module pulley(){
    union(){
        pulley_body();
        for(i=[0:teeth-1]){
            rotate([0,0, i*360/teeth])
                tooth();
        }
    }
}

pulley();