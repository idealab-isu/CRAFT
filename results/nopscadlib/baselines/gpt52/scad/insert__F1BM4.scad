$fn=96;

od = 8.2;
len = 6.3;

screw_d = 4.0;
clearance = 0.35;
id = screw_d + clearance;

chamfer = 0.6;
knurl_depth = 0.35;
knurl_count = 24;

module knurled_shell(od, len, depth, n){
    difference(){
        cylinder(d=od, h=len, center=true);
        for(i=[0:n-1]){
            rotate([0,0,360*i/n])
                translate([od/2 - depth/2, 0, 0])
                    cylinder(d=depth, h=len+0.4, center=true, $fn=24);
        }
    }
}

module heat_set_insert(od, len, id){
    difference(){
        union(){
            knurled_shell(od, len, knurl_depth, knurl_count);
            translate([0,0,len/2 - chamfer/2])
                cylinder(d1=od-2*chamfer, d2=od, h=chamfer, center=true);
            translate([0,0,-len/2 + chamfer/2])
                cylinder(d1=od, d2=od-2*chamfer, h=chamfer, center=true);
        }
        cylinder(d=id, h=len+1.0, center=true, $fn=96);
    }
}

heat_set_insert(od, len, id);