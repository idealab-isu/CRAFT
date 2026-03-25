$fn=64;

size_x = 0.1;
size_y = 0.1;
size_z = 0.0;

module faceted_outer(h=0.0001, r1=0.05, r2=0.03, facets=12){
    cylinder(h=h, r1=r1, r2=r2, $fn=facets);
}

module rim_lip(h=0.0001, r_outer=0.05, r_inner=0.042){
    difference(){
        cylinder(h=h, r=r_outer, $fn=64);
        translate([0,0,-0.0002]) cylinder(h=h+0.0004, r=r_inner, $fn=64);
    }
}

module interior_cavity(h=0.0001, r_top=0.04, r_bottom=0.0){
    cylinder(h=h, r1=r_top, r2=r_bottom, $fn=64);
}

module side_notch(w=0.012, d=0.01, h=0.0001){
    translate([0.05 - d/2, 0, h/2])
        cube([d, w, h+0.0004], center=true);
}

module cup(){
    h = (size_z <= 0) ? 0.0001 : size_z;
    r_rim = size_x/2;
    r_body_bottom = r_rim*0.6;
    r_cavity = r_rim*0.8;
    lip_thickness = r_rim*0.16;

    difference(){
        union(){
            translate([0,0,-h/2]) faceted_outer(h=h, r1=r_rim, r2=r_body_bottom, facets=14);
            translate([0,0,-h/2]) rim_lip(h=h, r_outer=r_rim, r_inner=r_rim - lip_thickness);
        }
        translate([0,0,-h/2]) interior_cavity(h=h+0.0002, r_top=r_cavity, r_bottom=0.0);
        translate([0,0,-h/2]) side_notch(w=r_rim*0.5, d=r_rim*0.22, h=h);
        rotate([0,0,180]) translate([0,0,-h/2]) side_notch(w=r_rim*0.5, d=r_rim*0.22, h=h);
    }
}

cup();