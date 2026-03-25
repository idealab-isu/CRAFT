// Dimension-calibrated (target: 54.41 x 57.06 x 89.95 mm)
scale([4.750261, 4.994529, 4.088773])
{
// Faceted 5-point star polyhedron (single connected solid)
// Target bounding box: 54.41 x 57.06 x 89.95 mm

// ---------------- Parameters ----------------
bbox_x = 54.41;
bbox_y = 57.06;
bbox_z = 89.95;

num_points = 5;

hub_radius = 12.0;
hub_height = 22.0;

lobe_length = 45.0;
lobe_base_width = 22.0;
lobe_thickness = 18.0;

lobe_twist_deg = 0.0;
overlap = 1.0;

base_trim_height = 2.0;

// Keep solid (no internal cavity subtraction)
make_internal_cavity = false;
cavity_scale_xy = 0.62;
cavity_scale_z  = 0.62;
cavity_z_offset = 6.0;

// ---------------- Helpers ----------------
function clamp(x,a,b) = min(max(x,a),b);

// A faceted "pyramidal lobe" built as a polyhedron (planar triangular faces)
module lobe_poly(lobe_len, base_w, base_t, z0, z1) {
    // Base rectangle at z0, apex at z1
    // Local coordinates: +X points outward from hub
    x0 = 0;
    x1 = base_t;
    y0 = -base_w/2;
    y1 =  base_w/2;

    apex = [lobe_len, 0, z1];

    p0 = [x0, y0, z0];
    p1 = [x1, y0, z0];
    p2 = [x1, y1, z0];
    p3 = [x0, y1, z0];

    polyhedron(
        points = [p0,p1,p2,p3,apex],
        faces = [
            [0,1,2,3],   // base (internal-ish; helps keep manifold)
            [0,1,4],
            [1,2,4],
            [2,3,4],
            [3,0,4]
        ],
        convexity = 10
    );
}

// Central stellated hub: a faceted bipyramid-like core to visually merge lobes
module central_core() {
    // Faceted core via hull of two short cylinders (gives planar-ish facets with low $fn)
    core_r = hub_radius;
    core_h = hub_height;

    hull() {
        translate([0,0,-core_h/2 + overlap])
            cylinder(r=core_r, h=overlap*2, center=true, $fn=10);
        translate([0,0, core_h/2 - overlap])
            cylinder(r=core_r*0.85, h=overlap*2, center=true, $fn=10);
    }
}

// One lobe positioned so its root overlaps into the hub (guaranteed connectivity)
module lobe_at(angle) {
    // Root plane slightly inside hub to ensure union connectivity
    root_x = hub_radius - overlap;                 // overlaps INTO hub
    z0 = -hub_height/2 + overlap;                  // start near hub bottom
    z1 =  bbox_z/2 - overlap;                      // apex near top

    rotate([0,0,angle + lobe_twist_deg])
        translate([root_x, 0, 0])
            lobe_poly(
                lobe_len = lobe_length + overlap,  // extra to keep tip sharp after scaling
                base_w   = lobe_base_width,
                base_t   = lobe_thickness,
                z0       = z0,
                z1       = z1
            );
}

// Optional internal cavity (disabled by default to keep "no openings" solid)
module internal_cavity() {
    translate([0,0,-hub_height/2 + cavity_z_offset])
        sphere(r = hub_radius + lobe_length*0.55, $fn=48);
}

// Small base trim to flatten bottom slightly (kept minimal)
module base_trim() {
    translate([0,0,-bbox_z/2 + base_trim_height/2])
        cube([2*(hub_radius + lobe_length) + 4, 2*(hub_radius + lobe_length) + 4, base_trim_height], center=true);
}

// ---------------- Model ----------------
module star_solid() {
    union() {
        central_core();
        for (i=[0:num_points-1])
            lobe_at(i*360/num_points);
    }
}

module final_model() {
    difference() {
        star_solid();

        if (make_internal_cavity)
            scale([cavity_scale_xy, cavity_scale_xy, cavity_scale_z])
                internal_cavity();

        // Keep a tiny flat so it stands; does not create openings
        base_trim();
    }
}

// ---------------- Scale to exact bounding box ----------------
// Build at nominal size then scale to target bbox.
// Nominal XY radius approx: hub_radius + lobe_length
nom_xy = 2*(hub_radius + lobe_length);
nom_z  = bbox_z;

sx = bbox_x / nom_xy;
sy = bbox_y / nom_xy;
sz = bbox_z / nom_z;

scale([sx, sy, sz])
    final_model();
}
