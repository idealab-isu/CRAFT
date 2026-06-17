$fn=96;

// Bi-metal saw blade (sheet model)
blade_len = 300;
blade_w   = 25;
blade_t   = 0.9;

tooth_pitch = 3.0;      // mm per tooth
tooth_h     = 2.2;      // tooth height beyond blade edge
tooth_tip_w = 0.35;     // tip width along length
tooth_root_w= 1.6;      // root width along length
set_ratio   = 0.35;     // alternating tooth set as fraction of thickness

hole_d = 6.5;
hole_margin = 18;

bimetal_edge_w = 3.0;   // hardened edge strip width (visual)
bimetal_edge_t = 0.15;  // slight thickness bump (visual)

module rounded_rect_2d(L, W, r){
    r2 = min(r, min(L,W)/2);
    hull(){
        translate([ r2,  r2]) circle(r=r2);
        translate([L-r2,  r2]) circle(r=r2);
        translate([ r2, W-r2]) circle(r=r2);
        translate([L-r2, W-r2]) circle(r=r2);
    }
}

module blade_body_2d(){
    difference(){
        rounded_rect_2d(blade_len, blade_w, r=2.0);

        // mounting holes near one end
        translate([hole_margin, blade_w/2]) circle(d=hole_d);
        translate([hole_margin+18, blade_w/2]) circle(d=hole_d*0.85);

        // slight end notch
        translate([6, blade_w/2]) rotate(90) rounded_rect_2d(10, 8, r=1.5);
    }
}

module tooth_2d(root_w, tip_w, h){
    // Tooth points downward from y=0 to y=-h
    polygon(points=[
        [-root_w/2, 0],
        [ root_w/2, 0],
        [ tip_w/2, -h],
        [-tip_w/2, -h]
    ]);
}

module teeth_3d(){
    n = floor(blade_len/tooth_pitch);
    for(i=[0:n-1]){
        x = (i+0.5)*tooth_pitch;
        // alternate set left/right
        zoff = ((i%2)==0 ? 1 : -1) * (blade_t*set_ratio);
        translate([x, 0, zoff])
            linear_extrude(height=blade_t, center=true, convexity=5)
                tooth_2d(tooth_root_w, tooth_tip_w, tooth_h);
    }
}

module blade_3d(){
    // Base blade sheet
    color([0.75,0.75,0.78])
    linear_extrude(height=blade_t, center=true, convexity=10)
        blade_body_2d();

    // Teeth along one long edge (y=0 edge)
    // Place blade so toothed edge is at y=0 by shifting body up
    // We'll render by translating body and teeth together in an assembly.
}

module assembly(){
    // Shift blade body so toothed edge aligns at y=0
    translate([0, tooth_h + 0.01, 0]){
        // Blade body
        color([0.72,0.72,0.75])
        linear_extrude(height=blade_t, center=true, convexity=10)
            blade_body_2d();

        // Bi-metal hardened edge strip (visual accent)
        color([0.55,0.55,0.58])
        translate([0, 0, 0])
            linear_extrude(height=blade_t + bimetal_edge_t, center=true, convexity=5)
                intersection(){
                    blade_body_2d();
                    translate([0, 0]) square([blade_len, bimetal_edge_w], center=false);
                }

        // Teeth
        color([0.60,0.60,0.63])
        translate([0, 0, 0])
            teeth_3d();
    }
}

assembly();