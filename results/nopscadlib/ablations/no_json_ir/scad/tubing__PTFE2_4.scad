module ptfe_tube_body(OD, ID, length, centered=false) {
    difference() {
        cylinder(d=OD, h=length, center=centered);
        cylinder(d=ID, h=length + 2, center=centered);
    }
}

module hollow_bore(ID, length, centered=false) {
    cylinder(d=ID, h=length + 2, center=centered);
}

module tubing(OD, ID, length, centered=false) {
    ptfe_tube_body(OD, ID, length, centered);
}

// Example usage
tubing(10, 8, 50, true);