$fn=64;

module radial(v=[2.0,0,6], r=0.25){
    hull(){
        translate([0,0,0]) sphere(r=r);
        translate(v) sphere(r=r);
    }
}

radial([2.0,0,6], 0.25);