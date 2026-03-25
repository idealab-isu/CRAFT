$fn=96;

outer_d = 80;
thickness = 10;

rim_thick_rad = 10;

hub_d = 30;
hub_h = 6;

hex_flat = 12;
hex_h = thickness + hub_h + 2;

post_d = 14;
post_h = 12;

cutout_count = 4;
cutout_r = outer_d/2 - rim_thick_rad/2;
cutout_len = 22;
cutout_w = 10;
cutout_h = thickness + 2;
cutout_round = 4;

module rounded_slot_2d(len, w, r){
    rr = min(r, w/2, len/2);
    hull(){
        translate([ len/2-rr, 0]) circle(r=rr);
        translate([-len/2+rr, 0]) circle(r=rr);
    }
    offset(delta=(w/2-rr)) children();
}

module rounded_rect_2d(len, w, r){
    rr = min(r, w/2, len/2);
    hull(){
        translate([ len/2-rr,  w/2-rr]) circle(r=rr);
        translate([-len/2+rr,  w/2-rr]) circle(r=rr);
        translate([ len/2-rr, -w/2+rr]) circle(r=rr);
        translate([-len/2+rr, -w/2+rr]) circle(r=rr);
    }
}

module curved_cutout(r_center, len, w, h, roundr){
    translate([r_center,0,0])
        rotate([0,0,90])
            linear_extrude(height=h, center=true)
                rounded_rect_2d(len, w, roundr);
}

module hex_prism(flat, h){
    r = flat / sqrt(3);
    cylinder(h=h, r=r, center=true, $fn=6);
}

module disk_with_rim(){
    union(){
        cylinder(h=thickness, d=outer_d, center=true);
        cylinder(h=thickness, d=outer_d, center=true);
    }
}

module hub(){
    translate([0,0,thickness/2 + hub_h/2])
        cylinder(h=hub_h, d=hub_d, center=true);
}

module post(){
    translate([0,0,-thickness/2 - post_h/2])
        cylinder(h=post_h, d=post_d, center=true);
}

difference(){
    union(){
        cylinder(h=thickness, d=outer_d, center=true);
        hub();
        post();
    }

    for(i=[0:cutout_count-1]){
        rotate([0,0,i*360/cutout_count])
            curved_cutout(cutout_r, cutout_len, cutout_w, cutout_h, cutout_round);
    }

    hex_prism(hex_flat, hex_h);
}