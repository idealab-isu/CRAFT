$fn=96;

// IEC fused inlet module (old style) - panel cutout 36x27mm
// This model provides a simplified inlet body with flange, fuse drawer bump,
// and two mounting holes. Dimensions are approximate and parametric.

cutout_w = 36.0;
cutout_h = 27.0;

panel_thickness = 3.0;

// Body that passes through panel (slightly undersized for clearance)
body_clearance = 0.3;
body_w = cutout_w - body_clearance;
body_h = cutout_h - body_clearance;
body_depth = 28.0;

// Front flange
flange_w = 44.0;
flange_h = 33.0;
flange_th = 2.5;

// Mounting holes on flange
hole_d = 3.2;
hole_x = 18.0;   // half spacing
hole_y = 12.0;   // half spacing

// Fuse drawer bump (front feature)
fuse_w = 18.0;
fuse_h = 10.0;
fuse_th = 6.0;
fuse_offset_y = 6.0; // upward from center

// Rear terminal block bump
rear_w = 30.0;
rear_h = 22.0;
rear_th = 10.0;

// Helper: rounded rectangle prism
module rrect_prism(w,h,t,r=1.5){
    r2 = min(r, min(w,h)/2);
    linear_extrude(height=t)
        offset(r=r2)
            square([w-2*r2, h-2*r2], center=true);
}

module iec_inlet(){
    difference(){
        union(){
            // Flange (front face at z=0, body extends to +z)
            translate([0,0,0])
                rrect_prism(flange_w, flange_h, flange_th, r=2.0);

            // Main body through panel
            translate([0,0,flange_th])
                rrect_prism(body_w, body_h, body_depth, r=1.2);

            // Fuse drawer bump on front
            translate([0,fuse_offset_y,0])
                rrect_prism(fuse_w, fuse_h, fuse_th, r=1.2);

            // Rear terminal block bump
            translate([0,0,flange_th + body_depth])
                rrect_prism(rear_w, rear_h, rear_th, r=1.2);
        }

        // Mounting holes through flange
        for (sx=[-1,1], sy=[-1,1]){
            translate([sx*hole_x, sy*hole_y, -0.5])
                cylinder(d=hole_d, h=flange_th+1.0);
        }

        // Optional: shallow front recess to suggest inlet opening
        translate([0,-2.0,0.6])
            rrect_prism(28.0, 20.0, 2.0, r=1.5);

        // Optional: fuse drawer notch
        translate([0,fuse_offset_y,0.6])
            rrect_prism(14.0, 6.0, 2.2, r=1.0);
    }
}

// Show with a reference panel and cutout (toggle)
show_panel = false;

if (show_panel){
    difference(){
        translate([0,0,-panel_thickness])
            color([0.8,0.8,0.85])
                cube([80,60,panel_thickness], center=true);
        translate([0,0,-panel_thickness-0.1])
            linear_extrude(height=panel_thickness+0.2)
                square([cutout_w, cutout_h], center=true);
    }
    color([0.1,0.1,0.1]) translate([0,0,0]) iec_inlet();
} else {
    iec_inlet();
}