$fn=64;

module rounded_rect_2d(w, h, r){
    r2 = min(r, min(w,h)/2);
    hull(){
        translate([ w/2 - r2,  h/2 - r2]) circle(r=r2);
        translate([-w/2 + r2,  h/2 - r2]) circle(r=r2);
        translate([-w/2 + r2, -h/2 + r2]) circle(r=r2);
        translate([ w/2 - r2, -h/2 + r2]) circle(r=r2);
    }
}

module panel_cutout(w=40.0, h=29.0, r=2.0, t=6.0){
    linear_extrude(height=t, center=true)
        rounded_rect_2d(w,h,r);
}

module screw_hole(d=3.2, t=20){
    cylinder(d=d, h=t, center=true);
}

module iec_inlet_module(){
    // Panel cutout volume (for subtracting from a panel)
    panel_cutout(40.0, 29.0, 2.0, 8.0);

    // Add typical mounting holes (for reference/optional subtraction)
    // Centers approximated for common 40x29 IEC filtered inlets
    translate([0,  12.0, 0]) screw_hole(3.2, 20);
    translate([0, -12.0, 0]) screw_hole(3.2, 20);
}

iec_inlet_module();