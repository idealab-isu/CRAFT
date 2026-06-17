$fn=64;

thread_d = 3.0;
length = 13.0;
outer_d = 6.0;

module standoff_pillar(od, h, hole_d){
    difference(){
        cylinder(d=od, h=h, center=true);
        cylinder(d=hole_d, h=h+0.4, center=true);
    }
}

standoff_pillar(outer_d, length, thread_d);