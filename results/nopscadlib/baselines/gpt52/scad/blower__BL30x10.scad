$fn=96;

size_xy = 30.0;
height_z = 10.1;

wall = 1.2;
base_th = 1.2;

inlet_d = 14.0;
inlet_r = inlet_d/2;

outlet_w = 8.0;
outlet_h = 6.0;

scroll_clear = 0.8;

hub_d = 8.0;
hub_h = 6.0;

shaft_d = 3.0;

impeller_od = 22.0;
impeller_h = 7.0;
blade_count = 11;
blade_th = 0.9;
blade_len = (impeller_od/2 - hub_d/2) - 0.6;
blade_twist = 28;

module rounded_box_xy(x,y,z,r){
    hull(){
        for (sx=[-1,1], sy=[-1,1]){
            translate([sx*(x/2-r), sy*(y/2-r), 0])
                cylinder(r=r, h=z);
        }
    }
}

module housing_outer(){
    rounded_box_xy(size_xy, size_xy, height_z, 2.2);
}

module housing_inner(){
    inner_x = size_xy - 2*wall;
    inner_y = size_xy - 2*wall;
    inner_z = height_z - base_th;
    translate([0,0,base_th])
        rounded_box_xy(inner_x, inner_y, inner_z, 1.6);
}

module outlet_cut(){
    // Outlet on +X side
    translate([size_xy/2 - wall/2, 0, base_th + outlet_h/2 + 1.0])
        cube([wall+2.0, outlet_w, outlet_h], center=true);
}

module inlet_cut(){
    // Inlet on top face, centered
    translate([0,0,height_z-0.01])
        cylinder(d=inlet_d, h=base_th+0.5);
}

module scroll_cavity(){
    // Approximate volute/scroll cavity as an offset ring sector
    z0 = base_th;
    h = height_z - base_th - 0.8;
    r_in = hub_d/2 + 1.2;
    r_out = impeller_od/2 + scroll_clear + 2.0;
    // Create a "C" shaped cavity by subtracting a block near outlet to open it
    difference(){
        translate([0,0,z0])
            difference(){
                cylinder(r=r_out, h=h);
                translate([0,0,-0.1]) cylinder(r=r_in, h=h+0.2);
            }
        // Keep cavity within housing bounds
        translate([0,0,z0-0.2])
            cube([size_xy-2*wall, size_xy-2*wall, h+0.4], center=true);
        // Leave material near outlet to form tongue; remove cavity there
        translate([size_xy/2 - wall - 2.0, 0, z0 + h/2])
            cube([10.0, 14.0, h+1.0], center=true);
    }
}

module impeller_blade(){
    // A thin radial blade with slight backward sweep via rotation
    translate([hub_d/2 + blade_len/2, 0, 0])
        cube([blade_len, blade_th, impeller_h], center=true);
}

module impeller(){
    union(){
        // Hub
        cylinder(d=hub_d, h=hub_h);
        // Backplate
        cylinder(d=impeller_od-1.0, h=1.0);
        // Blades
        for(i=[0:blade_count-1]){
            rotate([0,0,i*360/blade_count])
                rotate([0,0,-blade_twist])
                    translate([0,0,impeller_h/2])
                        impeller_blade();
        }
        // Shroud ring (partial)
        translate([0,0,impeller_h-1.0])
            difference(){
                cylinder(d=impeller_od, h=1.0);
                cylinder(d=impeller_od-2.2, h=1.2);
            }
    }
}

module blower(){
    difference(){
        union(){
            // Housing shell
            difference(){
                housing_outer();
                housing_inner();
                // Inlet hole
                inlet_cut();
                // Outlet opening
                outlet_cut();
                // Scroll cavity
                scroll_cavity();
            }
            // Impeller inside
            translate([0,0,base_th+0.6])
                impeller();
        }
        // Shaft hole through hub and base
        translate([0,0,-0.2])
            cylinder(d=shaft_d, h=height_z+0.4);
    }
}

blower();