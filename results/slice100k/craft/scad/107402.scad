// Curved C-shaped hollow sleeve segment (partial ring/pipe section)
// Target bounding box: 9.1 x 3.5 x 1.7 mm (L x W x H), elongated along X
// Fix: ensure non-empty visible geometry; true hollow C-segment; constant wall;
// faceted outer surface; single connected solid; robust clipping to bbox.

$fn = 64;

bbox_L = 9.10; // X (length)
bbox_W = 3.50; // Y (width)
bbox_H = 1.70; // Z (height)

wall_t = 0.30;
facet_count = 12;          // facets around the arc (outer surface faceting)
end_gap_clearance = 0.20;  // chord gap between open ends (approx)
eps = 0.02;

// Radii chosen to fit within bbox in Y and Z after clipping.
// Use the limiting half-dimension so the ring is guaranteed to exist after intersection.
R_outer_use = max(wall_t + 0.10, min(bbox_W/2, bbox_H/2) - eps);
R_inner_use = max(0.05, R_outer_use - wall_t);

// Compute arc angle from desired end gap at outer radius.
// chord = 2*R*sin(theta/2) => theta = 2*asin(chord/(2R))
// arc = 360 - theta (remove a wedge to make a "C")
arc_from_gap = 2 * asin(min(0.999, end_gap_clearance / (2*R_outer_use)));
arc_deg_use  = 360 - arc_from_gap * 180 / PI;
arc_deg_use  = max(160, min(330, arc_deg_use)); // clearly C-shaped

// 2D ring sector in XY (faceted by polygon sampling)
module ring_sector_2d(Ri, Ro, ang_deg, facets=24) {
    ang = max(1, min(359, ang_deg));
    n = max(6, facets);

    outer_pts = [for (i=[0:n]) let(a = -ang/2 + ang*i/n) [Ro*cos(a), Ro*sin(a)]];
    inner_pts = [for (i=[0:n]) let(a =  ang/2 - ang*i/n) [Ri*cos(a), Ri*sin(a)]];

    polygon(points=concat(outer_pts, inner_pts));
}

// Main sleeve: extrude along X by rotating a Z-extrude
module c_sleeve() {
    rotate([0,90,0])
        linear_extrude(height=bbox_L + 2*eps, center=true, convexity=10)
            ring_sector_2d(R_inner_use, R_outer_use, arc_deg_use, facets=max(12, facet_count));
}

// Clip to exact bounding box while keeping a single solid.
// Slightly oversize the clipping cube to avoid accidental empty intersections due to coplanar faces.
intersection() {
    union() {
        c_sleeve();
    }
    cube([bbox_L + 2*eps, bbox_W + 2*eps, bbox_H + 2*eps], center=true);
}