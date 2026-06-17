$fn=64;

L = 55.4;
W = 31.5;
H = 37.5;

bar_t = 8.0;
leg_t = 8.0;

long_leg_h = 29.5;
short_leg_h = 18.0;

taper_h = 6.0;
taper_inset = 2.0;

hex_flat = 8.0;
hex_r = hex_flat / sqrt(3);
hex_hole_z = 0;
hex_hole_x = -L/2 + 14.0;

module hex_prism(r, h){
    cylinder(h=h, r=r, center=true, $fn=6);
}

module tapered_leg(t, w, h, taper_h, inset){
    union(){
        translate([0,0,(h - taper_h)/2])
            cube([t, w, h - taper_h], center=true);
        translate([0,0,h/2 - taper_h/2])
            hull(){
                cube([t, w, 0.01], center=true);
                translate([0,0,taper_h])
                    cube([max(0.01, t - 2*inset), max(0.01, w - 2*inset), 0.01], center=true);
            }
    }
}

module bracket_body(){
    union(){
        cube([L, W, bar_t], center=true);

        translate([-L/2 + leg_t/2, 0, bar_t/2 + long_leg_h/2])
            tapered_leg(leg_t, W, long_leg_h, taper_h, taper_inset);

        translate([ L/2 - leg_t/2, 0, bar_t/2 + short_leg_h/2])
            cube([leg_t, W, short_leg_h], center=true);
    }
}

difference(){
    bracket_body();
    translate([hex_hole_x, 0, hex_hole_z])
        rotate([90,0,0])
            hex_prism(hex_r, W + 2);
}