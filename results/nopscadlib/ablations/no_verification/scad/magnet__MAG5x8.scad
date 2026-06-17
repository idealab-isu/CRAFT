// Parameters
magnet_type = 0; //[0:10:1]
outer_diameter_mm = 20; //[10:40:1]
height_mm = 5; //[2.5:10:0.5]
inner_diameter_mm = 0; //[0:20:1]
edge_radius_mm = 0.5; //[0:2:0.1]
bore_clearance_mm = 0.2; //[0:1:0.05]

$fn = 96;

// Magnet - complete geometry (single connected solid)
module magnet() {
    od = max(0.01, outer_diameter_mm);
    h  = max(0.01, height_mm);

    // Clamp edge radius so it can't erase the body
    er = max(0, min(edge_radius_mm, min(od/2 - 0.01, h/2 - 0.01)));

    // Clamp bore so it can't remove the entire magnet
    id_req = max(0, inner_diameter_mm);
    id_eff = min(id_req, od - 2*max(0.01, er) - 0.02);

    // Small epsilon to ensure robust booleans
    eps = 0.02;

    color([0.72, 0.45, 0.2])
    difference() {
        // Rounded-edge disk (or plain cylinder if er==0)
        if (er > 0) {
            minkowski() {
                cylinder(r=od/2 - er, h=h - 2*er, center=true);
                sphere(r=er);
            }
        } else {
            cylinder(r=od/2, h=h, center=true);
        }

        // Optional center bore
        if (id_eff > 0) {
            cylinder(r=id_eff/2 + bore_clearance_mm,
                     h=h + 2*(bore_clearance_mm + eps),
                     center=true);
        }
    }
}

// Assembly
module assembly() {
    magnet();
}

assembly();