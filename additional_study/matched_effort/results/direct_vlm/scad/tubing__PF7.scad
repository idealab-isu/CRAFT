$fn = 128;

// PTFE tubing (hollow cylinder)
// Units: mm
outer_d = 4.0;     // OD
inner_d = 2.0;     // ID
length  = 200.0;   // tube length

module ptfe_tube(od, id, len) {
    eps = 0.2;
    od_ok = (od > 0) && (len > 0);
    id_ok = (id > 0) && (od > id);

    color([0.95, 0.95, 0.95])
    rotate([0, 90, 0])  // axis along X
    difference() {
        // Outer tube
        cylinder(d=od, h=len, center=true);

        // Inner bore (slightly longer to guarantee a clean through-hole)
        if (od_ok && id_ok)
            cylinder(d=id, h=len + 2*eps, center=true);
    }
}

ptfe_tube(outer_d, inner_d, length);