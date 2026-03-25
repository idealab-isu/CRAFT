$fn=64;

W = 22.1;      // X overall
D = 24.3;      // Y overall
H = 79.0;      // Z overall

wall = 3.0;    // wall thickness
backR = 11.0;  // outer back rounding radius (in XY)
innerR = 7.0;  // inner back rounding radius (in XY)

channelW = W - 2*wall;     // inner width (X)
channelD = D - wall;       // inner depth (Y), open at front

hole_d = 4.2;
hole_z = H - 18.0;         // near upper region
hole_y = 0.0;              // centered in depth

lip_h = 3.0;
lip_t = 1.8;
lip_inset = 0.6;

fillet_r = 2.2;

module rounded_rect_2d(w, d, r){
    r2 = min(r, min(w,d)/2);
    hull(){
        translate([ w/2 - r2,  d/2 - r2]) circle(r=r2);
        translate([-w/2 + r2,  d/2 - r2]) circle(r=r2);
        translate([ w/2 - r2, -d/2 + r2]) circle(r=r2);
        translate([-w/2 + r2, -d/2 + r2]) circle(r=r2);
    }
}

module u_body(){
    difference(){
        linear_extrude(height=H, center=true, convexity=10)
            rounded_rect_2d(W, D, backR);

        translate([0, wall/2, 0])
            linear_extrude(height=H + 0.6, center=true, convexity=10)
                rounded_rect_2d(channelW, channelD, innerR);

        translate([0, D/2 + 0.1, 0])
            cube([W + 2, D, H + 2], center=true);

        translate([0, hole_y, hole_z - H/2])
            rotate([0,90,0])
                cylinder(d=hole_d, h=W + 2, center=true);

        translate([0, hole_y, -(hole_z - H/2)])
            rotate([0,90,0])
                cylinder(d=hole_d, h=W + 2, center=true);
    }
}

module lips(){
    y_front = D/2 - lip_t/2;
    z0 = -H/2 + lip_h/2;

    union(){
        translate([ (W/2 - wall/2), y_front - lip_inset, z0])
            cube([wall, lip_t, lip_h], center=true);

        translate([-(W/2 - wall/2), y_front - lip_inset, z0])
            cube([wall, lip_t, lip_h], center=true);
    }
}

module internal_fillet(){
    // Add a smooth fillet-like ridge along the inner bottom corners using hull of spheres
    // (kept subtle to avoid changing bounding box)
    z_bot = -H/2 + wall + fillet_r;
    y_in = -D/2 + wall + fillet_r;
    x_in = channelW/2 - fillet_r;

    hull(){
        translate([ x_in, y_in, z_bot]) sphere(r=fillet_r);
        translate([-x_in, y_in, z_bot]) sphere(r=fillet_r);
        translate([ x_in, y_in, -z_bot]) sphere(r=fillet_r);
        translate([-x_in, y_in, -z_bot]) sphere(r=fillet_r);
    }
}

union(){
    u_body();
    lips();
    internal_fillet();
}