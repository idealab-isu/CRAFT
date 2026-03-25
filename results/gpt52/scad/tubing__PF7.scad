$fn=96;

module ptfe_tube(length=100, od=4, id=2.5) {
    difference() {
        cylinder(h=length, d=od, center=true);
        cylinder(h=length+0.2, d=id, center=true);
    }
}

ptfe_tube(length=100, od=4, id=2.5);