$fn=96;

outer_x = 46.2;
outer_y = 40.0;
thickness = 10.0;

outer_r = outer_x/2;
inner_through_d = 28.0;
inner_through_r = inner_through_d/2;

recess_depth = 3.0;
recess_r = 18.0;

lug_count = 10;
lug_radial_len = 2.2;
lug_tangential_w = 4.0;
lug_height = thickness - recess_depth;

module outer_hex_elliptical(h, rx, ry){
    scale([rx, ry, 1])
        cylinder(h=h, r=1, center=true, $fn=6);
}

module lug(i, base_r, radial_len, tang_w, h){
    rotate([0,0, i*360/lug_count])
        translate([base_r - radial_len/2, 0, 0])
            cube([radial_len, tang_w, h], center=true);
}

module lugs(){
    for(i=[0:lug_count-1])
        lug(i, inner_through_r, lug_radial_len, lug_tangential_w, lug_height);
}

module collar(){
    difference(){
        outer_hex_elliptical(thickness, outer_r, outer_y/2);

        cylinder(h=thickness+0.4, r=inner_through_r, center=true, $fn=128);

        translate([0,0, thickness/2 - recess_depth/2])
            cylinder(h=recess_depth+0.2, r=recess_r, center=true, $fn=128);

        translate([0,0, thickness/2 - recess_depth - lug_height/2])
            lugs();
    }
}

collar();