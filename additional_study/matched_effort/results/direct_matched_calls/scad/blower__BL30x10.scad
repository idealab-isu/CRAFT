$fn=96;

// Centrifugal blower fan 30.0 x 30.0 x 10.1 mm (approximate external geometry)
size_xy = 30.0;
height  = 10.1;

wall = 1.2;
base_th = 1.2;

corner_r = 3.0;

outlet_w = 12.0;
outlet_h = 6.0;
outlet_len = 8.0;

top_inlet_d = 16.0;
top_inlet_rim = 1.2;

screw_hole_d = 2.6;
screw_boss_d = 5.6;
screw_offset = 4.0;

impeller_clearance = 0.6;
impeller_th = height - base_th - 0.8;
impeller_d = 22.0;
hub_d = 8.0;
blade_count = 11;
blade_th = 0.9;

module rounded_box(x,y,z,r){
    linear_extrude(height=z)
        offset(r=r)
            square([x-2*r, y-2*r], center=true);
}

module shell_body(){
    difference(){
        // Outer housing
        translate([0,0,height/2])
            rounded_box(size_xy, size_xy, height, corner_r);

        // Inner cavity (open at top, with base thickness)
        translate([0,0,(base_th + (height-base_th))/2])
            rounded_box(size_xy-2*wall, size_xy-2*wall, height-base_th, max(0.1, corner_r-wall));

        // Outlet opening (side)
        translate([size_xy/2 - wall/2, 0, base_th + outlet_h/2 + 1.0])
            rotate([0,90,0])
                cube([outlet_h, outlet_w, wall+0.8], center=true);

        // Outlet duct hollow (extends out)
        translate([size_xy/2 + outlet_len/2, 0, base_th + outlet_h/2 + 1.0])
            rotate([0,90,0])
                cube([outlet_h-2*1.0, outlet_w-2*1.0, outlet_len+0.2], center=true);

        // Top inlet hole
        translate([0,0,height-0.6])
            cylinder(h=2.0, d=top_inlet_d, center=true);

        // Screw holes
        for (sx=[-1,1], sy=[-1,1]){
            translate([sx*(size_xy/2 - screw_offset), sy*(size_xy/2 - screw_offset), height/2])
                cylinder(h=height+1, d=screw_hole_d, center=true);
        }
    }

    // Outlet duct outer
    translate([size_xy/2 + outlet_len/2, 0, base_th + outlet_h/2 + 1.0])
        rotate([0,90,0])
            difference(){
                cube([outlet_h, outlet_w, outlet_len], center=true);
                cube([outlet_h-2*1.0, outlet_w-2*1.0, outlet_len+0.2], center=true);
            }

    // Screw bosses (inside corners)
    for (sx=[-1,1], sy=[-1,1]){
        translate([sx*(size_xy/2 - screw_offset), sy*(size_xy/2 - screw_offset), base_th + (height-base_th)/2])
            difference(){
                cylinder(h=height-base_th-0.2, d=screw_boss_d, center=true);
                cylinder(h=height+1, d=screw_hole_d, center=true);
            }
    }

    // Top inlet rim
    translate([0,0,height-0.6])
        difference(){
            cylinder(h=1.2, d=top_inlet_d + 2*top_inlet_rim, center=true);
            cylinder(h=1.4, d=top_inlet_d, center=true);
        }
}

module impeller(){
    z0 = base_th + impeller_clearance;
    zc = z0 + impeller_th/2;

    translate([0,0,zc])
    union(){
        // Hub
        cylinder(h=impeller_th, d=hub_d, center=true);

        // Backplate
        cylinder(h=1.0, d=impeller_d, center=true);

        // Blades (simple radial vanes with slight forward sweep)
        for(i=[0:blade_count-1]){
            ang = i*360/blade_count;
            rotate([0,0,ang])
                translate([impeller_d*0.22, 0, 0])
                    rotate([0,0,18])
                        cube([impeller_d*0.32, blade_th, impeller_th-1.2], center=true);
        }
    }
}

module blower_fan(){
    color([0.15,0.15,0.15]) shell_body();
    color([0.25,0.25,0.25]) impeller();
}

blower_fan();