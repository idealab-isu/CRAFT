$fn=16;

rod_d = 0.08;
rod_h = 0.20;

hole_d = 0.02;
hole_offset_from_end = 0.03;

module rod_body(d, h){
    cylinder(d=d, h=h, center=true);
}

module cross_hole(d, len){
    rotate([90,0,0]) cylinder(d=d, h=len, center=true, $fn=24);
}

difference(){
    rod_body(rod_d, rod_h);
    translate([0,0, rod_h/2 - hole_offset_from_end])
        cross_hole(hole_d, rod_d*1.6);
}