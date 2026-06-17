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

impeller_od = 28.0;
impeller_id = 10.0;
impeller_h  = 7.2;
hub_h = 7.2;
hub_od = 12.0;
shaft_hole = 3.0;

blade_count = 11;
blade_th = 0.9;
blade_len = (impeller_od/2 - impeller_id/2) * 0.95;
blade_h = impeller_h * 0.95;
blade_twist = 22; // degrees

module rounded_box_xy(w,d,h,r){
    // Rounded rectangle prism using hull of corner cylinders
    hull(){
        for (sx=[-1,1], sy=[-1,1]){
            translate([sx*(w/2-r), sy*(d/2-r), 0])
                cylinder(h=h, r=r);
        }
    }
}

module shell_body(){
    // Outer housing
    difference(){
        union(){
            // Main body
            rounded_box_xy(fan_w, fan_d, fan_h, corner_r);

            // Outlet duct (side)
            translate([fan_w/2, 0, fan_h - outlet_h - 1.0])
                rotate([0,90,0])
                    rounded_box_xy(outlet_len, outlet_w, outlet_h, 1.2);
        }

        // Inner cavity
        translate([0,0,base_th])
            rounded_box_xy(fan_w-2*wall, fan_d-2*wall, fan_h-base_th-wall, max(0.1, corner_r-wall));

        // Outlet opening through wall into cavity
        translate([fan_w/2 - wall/2, 0, fan_h - outlet_h - 1.0])
            rotate([0,90,0])
                rounded_box_xy(wall+0.6, outlet_w-2.0, outlet_h-1.0, 0.8);

        // Inlet opening on top (circular)
        translate([0,0,fan_h-wall])
            cylinder(h=wall+0.8, r=12.5);

        // Screw holes (typical 32mm spacing)
        hole_spacing = 32.0;
        hole_r = 1.6;
        for (sx=[-1,1], sy=[-1,1]){
            translate([sx*hole_spacing/2, sy*hole_spacing/2, -0.2])
                cylinder(h=fan_h+0.4, r=hole_r);
        }
    }
}

module impeller(){
    // Impeller positioned inside cavity
    translate([0,0,base_th + 0.6]){
        difference(){
            union(){
                // Hub
                cylinder(h=hub_h, r=hub_od/2);

                // Backplate / shroud
                translate([0,0,0])
                    cylinder(h=1.0, r=impeller_od/2);

                // Blades
                for(i=[0:blade_count-1]){
                    ang = i*360/blade_count;
                    rotate([0,0,ang])
                        translate([impeller_id/2 + blade_len/2, 0, 0.8])
                            linear_extrude(height=blade_h, twist=blade_twist, slices=24)
                                square([blade_len, blade_th], center=true);
                }

                // Outer ring (helps blade tips)
                translate([0,0,0.8])
                    difference(){
                        cylinder(h=blade_h, r=impeller_od/2);
                        cylinder(h=blade_h, r=impeller_od/2 - 1.0);
                    }
            }

            // Shaft hole
            translate([0,0,-0.2])
                cylinder(h=hub_h+impeller_h+1.0, r=shaft_hole/2);
        }
    }
}

module simple_motor_boss(){
    // Small motor boss under impeller (inside base thickness)
    translate([0,0,0])
        difference(){
            cylinder(h=base_th+0.6, r=9.0);
            translate([0,0,-0.2]) cylinder(h=base_th+1.2, r=shaft_hole/2);
        }
}

module fan(){
    union(){
        color([0.15,0.15,0.15]) shell_body();
        color([0.85,0.85,0.85]) impeller();
        color([0.6,0.6,0.6]) simple_motor_boss();
    }
}

fan();