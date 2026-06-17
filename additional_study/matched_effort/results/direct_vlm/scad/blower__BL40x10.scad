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
impeller_h = 7.2;
hub_r = 5.0;
hub_h = 7.2;
shaft_r = 1.6;

blade_count = 11;
blade_th = 1.0;
blade_len = 7.5;
blade_h = 6.6;
blade_twist = 22; // degrees

mount_hole_d = 3.2;
mount_hole_inset = 4.0;

module rounded_box(size=[10,10,10], r=2, center=false){
    x=size[0]; y=size[1]; z=size[2];
    translate(center ? [-x/2,-y/2,-z/2] : [0,0,0])
    linear_extrude(height=z)
        offset(r=r)
            square([x-2*r, y-2*r], center=false);
}

module blower_shell(){
    // Outer body
    difference(){
        rounded_box([fan_w, fan_d, fan_h], r=corner_r, center=false);

        // Internal cavity (main)
        translate([wall, wall, base_th])
            rounded_box([fan_w-2*wall, fan_d-2*wall, fan_h-base_th-wall], r=max(0.1, corner_r-wall), center=false);

        // Outlet cut through side wall
        translate([fan_w - wall - 0.01, (fan_d - outlet_w)/2, fan_h - outlet_h - 1.2])
            cube([wall+outlet_len+0.02, outlet_w, outlet_h], center=false);

        // Mount holes (4 corners)
        for (sx=[-1,1], sy=[-1,1]){
            translate([
                (sx<0)? mount_hole_inset : (fan_w-mount_hole_inset),
                (sy<0)? mount_hole_inset : (fan_d-mount_hole_inset),
                -0.1
            ])
            cylinder(d=mount_hole_d, h=fan_h+0.2);
        }

        // Slight inlet recess on top (visual)
        translate([fan_w/2, fan_d/2, fan_h-0.8])
            cylinder(d=28, h=1.2);
    }

    // Outlet duct (external)
    translate([fan_w, (fan_d - outlet_w)/2, fan_h - outlet_h - 1.2])
    difference(){
        cube([outlet_len, outlet_w, outlet_h], center=false);
        translate([0.8, 0.8, 0.8])
            cube([outlet_len-1.6, outlet_w-1.6, outlet_h-1.6], center=false);
    }
}

module impeller(){
    // Positioned inside cavity
    translate([fan_w/2, fan_d/2, base_th + 0.6]){
        // Hub + shaft
        color([0.15,0.15,0.15])
        union(){
            cylinder(r=hub_r, h=hub_h);
            translate([0,0,hub_h-0.2])
                cylinder(r=shaft_r, h=2.0);
        }

        // Backplate
        color([0.2,0.2,0.2])
        translate([0,0,0])
            cylinder(r=impeller_r, h=1.0);

        // Blades (curved via twist)
        color([0.25,0.25,0.25])
        for(i=[0:blade_count-1]){
            rotate([0,0,i*360/blade_count])
            translate([hub_r+0.6, -blade_th/2, 1.0])
                linear_extrude(height=blade_h, twist=blade_twist, slices=24)
                    square([blade_len, blade_th], center=false);
        }

        // Shroud ring (partial) to suggest centrifugal housing interaction
        color([0.22,0.22,0.22])
        translate([0,0,1.0])
        difference(){
            cylinder(r=impeller_r+0.8, h=blade_h);
            cylinder(r=impeller_r-1.2, h=blade_h+0.01);
        }
    }
}

module top_label(){
    // Simple raised label area
    translate([6, 6, fan_h-0.8])
        linear_extrude(height=0.6)
            offset(r=1.2)
                square([18, 10], center=false);
}

union(){
    color([0.05,0.05,0.05]) blower_shell();
    impeller();
    color([0.08,0.08,0.08]) top_label();
}