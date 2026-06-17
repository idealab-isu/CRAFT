$fn=128;

module washer(id=3.0, od=7.0, t=0.5){
    difference(){
        cylinder(h=t, d=od, center=true);
        cylinder(h=t+0.2, d=id, center=true);
    }
}

washer();