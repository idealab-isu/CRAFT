$fn = 96;

module heat_set_insert(thread_bore_d=2.5, outer_d=4.6, len=4) {
    difference() {
        cylinder(d=outer_d, h=len, center=true);
        cylinder(d=thread_bore_d, h=len+0.4, center=true);
    }
}

heat_set_insert();