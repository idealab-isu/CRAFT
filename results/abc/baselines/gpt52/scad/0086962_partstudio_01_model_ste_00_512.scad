$fn=96;

gear_od = 60;
gear_thickness = 18;
body_od = 50;

tooth_count = 24;
tooth_radial = (gear_od - body_od)/2;
tooth_arc_factor = 0.55;

hex_flat = 12;
hex_clearance = 0.25;

module hex_prism(flat, h){
    r = flat / sqrt(3);
    cylinder(h=h, r=r, $fn=6, center=true);
}

module tooth(r_base, radial, h, ang_width){
    r_mid = r_base + radial/2;
    w = 2*r_mid*tan(ang_width/2);
    translate([r_base + radial/2, 0, 0])
        cube([radial, w, h], center=true);
}

module gear_body(){
    union(){
        cylinder(h=gear_thickness, d=body_od, center=true);
        for(i=[0:tooth_count-1]){
            rotate([0,0, i*360/tooth_count])
                tooth(body_od/2, tooth_radial, gear_thickness, (360/tooth_count)*tooth_arc_factor);
        }
    }
}

difference(){
    gear_body();
    hex_prism(hex_flat + hex_clearance, gear_thickness + 2);
}