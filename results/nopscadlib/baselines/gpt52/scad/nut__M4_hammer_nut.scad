$fn=64;

screw_d = 4.0;
across_flats = 6.0;
thickness = 3.25;

clearance_d = 4.3;
hex_af = across_flats;
hex_r = hex_af / sqrt(3);

slot_width = 8.0;
slot_length = 12.0;
slot_height = thickness;

chamfer = 0.4;

module hex_prism(af, h){
    r = af / sqrt(3);
    cylinder(h=h, r=r, center=true, $fn=6);
}

module tslot_nut_body(){
    union(){
        cube([slot_length, slot_width, slot_height], center=true);
        translate([0, 0, slot_height/2 - chamfer/2])
            cube([slot_length-0.6, slot_width-0.6, chamfer], center=true);
        translate([0, 0, -slot_height/2 + chamfer/2])
            cube([slot_length-0.6, slot_width-0.6, chamfer], center=true);
    }
}

module tslot_nut(){
    difference(){
        tslot_nut_body();
        cylinder(h=thickness+1, d=clearance_d, center=true, $fn=64);
        translate([0,0,0.2])
            hex_prism(hex_af+0.2, thickness+1);
    }
}

tslot_nut();