$fn=96;

fan_w = 40.0;
fan_d = 40.0;
fan_h = 9.5;

wall = 1.2;
base = 1.2;

inlet_d = 18.0;
inlet_r = inlet_d/2;

outlet_w = 12.0;
outlet_h = 6.0;

scroll_clear = 0.8;

hub_d = 10.0;
hub_h = 7.0;

impeller_d = 30.0;
impeller_r = impeller_d/2;
impeller_h = 7.0;

blade_count = 11;
blade_th = 0.9;
blade_len = 8.5;
blade_h = 6.2;
blade_twist = 28;

module rounded_box(size=[10,10,10], r=1.0, center=true){
    sx=size[0]; sy=size[1]; sz=size[2];
    translate(center ? [0,0,0] : [sx/2, sy/2, sz/2])
    hull(){
        for(x=[-1,1], y=[-1,1], z=[-1,1]){
            translate([x*(sx/2-r), y*(sy/2-r), z*(sz/2-r)])
                sphere(r=r);
        }
    }
}

module housing_shell(){
    difference(){
        rounded_box([fan_w, fan_d, fan_h], r=2.0, center=true);

        // Inner cavity
        translate([0,0, base/2])
            rounded_box([fan_w-2*wall, fan_d-2*wall, fan_h-base], r=1.4, center=true);

        // Inlet hole (top to cavity)
        translate([0,0, fan_h/2 - 0.01])
            cylinder(h=fan_h+0.2, r=inlet_r, center=false);

        // Outlet opening on +X side
        translate([fan_w/2 - wall/2, 0, 0])
            rotate([0,90,0])
                cube([outlet_h, outlet_w, wall+2.0], center=true);

        // Scroll cavity shaping (approximate volute)
        translate([0,0, -fan_h/2 + base + (fan_h-base)/2])
            difference(){
                cylinder(h=fan_h-base+0.2, r=impeller_r+scroll_clear+3.0, center=true);
                cylinder(h=fan_h-base+0.4, r=impeller_r+scroll_clear, center=true);
                // Cut to create volute growth toward outlet
                translate([-(impeller_r+scroll_clear+3.0),0,0])
                    cube([2*(impeller_r+scroll_clear+3.0), 2*(impeller_r+scroll_clear+3.0), fan_h], center=true);
            }
    }
}

module impeller_blade(){
    // A curved blade made by hulling two thin rectangles at different angles
    z0 = -blade_h/2;
    z1 = blade_h/2;
    hull(){
        translate([impeller_r - blade_len, 0, 0])
            rotate([0,0, -blade_twist/2])
                cube([blade_len, blade_th, blade_h], center=true);
        translate([impeller_r - blade_len/2, 0, 0])
            rotate([0,0, blade_twist/2])
                cube([blade_len*0.7, blade_th, blade_h], center=true);
    }
}

module impeller(){
    union(){
        // Hub
        translate([0,0, -fan_h/2 + base + hub_h/2])
            cylinder(h=hub_h, r=hub_d/2, center=true);

        // Backplate
        translate([0,0, -fan_h/2 + base + 0.6])
            cylinder(h=1.2, r=impeller_r-0.6, center=true);

        // Blades
        translate([0,0, -fan_h/2 + base + 1.2 + blade_h/2])
        for(i=[0:blade_count-1]){
            rotate([0,0, i*360/blade_count])
                impeller_blade();
        }

        // Shroud ring (partial)
        translate([0,0, -fan_h/2 + base + 1.2 + blade_h - 0.4])
            difference(){
                cylinder(h=0.8, r=impeller_r, center=true);
                cylinder(h=1.0, r=impeller_r-1.2, center=true);
            }
    }
}

module mounting_posts(){
    post_d = 3.2;
    post_h = fan_h;
    hole_d = 2.2;
    inset = 4.0;
    for(x=[-1,1], y=[-1,1]){
        translate([x*(fan_w/2 - inset), y*(fan_d/2 - inset), 0])
        difference(){
            cylinder(h=post_h, r=post_d/2, center=true);
            cylinder(h=post_h+0.4, r=hole_d/2, center=true);
        }
    }
}

module blower_fan(){
    union(){
        housing_shell();
        // Add internal impeller (visible if rendered as solid; still included)
        impeller();
        // Corner posts integrated
        intersection(){
            rounded_box([fan_w, fan_d, fan_h], r=2.0, center=true);
            mounting_posts();
        }
    }
}

blower_fan();