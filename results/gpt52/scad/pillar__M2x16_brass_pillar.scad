$fn=64;

module standoff_pillar(thread_d=2.0, length=16.0, outer_d=3.17) {
    difference() {
        cylinder(h=length, d=outer_d, center=true);
        cylinder(h=length+0.4, d=thread_d, center=true);
    }
}

standoff_pillar(thread_d=2.0, length=16.0, outer_d=3.17);