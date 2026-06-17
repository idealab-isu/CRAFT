$fn=64;

// Corrugated cardboard sheet (single-wall): two liners + sinusoidal fluting between
// Units: mm

// ---- Parameters ----
sheet_len = 200;
sheet_wid = 120;

liner_th = 0.6;          // thickness of each flat liner
flute_amp = 1.8;         // amplitude of flute (peak-to-mid)
flute_pitch = 6.5;       // wavelength along X
flute_wall = 0.7;        // thickness of flute web (approx)
edge_margin = 1.0;       // keep flutes slightly inset from edges

// Resolution controls
nx = 220;                // segments along length
ny = 90;                 // segments along width

// Derived
core_h = 2*flute_amp;     // distance between liners (excluding liner thickness)
total_th = core_h + 2*liner_th;

// ---- Helpers ----
function clamp(v, a, b) = v < a ? a : (v > b ? b : v);

// Sinusoidal mid-surface for flute (centered between liners)
function z_mid(x) = liner_th + flute_amp + flute_amp * sin(360 * x / flute_pitch);

// Build a thin "web" surface by giving the sinusoid a small thickness in Z
module flute_web() {
    x0 = edge_margin;
    x1 = sheet_len - edge_margin;
    y0 = edge_margin;
    y1 = sheet_wid - edge_margin;

    dx = (x1 - x0) / nx;
    dy = (y1 - y0) / ny;

    // Create a polyhedron as a thickened heightfield (top and bottom surfaces)
    // Vertices: (nx+1)*(ny+1) for bottom + same for top
    verts = [
        for (j = [0:ny], i = [0:nx]) 
            let(x = x0 + i*dx, y = y0 + j*dy, zm = z_mid(x))
            [x, y, zm - flute_wall/2],
        for (j = [0:ny], i = [0:nx]) 
            let(x = x0 + i*dx, y = y0 + j*dy, zm = z_mid(x))
            [x, y, zm + flute_wall/2]
    ];

    // Faces for bottom and top grids + side walls
    // Index helpers
    function idx(i,j) = j*(nx+1) + i;
    function idxT(i,j) = (ny+1)*(nx+1) + idx(i,j);

    faces = concat(
        // Bottom surface (winding downward)
        [
            for (j=[0:ny-1], i=[0:nx-1])
                [ idx(i,j), idx(i+1,j), idx(i+1,j+1), idx(i,j+1) ]
        ],
        // Top surface (winding upward)
        [
            for (j=[0:ny-1], i=[0:nx-1])
                [ idxT(i,j), idxT(i,j+1), idxT(i+1,j+1), idxT(i+1,j) ]
        ],
        // Sides: i=0 and i=nx
        [
            for (j=[0:ny-1])
                [ idx(0,j), idx(0,j+1), idxT(0,j+1), idxT(0,j) ],
            for (j=[0:ny-1])
                [ idx(nx,j), idxT(nx,j), idxT(nx,j+1), idx(nx,j+1) ]
        ],
        // Sides: j=0 and j=ny
        [
            for (i=[0:nx-1])
                [ idx(i,0), idxT(i,0), idxT(i+1,0), idx(i+1,0) ],
            for (i=[0:nx-1])
                [ idx(i,ny), idx(i+1,ny), idxT(i+1,ny), idxT(i,ny) ]
        ]
    );

    polyhedron(points=verts, faces=faces, convexity=10);
}

module liner(z0) {
    translate([0,0,z0])
        cube([sheet_len, sheet_wid, liner_th], center=false);
}

// ---- Model ----
module corrugated_cardboard_sheet() {
    // Slightly warm cardboard color in preview
    color([0.78, 0.67, 0.48])
    union() {
        // Bottom liner
        liner(0);

        // Top liner
        liner(liner_th + core_h);

        // Flute web between liners
        flute_web();
    }
}

corrugated_cardboard_sheet();