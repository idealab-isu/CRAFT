$fn=128;

outer_d = 23.5;
thickness = 7.0;

bore_d = 10.0;

tooth_count = 12;
tooth_radial = 1.6;
tooth_tangential = 2.2;

module tooth(r_base, t, radial, tangential){
    translate([r_base + radial/2, 0, 0])
        cube([radial, tangential, t], center=true);
}

module ring_with_teeth(od, t, bore, n, radial, tangential){
    r_outer = od/2;
    r_base = r_outer - radial;
    difference(){
        union(){
            cylinder(d=2*r_base, h=t, center=true);
            for(i=[0:n-1]){
                rotate([0,0, i*360/n])
                    tooth(r_base, t, radial, tangential);
            }
        }
        cylinder(d=bore, h=t+0.6, center=true);
    }
}

ring_with_teeth(outer_d, thickness, bore_d, tooth_count, tooth_radial, tooth_tangential);