$fn=64;

module d_profile(r=10, depth=8, h=10){
    // D shape: circle clipped by a flat
    difference(){
        cylinder(h=h, r=r, center=true);
        translate([r-depth,0,0])
            cube([2*r, 2*r+2, h+2], center=true);
    }
}

module d_connector(male=true, r=10, depth=8, h=12, clearance=0.25, lead=2){
    if(male){
        union(){
            d_profile(r=r, depth=depth, h=h);
            translate([0,0,h/2 + lead/2])
                d_profile(r=r*0.98, depth=depth*0.98, h=lead);
        }
    } else {
        difference(){
            translate([0,0,0])
                cube([2*(r+4), 2*(r+4), h+6], center=true);
            translate([0,0,0])
                d_profile(r=r+clearance, depth=depth+clearance, h=h+8);
        }
    }
}

module demo(){
    union(){
        translate([-18,0,0]) d_connector(male=true, r=10, depth=8, h=14, clearance=0.25, lead=2);
        translate([18,0,0]) d_connector(male=false, r=10, depth=8, h=14, clearance=0.25, lead=2);
    }
}

demo();