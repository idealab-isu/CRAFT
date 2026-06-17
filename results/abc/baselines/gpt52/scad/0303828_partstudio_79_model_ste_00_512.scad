$fn=64;

web_len = 80;
web_w   = 14;
web_t   = 4;

flange_len = 28;
flange_w   = 20;
flange_t   = 4;

hole_d = 4;
hole_edge_offset = 6;

lug_len = 10;
lug_w   = 6;
lug_h   = 2;
lug_side_offset = 0;

module obround2d(L, W){
    r = W/2;
    hull(){
        translate([-(L/2 - r), 0]) circle(r=r);
        translate([ (L/2 - r), 0]) circle(r=r);
    }
}

module flange(){
    difference(){
        union(){
            linear_extrude(height=flange_t, center=true)
                obround2d(flange_len, flange_w);

            translate([0, (flange_w/2 + lug_w/2 + lug_side_offset), (flange_t/2 + lug_h/2)])
                cube([lug_len, lug_w, lug_h], center=true);
        }

        translate([flange_len/2 - hole_edge_offset, 0, 0])
            cylinder(h=flange_t + lug_h + 2, d=hole_d, center=true);
    }
}

module bracket(){
    union(){
        cube([web_len, web_w, web_t], center=true);

        translate([ web_len/2 + flange_len/2, 0, 0]) flange();
        translate([-(web_len/2 + flange_len/2), 0, 0]) rotate([0,0,180]) flange();
    }
}

bracket();