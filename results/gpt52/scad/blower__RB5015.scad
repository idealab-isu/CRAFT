$fn=96;

fan_x = 51.3;
fan_y = 51.0;
fan_z = 15.0;

wall = 1.6;
base_th = 1.6;
top_th = 1.2;

inlet_d = 24.0;
inlet_rim = 1.2;

outlet_w = 16.0;
outlet_h = 9.0;
outlet_len = 10.0;

impeller_d = 38.0;
impeller_h = 11.0;
hub_d = 10.0;
hub_h = 11.0;
shaft_d = 3.0;

blade_count = 11;
blade_th = 1.2;
blade_height = 10.0;
blade_r_in = hub_d/2 + 1.0;
blade_r_out = impeller_d/2 - 1.2;
blade_twist = 28;

module rounded_box(x,y,z,r){
    hull(){
        for (sx=[-1,1], sy=[-1,1], sz=[-1,1])
            translate([sx*(x/2-r), sy*(y/2-r), sz*(z/2-r)]) sphere(r=r);
    }
}

module outlet_duct(){
    translate([fan_x/2 - wall/2, 0, -fan_z/2 + base_th + outlet_h/2 + 1.0])
        cube([outlet_len, outlet_w, outlet_h], center=true);
}

module housing(){
    difference(){
        rounded_box(fan_x, fan_y, fan_z, 2.2);

        translate([0,0,-fan_z/2 + base_th + (fan_z-base_th-top_th)/2])
            rounded_box(fan_x-2*wall, fan_y-2*wall, fan_z-base_th-top_th, 1.6);

        translate([0,0, fan_z/2 - top_th - 0.01])
            cylinder(h=top_th+0.2, d=inlet_d, center=false);

        translate([0,0, fan_z/2 - top_th - 0.01])
            cylinder(h=top_th+0.2, d=inlet_d + 2*inlet_rim, center=false);

        outlet_duct();
    }
}

module blade(){
    rmid = (blade_r_in + blade_r_out)/2;
    len = blade_r_out - blade_r_in;
    translate([rmid,0,-fan_z/2 + base_th + blade_height/2])
        rotate([0,0,blade_twist])
            cube([len, blade_th, blade_height], center=true);
}

module impeller(){
    union(){
        translate([0,0,-fan_z/2 + base_th + impeller_h/2])
            difference(){
                cylinder(h=impeller_h, d=impeller_d, center=true);
                cylinder(h=impeller_h+0.4, d=impeller_d-2*blade_th-2.0, center=true);
            }

        translate([0,0,-fan_z/2 + base_th + hub_h/2])
            cylinder(h=hub_h, d=hub_d, center=true);

        translate([0,0,-fan_z/2 + base_th + hub_h/2])
            difference(){
                cylinder(h=hub_h+0.2, d=hub_d-1.0, center=true);
                cylinder(h=hub_h+0.6, d=shaft_d, center=true);
            }

        for(i=[0:blade_count-1]){
            rotate([0,0,i*360/blade_count])
                blade();
        }
    }
}

module mounting_bosses(){
    boss_d = 5.6;
    hole_d = 3.2;
    inset = 4.2;
    z0 = -fan_z/2 + base_th/2;
    for (sx=[-1,1], sy=[-1,1]){
        translate([sx*(fan_x/2 - inset), sy*(fan_y/2 - inset), z0])
            difference(){
                cylinder(h=base_th+2.0, d=boss_d, center=true);
                cylinder(h=base_th+2.6, d=hole_d, center=true);
            }
    }
}

module blower_fan(){
    union(){
        housing();
        mounting_bosses();
        impeller();
    }
}

blower_fan();