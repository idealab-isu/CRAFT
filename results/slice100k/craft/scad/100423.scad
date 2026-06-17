// Faceted low-poly spiral/rosette solid with tapered silhouette and central vortex depression
// Bounding box target: ~6.2 x 6.0 x 11.6 mm
// Fixed: removed expensive minkowski(); kept faceted look and vortex subtraction

// Parameters
bbox_x = 6.15; //[3.08:12.3:0.01]
bbox_y = 6.01; //[3.01:12.02:0.01]
bbox_z = 11.63; //[5.82:23.26:0.01]

z_height = bbox_z; //[5.82:23.26:0.01]
r_max_x = bbox_x/2; //[1.54:6.15:0.01]
r_max_y = bbox_y/2; //[1.5:6.01:0.01]

r_min = 0.9; //[0.45:1.8:0.01]
twist_deg = 720; //[180:1080:1]
facets_around = 18; //[8:48:1]
slices_z = 28; //[10:80:1]

depression_depth = 4.2; //[2.1:8.4:0.01]
depression_r0 = 0.55; //[0.3:1.2:0.01]
depression_r1 = 2.25; //[1.1:4.4:0.01]

profile_power = 1.6; //[0.8:3.2:0.01]
micro_facet_amp = 0.18; //[0.0:0.5:0.01]
rosette_lobes = 6; //[3:12:1]

overlap = 0.25; //[0.05:1.0:0.01]
eps = 0.03; //[0.02:0.2:0.01]

// Helpers
function lerp(a,b,t) = a + (b-a)*t;

// Radius profile: large at mid-height, tapered at top/bottom
function radial_scale(t) =
    let(u = abs(2*t - 1)) // 0 at mid, 1 at ends
    lerp(1.0, r_min/min(r_max_x,r_max_y), pow(u, profile_power));

// Slight rosette waviness
function rosette_scale(a_deg) =
    1 + micro_facet_amp * 0.55 * cos(rosette_lobes * a_deg);

// Twisted, faceted outer surface via polyhedron (triangulated)
module faceted_twisted_body() {
    n = facets_around;
    m = slices_z;
    H = z_height;
    rx = r_max_x;
    ry = r_max_y;

    pts = [
        for (j = [0:m])
            let(t = j/m,
                z = -H/2 + H*t,
                s = radial_scale(t),
                phi = twist_deg * t)
            for (i = [0:n-1])
                let(a = 360*i/n + phi,
                    rr = rosette_scale(360*i/n),
                    x = rx * s * rr * cos(a),
                    y = ry * s * rr * sin(a))
                [x,y,z]
    ];

    side_faces = [
        for (j = [0:m-1], i = [0:n-1])
            let(i2 = (i+1)%n,
                a = j*n + i,
                b = j*n + i2,
                c = (j+1)*n + i2,
                d = (j+1)*n + i)
            each [[a,b,c],[a,c,d]]
    ];

    // Caps (triangulated fan using first vertex of each ring)
    bottom_faces = [
        for (i = [1:n-2])
            [0, i+1, i]
    ];
    top0 = m*n;
    top_faces = [
        for (i = [1:n-2])
            [top0, top0+i, top0+i+1]
    ];

    polyhedron(points = pts, faces = concat(side_faces, bottom_faces, top_faces), convexity = 10);
}

// Central vortex-like depression: twisted, faceted "funnel" subtracted from the top
module vortex_depression() {
    n = facets_around;
    m = max(10, floor(slices_z*0.75));
    H = depression_depth;
    z_top = z_height/2;

    z0 = z_top - overlap;
    z1 = z0 - H - eps;

    pts = [
        for (j = [0:m])
            let(t = j/m,
                z = lerp(z0, z1, t),
                r = lerp(depression_r1, depression_r0, pow(t, 1.15)),
                phi = (twist_deg*0.55) * t + 120*t*t)
            for (i = [0:n-1])
                let(a = 360*i/n + phi,
                    rr = 1 + 0.10*cos(3*(360*i/n)))
                [r*rr*cos(a), r*rr*sin(a), z]
    ];

    side_faces = [
        for (j = [0:m-1], i = [0:n-1])
            let(i2 = (i+1)%n,
                a = j*n + i,
                b = j*n + i2,
                c = (j+1)*n + i2,
                d = (j+1)*n + i)
            each [[a,b,c],[a,c,d]]
    ];

    // Cap the bottom (ring j=m) to make a closed solid
    base = m*n;
    bottom_faces = [
        for (i = [1:n-2])
            [base, base+i, base+i+1]
    ];

    polyhedron(points = pts, faces = concat(side_faces, bottom_faces), convexity = 10);
}

// Final (no minkowski; keep crisp low-poly facets for fast render)
difference() {
    faceted_twisted_body();
    vortex_depression();
}