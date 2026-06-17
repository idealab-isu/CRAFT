$fn=96;

module ptfe_sleeving(length=100, od=6, id=4) {
    difference() {
        cylinder(h=length, d=od, center=true);
        cylinder(h=length+0.2, d=id, center=true);
    }
}

ptfe_sleeving(length=120, od=6, id=4);