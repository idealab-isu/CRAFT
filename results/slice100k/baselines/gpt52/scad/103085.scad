$fn=64;

L = 55.4;
W = 31.5;
H = 37.5;

beam_h = 10;
beam_w = W;
beam_l = L;

plate_t = 6;
plate_h = H;
plate_w = W;

leg_t = 6;
leg_h = 18;
leg_w = W;

hex_flat = 10.5;
hex_r = hex_flat / sqrt(3);
hex_h = beam_w + 2;

chamfer_drop = 10;
chamfer_run = 14;

module hex_prism(h, r){
    cylinder(h=h, r=r, $fn=6);
}

module beam(){
    translate([-beam_l/2, -beam_w/2, -beam_h/2])
        cube([beam_l, beam_w, beam_h], center=false);
}

module end_plate(){
    translate([beam_l/2 - plate_t, -plate_w/2, -plate_h/2])
        cube([plate_t, plate_w, plate_h], center=false);
}

module leg(){
    translate([-beam_l/2, -leg_w/2, -beam_h/2])
        cube([leg_t, leg_w, leg_h], center=false);
}

module chamfer_cut(){
    translate([beam_l/2 - plate_t - 1, -plate_w/2 - 1, plate_h/2 - chamfer_drop])
        rotate([0,90,0])
            linear_extrude(height=plate_t + 2)
                polygon(points=[
                    [-1, -1],
                    [plate_w + 2, -1],
                    [plate_w + 2, chamfer_run],
                    [-1, chamfer_run]
                ]);
}

module bracket_solid(){
    union(){
        beam();
        end_plate();
        leg();
    }
}

module bracket(){
    difference(){
        difference(){
            bracket_solid();
            chamfer_cut();
        }
        translate([0, 0, 0])
            rotate([90,0,0])
                hex_prism(h=hex_h, r=hex_r);
    }
}

bracket();