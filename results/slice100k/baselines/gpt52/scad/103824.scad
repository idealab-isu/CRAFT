$fn=64;

bbox_x = 22.1;
bbox_y = 24.3;
bbox_z = 79.0;

wall = 2.2;
outer_r = 10.2;
inner_r = outer_r - wall;

channel_depth = bbox_y;
outer_y = channel_depth;
inner_y = channel_depth - wall;

tab_th = 1.2;
tab_len = 3.0;
tab_h = 10.0;

boss_r = 3.2;
boss_hole_r = 1.8;
boss_len = 4.2;

boss_z1 = 18.0;
boss_z2 = 61.0;

module u_shell(){
    difference(){
        union(){
            translate([0,0,0])
                linear_extrude(height=bbox_z, center=true, convexity=10)
                    difference(){
                        offset(r=outer_r) square([bbox_x-2*outer_r, outer_y-2*outer_r], center=true);
                        offset(r=inner_r) square([bbox_x-2*inner_r, inner_y-2*inner_r], center=true);
                    }

            translate([0, (outer_y/2 - tab_th/2), 0])
                cube([bbox_x, tab_th, tab_h], center=true);

            translate([0, (outer_y/2 + tab_len/2), 0])
                cube([bbox_x-2.0, tab_len, tab_th], center=true);
        }

        translate([0, (outer_y/2 + 0.01), 0])
            cube([bbox_x+2, outer_y, bbox_z+2], center=true);
    }
}

module boss_pair(zpos){
    for (sx=[-1,1]){
        translate([sx*(bbox_x/2 - wall - boss_len/2), 0, zpos - bbox_z/2])
            rotate([0,90,0])
                difference(){
                    cylinder(h=boss_len, r=boss_r, center=true);
                    cylinder(h=boss_len+0.6, r=boss_hole_r, center=true);
                }
    }
}

module clip(){
    difference(){
        union(){
            u_shell();
            boss_pair(boss_z1);
            boss_pair(boss_z2);
        }

        translate([0,0,0])
            linear_extrude(height=bbox_z+2, center=true, convexity=10)
                offset(r=inner_r)
                    square([bbox_x-2*inner_r, inner_y-2*inner_r], center=true);
    }
}

clip();