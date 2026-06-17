// Neoprene tubing (single connected solid)

// Parameters
outer_diameter = 10; //[5:20:0.5]
inner_diameter = 6;  //[3:12:0.5]
length = 15;         //[8:30:1]
center = 1;          //[0:1:1]
forced_id = 0;       //[0:20:0.5]
eps = 0.2;           //[0.01:1:0.01]

// Smoothness
$fn = 96;

// Tubing geometry
module tubing(od, id, len, eps_local) {
    od2 = max(od, 0.01);
    id_req = (forced_id > 0) ? forced_id : id;

    // Keep a guaranteed minimum wall thickness per side
    min_wall = 0.1; // mm per side
    id2 = min(max(id_req, 0), od2 - 2*min_wall);

    // Ensure the inner cutter fully clears the outer cylinder in Z
    cut_h = len + 2*eps_local;

    color([0.2, 0.2, 0.2])  // Neoprene-like dark gray
    difference() {
        cylinder(h=len, r=od2/2, center=true);
        cylinder(h=cut_h, r=id2/2, center=true);
    }
}

// Assembly (centered or sitting on Z=0 plane)
module assembly() {
    z0 = (center == 1) ? 0 : (length/2);
    translate([0, 0, z0])
        tubing(outer_diameter, inner_diameter, length, eps);
}

assembly();