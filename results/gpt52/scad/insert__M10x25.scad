$fn=128;

od = 25.0;
len = 18.5;
screw_d = 10.0;

wall = 3.0;
id = screw_d + 0.6;

knurl_depth = 0.9;
knurl_count = 36;

lead_in = 1.2;
chamfer = 0.8;

module knurl_ridges(outer_d, height, depth, count){
    for(i=[0:count-1]){
        rotate([0,0, i*360/count])
            translate([outer_d/2 - depth/2, 0, 0])
                cube([depth, 1.2, height], center=true);
    }
}

module insert_body(){
    difference(){
        union(){
            cylinder(d=od, h=len, center=true);
            knurl_ridges(od, len-2*lead_in, knurl_depth, knurl_count);
        }
        translate([0,0,0])
            cylinder(d=id, h=len+2, center=true);
        translate([0,0,len/2 - lead_in/2])
            cylinder(d1=id+2.0, d2=id, h=lead_in+0.01, center=true);
        translate([0,0,-len/2 + lead_in/2])
            cylinder(d1=id, d2=id+2.0, h=lead_in+0.01, center=true);
    }
}

module end_chamfers(){
    difference(){
        cylinder(d=od+0.01, h=len+0.02, center=true);
        translate([0,0,len/2 - chamfer/2])
            cylinder(d1=od+2*chamfer, d2=od-0.01, h=chamfer+0.02, center=true);
        translate([0,0,-len/2 + chamfer/2])
            cylinder(d1=od-0.01, d2=od+2*chamfer, h=chamfer+0.02, center=true);
    }
}

intersection(){
    insert_body();
    end_chamfers();
}