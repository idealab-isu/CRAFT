$fn=96;

od = 5.8;
len = 4.6;
screw_d = 3.0;

wall = 0.6;
id = screw_d + 0.4;

knurl_depth = 0.35;
knurl_count = 24;

lead_in = 0.5;
chamfer = 0.35;

module knurl_ring(z0, z1, r_base, depth, n){
    for(i=[0:n-1]){
        rotate([0,0,360*i/n])
            translate([r_base - depth/2,0,(z0+z1)/2])
                cube([depth, 0.7, (z1-z0)], center=true);
    }
}

module insert_body(){
    r = od/2;
    difference(){
        union(){
            cylinder(h=len, r=r, center=true);
            translate([0,0,len/2 - lead_in/2])
                cylinder(h=lead_in, r1=r-0.25, r2=r, center=true);
            translate([0,0,-len/2 + lead_in/2])
                cylinder(h=lead_in, r1=r, r2=r-0.25, center=true);
        }
        translate([0,0,0])
            cylinder(h=len+0.2, r=id/2, center=true);
        translate([0,0,len/2 - chamfer/2])
            cylinder(h=chamfer, r1=id/2, r2=id/2 + 0.35, center=true);
        translate([0,0,-len/2 + chamfer/2])
            cylinder(h=chamfer, r1=id/2 + 0.35, r2=id/2, center=true);
    }
}

module heat_set_insert(){
    difference(){
        union(){
            insert_body();
            knurl_ring(-len/2 + 0.6, -len/2 + 1.6, od/2, knurl_depth, knurl_count);
            knurl_ring(-0.8, 0.8, od/2, knurl_depth, knurl_count);
            knurl_ring(len/2 - 1.6, len/2 - 0.6, od/2, knurl_depth, knurl_count);
        }
        translate([0,0,0])
            cylinder(h=len+0.4, r=id/2, center=true);
    }
}

heat_set_insert();