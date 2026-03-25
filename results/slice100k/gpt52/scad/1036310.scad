$fn=128;

outer_d = 20.0;
height  = 18.0;
hole_d  = 8.0;

module washer(od, h, id){
    difference(){
        cylinder(d=od, h=h, center=true);
        cylinder(d=id, h=h+0.2, center=true);
    }
}

washer(outer_d, height, hole_d);