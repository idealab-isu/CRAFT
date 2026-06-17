$fn=128;

plate_od = 100;
thickness = 6;

rim_od = 100;
rim_id = 70;
rim_extra = 2;

recess_depth = 2;

bolt_circle_d = 50;
hole_count = 5;

oct_flat_d = 12;
oct_h = thickness + 2;

center_square = 6;

module oct_hole(flat_d, h){
    r = flat_d/(2*cos(180/8));
    cylinder(h=h, r=r, $fn=8);
}

module bolt_pattern(){
    for(i=[0:hole_count-1]){
        ang = 360/hole_count*i;
        translate([bolt_circle_d/2*cos(ang), bolt_circle_d/2*sin(ang), 0])
            oct_hole(oct_flat_d, oct_h);
    }
}

module recessed_plate(){
    difference(){
        union(){
            cylinder(h=thickness, d=plate_od);
            translate([0,0,0]) cylinder(h=thickness+rim_extra, d=rim_od);
        }
        translate([0,0,thickness-recess_depth])
            cylinder(h=recess_depth+0.2, d=rim_id);
    }
}

difference(){
    recessed_plate();
    translate([0,0,-1]) bolt_pattern();
    translate([0,0,-1]) cube([center_square, center_square, thickness+2], center=true);
}