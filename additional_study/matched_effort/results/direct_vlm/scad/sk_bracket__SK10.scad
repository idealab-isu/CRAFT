$fn = 96;

// Parameters
rod_d = 10.0;
height = 20.0;

clearance = 0.35;          // rod clearance
bore_d = rod_d + clearance;

wall = 4.0;                // wall thickness around bore
base_th = 6.0;             // base thickness
base_len = 40.0;           // base length (X)
base_wid = 24.0;           // base width (Y)

boss_d = bore_d + 2*wall;  // outer diameter of upright boss

slot_w = 3.2;              // clamp slit width
clamp_screw_d = 5.2;       // M5 clearance
clamp_nut_flat = 8.2;      // M5 nut across flats
clamp_nut_th = 4.2;        // nut thickness
clamp_screw_z = base_th + (height - base_th)*0.65;

mount_hole_d = 5.2;        // M5 clearance
mount_hole_x = 14.0;       // from center along X
mount_hole_y = 8.0;        // from center along Y

fillet_r = 3.0;            // base corner radius

module rounded_rect_2d(l, w, r){
    r2 = min(r, min(l,w)/2);
    hull(){
        for (sx=[-1,1], sy=[-1,1])
            translate([sx*(l/2 - r2), sy*(w/2 - r2)]) circle(r=r2);
    }
}

module hex_prism(af, h){
    // across flats = af
    r = af / (2*cos(30));
    cylinder(r=r, h=h, $fn=6);
}

difference(){
    union(){
        // Base
        linear_extrude(height=base_th)
            rounded_rect_2d(base_len, base_wid, fillet_r);

        // Upright boss
        translate([0,0,0])
            cylinder(d=boss_d, h=height);
    }

    // Rod bore
    translate([0,0,-0.2])
        cylinder(d=bore_d, h=height+0.4);

    // Clamp slit (from front side through to bore)
    translate([-boss_d/2 - 1, -slot_w/2, base_th])
        cube([boss_d + 2, slot_w, height - base_th + 1]);

    // Clamp screw through (Y direction)
    translate([0,0,clamp_screw_z])
        rotate([90,0,0])
            cylinder(d=clamp_screw_d, h=base_wid + 2, center=true);

    // Nut trap on +Y side
    translate([0, base_wid/2 - (clamp_nut_th/2 + 0.6), clamp_screw_z])
        rotate([90,0,0])
            hex_prism(clamp_nut_flat, clamp_nut_th + 1.2);

    // Mounting holes (4)
    for (sx=[-1,1], sy=[-1,1]){
        translate([sx*mount_hole_x, sy*mount_hole_y, -0.2])
            cylinder(d=mount_hole_d, h=base_th+0.4);
    }
}