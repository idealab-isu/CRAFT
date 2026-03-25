// Thick annular ring (washer/bushing-like) with circular through-bore
// and a faceted, slightly irregular outer surface.
// Bounding box target: ~0.1 x 0.1 x 0.1 mm

$fn = 96;

// Parameters (mm)
bbox_x = 0.1;
bbox_y = 0.1;
bbox_z = 0.1;

height  = bbox_z;          // axial thickness
outer_d = bbox_x;          // overall OD
inner_d = 0.045;           // circular bore ID

facet_sides = 18;          // faceted exterior
outer_irregularity = 0.03; // +/- radial variation (fraction of radius)

edge_chamfer = 0.004;      // small edge bevel
overlap = 0.002;           // boolean robustness

function clamp(x, a, b) = x < a ? a : (x > b ? b : x);

// Deterministic slightly irregular faceted profile
module irregular_facet_profile(r, n, irr=0.03, phase=0) {
    polygon(points=[
        for (i = [0:n-1]) let(
            a = phase + i*360/n,
            k = 1
                + irr*0.60*sin(a*1 + 17)
                + irr*0.35*sin(a*2 + 73)
                + irr*0.25*sin(a*3 + 11),
            rr = r * clamp(k, 1-irr*1.2, 1+irr*1.2)
        )
        [ rr*cos(a), rr*sin(a) ]
    ]);
}

// Faceted outer solid (NOT rotate_extrude; that caused empty/invalid geometry)
module outer_faceted_solid() {
    r = outer_d/2;
    linear_extrude(height=height, center=true, convexity=10)
        irregular_facet_profile(r=r, n=facet_sides, irr=outer_irregularity, phase=0);
}

// Chamfered cylindrical envelope to bevel the faceted solid
module chamfer_clip() {
    r = outer_d/2;
    h = height;

    if (edge_chamfer <= 0)
        cylinder(r=r, h=h + overlap*2, center=true);
    else
        union() {
            // middle straight section
            cylinder(r=r, h=max(0, h - 2*edge_chamfer) + overlap*2, center=true);

            // top chamfer
            translate([0,0, (h/2 - edge_chamfer/2)])
                cylinder(r1=r, r2=max(0, r-edge_chamfer), h=edge_chamfer + overlap, center=true);

            // bottom chamfer
            translate([0,0, -(h/2 - edge_chamfer/2)])
                cylinder(r1=max(0, r-edge_chamfer), r2=r, h=edge_chamfer + overlap, center=true);
        }
}

module through_bore() {
    cylinder(r=inner_d/2, h=height + 2*overlap, center=true, $fn=128);
}

module annular_ring() {
    difference() {
        // One connected body: faceted exterior clipped by chamfered envelope
        intersection() {
            outer_faceted_solid();
            chamfer_clip();
        }
        through_bore();
    }
}

// Final output
annular_ring();