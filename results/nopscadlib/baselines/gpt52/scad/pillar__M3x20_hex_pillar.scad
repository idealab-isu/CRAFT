$fn=64;

thread_d = 3.0;
length = 20.0;
outer_d = thread_d;

module standoff_pillar(d, h){
    cylinder(d=d, h=h, center=true);
}

standoff_pillar(outer_d, length);