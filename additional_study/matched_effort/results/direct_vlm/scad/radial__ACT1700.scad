$fn = 256;

module radial(od, id, h, t){
    // Interpret inputs as diameters: [OD, ID, height, wall_thickness]
    // If OD == ID (or too close), fall back to a solid cylinder of diameter OD.
    od_r = od/2;
    id_r = id/2;

    eps = 0.02;

    // Use t as wall thickness when possible; otherwise keep ID as given.
    id_r_eff = (t > 0) ? min(id_r, max(0, od_r - t)) : id_r;

    // If there's no meaningful hole, make a solid cylinder to avoid degenerate ring artifacts.
    if (id_r_eff <= eps || id_r_eff >= od_r - eps) {
        cylinder(h=h, r=od_r, center=true);
    } else {
        difference() {
            cylinder(h=h, r=od_r, center=true);
            cylinder(h=h + 2*eps, r=id_r_eff, center=true);
        }
    }
}

radial(10.8, 10.8, 5.3, 1);