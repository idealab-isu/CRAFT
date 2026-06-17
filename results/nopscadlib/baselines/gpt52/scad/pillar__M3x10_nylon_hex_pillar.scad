$fn=64;

thread_d = 3.0;
length = 10.0;
outer_d = 6.0;

module standoff_pillar(od, id, h){
    difference(){
        cylinder(d=od, h=h, center=true);
        cylinder(d=id, h=h+0.4, center=true);
    }
}

standoff_pillar(outer_d, thread_d, length);