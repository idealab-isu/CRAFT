$fn=64;

module standoff_pillar(thread_d=4.0, length=20.0, outer_d=8.0) {
    difference() {
        cylinder(h=length, d=outer_d, center=true);
        cylinder(h=length + 0.4, d=thread_d, center=true);
    }
}

standoff_pillar(thread_d=4.0, length=20.0, outer_d=8.0);