// Dimension-calibrated (target: 54.41 x 57.06 x 89.95 mm)
scale([1.125902, 1.123383, 1.462285])
{
// Faceted 5-point stellated star solid (single connected polyhedron-like solid)
// Target bbox approx: 54.4 x 57.1 x 90.0 mm, upright (Z is height)

$fn = 64;

// Bounding box targets
bbox_x = 54.41;
bbox_y = 57.06;
bbox_z = 89.95;

n_lobes = 5;

// Core proportions (tuned to match silhouette + height)
hub_r = 12.2;          // faceted hub radius (not a cylinder)
hub_h = 30.0;          // hub height contribution
lobe_len = 33.0;       // radial reach from hub surface to tip
lobe_w   = 22.0;       // lobe base width (tangential)
lobe_h   = 60.0;       // lobe height (Z) from base to tip
overlap  = 1.2;        // guaranteed overlap into hub for connectivity
base_pad_h = 1.2;      // small flattening pad
base_pad_r = 10.0;

// ---------- Helpers ----------
function clamp(x,a,b) = x<a ? a : (x>b ? b : x);

// ---------- Geometry ----------
module faceted_hub() {
    // A faceted "stellated" hub: hull of two rotated pentagons (gives planar facets)
    hull() {
        translate([0,0,-hub_h/2])
            rotate([0,0,0])
                cylinder(r=hub_r, h=0.01, $fn=n_lobes);
        translate([0,0, hub_h/2])
            rotate([0,0,180/n_lobes])
                cylinder(r=hub_r*0.92, h=0.01, $fn=n_lobes);
    }
}

module lobe_wedge() {
    // A wedge-like pyramidal lobe: hull between a base triangle and a tip point.
    // Built upright (Z height), then placed radially.
    hull() {
        // Base: thin triangular plate at z=0
        translate([0,0,0])
            linear_extrude(height=0.01, center=false)
                polygon(points=[
                    [0, -lobe_w/2],
                    [0,  lobe_w/2],
                    [lobe_len*0.55, 0]
                ]);

        // Tip: a point at z=lobe_h, slightly forward to create sharp ridges
        translate([lobe_len, 0, lobe_h])
            sphere(r=0.35);
    }
}

module star_solid() {
    union() {
        // Faceted hub
        faceted_hub();

        // Lobes: ensure they intersect the hub by translating inward by overlap
        for (i=[0:n_lobes-1]) {
            rotate([0,0,i*360/n_lobes])
                translate([hub_r - overlap, 0, -hub_h/2])  // base starts at hub bottom for upright height
                    lobe_wedge();
        }

        // Small base pad to stabilize; overlaps into hub (no floating)
        translate([0,0,-hub_h/2 + base_pad_h/2 - overlap])
            cylinder(r=base_pad_r, h=base_pad_h, center=true);
    }
}

// ---------- Scale to requested bounding box ----------
module scaled_to_bbox() {
    // Compute approximate extents before scaling:
    // XY radius approx = hub_r + lobe_len
    // Z height approx = hub_h + lobe_h
    approx_xy_d = 2*(hub_r + lobe_len);
    approx_z    = hub_h + lobe_h;

    sx = bbox_x / approx_xy_d;
    sy = bbox_y / approx_xy_d;
    sz = bbox_z / approx_z;

    // Keep near-uniform XY scaling, independent Z scaling to hit height
    sxy = min(sx, sy);

    scale([sxy, sxy, sz])
        star_solid();
}

scaled_to_bbox();
}
