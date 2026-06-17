$fn=96;

shaft_d = 10.0;
base_x = 67.0;
base_y = 53.0;

base_th = 10.0;

pedestal_x = 44.0;
pedestal_y = 34.0;
pedestal_h = 22.0;

cap_h = 18.0;
cap_r = 16.0;

bore_clear = 0.3;
bore_d = shaft_d + bore_clear;

mount_hole_d = 8.5;
mount_hole_head_d = 14.0;
mount_hole_head_depth = 3.0;

mount_x_spacing = 50.0;
mount_y_offset = 0.0;

fillet_r = 3.0;

module rounded_block(size=[10,10,10], r=2, center=true){
    x=size[0]; y=size[1]; z=size[2];
    rr = min(r, x/2, y/2, z/2);
    minkowski(){
        cube([x-2*rr, y-2*rr, z-2*rr], center=center);
        sphere(r=rr);
    }
}

module counterbore_hole(th, d_through, d_cb, cb_depth){
    union(){
        cylinder(h=th+0.2, d=d_through, center=false);
        translate([0,0,th-cb_depth]) cylinder(h=cb_depth+0.3, d=d_cb, center=false);
    }
}

module mount_holes(){
    for (sx=[-1,1]){
        translate([sx*mount_x_spacing/2, mount_y_offset, 0])
            counterbore_hole(base_th, mount_hole_d, mount_hole_head_d, mount_hole_head_depth);
    }
}

module pillow_block(){
    difference(){
        union(){
            rounded_block([base_x, base_y, base_th], r=fillet_r, center=true);

            translate([0,0,base_th/2 + pedestal_h/2])
                rounded_block([pedestal_x, pedestal_y, pedestal_h], r=fillet_r, center=true);

            translate([0,0,base_th + pedestal_h])
                rotate([90,0,0])
                    cylinder(h=pedestal_y, r=cap_r, center=true);
        }

        translate([0,0,base_th + pedestal_h])
            rotate([90,0,0])
                cylinder(h=base_y+2, d=bore_d, center=true);

        translate([0,0,-base_th/2-0.1])
            mount_holes();

        translate([0,0,base_th + pedestal_h])
            rotate([90,0,0])
                cylinder(h=pedestal_y+0.6, r=cap_r-3.0, center=true);
    }
}

pillow_block();