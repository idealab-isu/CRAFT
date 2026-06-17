$fn=96;

// Centrifugal blower fan 40x40x9.5mm (approximate external geometry)
fan_w = 40.0;
fan_d = 40.0;
fan_h = 9.5;

wall = 1.2;
base_th = 1.2;

outlet_w = 14.0;
outlet_h = 6.0;
outlet_len = 10.0;

corner_r = 3.0;

impeller_r = 14.0;
impeller_h = fan_h - base_th - 1.0;
hub_r = 5.0;
hub_h = impeller_h;

blade_count = 11;
blade_th = 1.0;
blade_len = impeller_r - hub_r - 0.8;
blade_h = impeller_h - 0.6;
blade_twist = 28; // degrees

module rounded_rect_2d(w,d,r){
    r2 = min(r, min(w,d)/2);
    hull(){
        translate([ w/2-r2,  d/2-r2]) circle(r=r2);
        translate([-w/2+r2,  d/2-r2]) circle(r=r2);
        translate([ w/2-r2, -d/2+r2]) circle(r=r2);
        translate([-w/2+r2, -d/2+r2]) circle(r=r2);
    }
}

module shell_body(){
    // Outer housing
    difference(){
        union(){
            // main block
            linear_extrude(height=fan_h)
                rounded_rect_2d(fan_w, fan_d, corner_r);

            // outlet duct (side)
            translate([fan_w/2, 0, fan_h - outlet_h])
                cube([outlet_len, outlet_w, outlet_h], center=true);
        }

        // inner cavity (leave walls + base)
        translate([0,0,base_th])
            linear_extrude(height=fan_h-base_th+0.01)
                rounded_rect_2d(fan_w-2*wall, fan_d-2*wall, max(0,corner_r-wall));

        // carve outlet opening through wall into cavity
        translate([fan_w/2 - wall/2, 0, fan_h - outlet_h])
            cube([wall+0.6, outlet_w-2.0, outlet_h-1.0], center=true);

        // inlet opening on top (round)
        translate([0,0,fan_h-0.01])
            cylinder(h=wall+0.2, r=impeller_r+2.0, center=false);

        // screw holes (typical 32mm spacing)
        hole_r = 1.6;
        spacing = 32.0;
        for (sx=[-1,1], sy=[-1,1]){
            translate([sx*spacing/2, sy*spacing/2, -0.1])
                cylinder(h=fan_h+0.2, r=hole_r, center=false);
        }
    }
}

module impeller(){
    // Positioned inside cavity, centered
    translate([0,0,base_th+0.4]){
        union(){
            // hub
            cylinder(h=hub_h, r=hub_r);

            // backplate
            cylinder(h=0.8, r=impeller_r);

            // blades (curved via twist)
            for(i=[0:blade_count-1]){
                rotate([0,0,i*360/blade_count]){
                    translate([hub_r+0.4, -blade_th/2, 0.8])
                        linear_extrude(height=blade_h, twist=blade_twist, slices=24)
                            square([blade_len, blade_th], center=false);
                }
            }
        }
    }
}

module fan(){
    color([0.15,0.15,0.15]) shell_body();
    color([0.25,0.25,0.25]) impeller();
}

fan();