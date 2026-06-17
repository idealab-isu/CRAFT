$fn=96;

bbox_x = 22.1;
bbox_y = 24.3;
bbox_z = 79.0;

wall = 3.0;
inner_x = bbox_x - 2*wall;
inner_y = bbox_y - 2*wall;

outer_r = 6.0;
inner_r = max(0.01, outer_r - wall);

mouth_depth = 10.0;

hole_d = 5.2;
hole_z = bbox_z*0.52;

tab_len = 6.0;
tab_thk = 2.2;
tab_drop = 2.0;

module rounded_box(size=[10,10,10], r=2.0){
    x=size[0]; y=size[1]; z=size[2];
    r2 = min(r, x/2, y/2);
    linear_extrude(height=z, center=true)
        offset(r=r2)
            square([x-2*r2, y-2*r2], center=true);
}

module u_body(){
    difference(){
        rounded_box([bbox_x, bbox_y, bbox_z], r=outer_r);

        // Inner channel (open at front by mouth cut)
        translate([0,0,0])
            linear_extrude(height=bbox_z, center=true)
                offset(r=inner_r)
                    square([inner_x-2*inner_r, inner_y-2*inner_r], center=true);

        // Open mouth at front (+Y)
        translate([0, (bbox_y/2 - mouth_depth/2), 0])
            cube([bbox_x+2, mouth_depth+0.2, bbox_z+2], center=true);

        // Side through-holes (one per side wall)
        translate([0,0,hole_z - bbox_z/2])
            rotate([0,90,0])
                cylinder(d=hole_d, h=bbox_x+4, center=true);
    }
}

module tabs(){
    // Two small lips at top-front corners
    for (sx=[-1,1]){
        translate([sx*(bbox_x/2 - tab_thk/2), bbox_y/2 - tab_len/2, bbox_z/2 - tab_drop - tab_thk/2])
            rounded_box([tab_thk, tab_len, tab_thk], r=min(0.8, tab_thk/2));
    }
}

union(){
    u_body();
    tabs();
}