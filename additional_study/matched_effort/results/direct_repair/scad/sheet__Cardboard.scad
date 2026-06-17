$fn=64;

// Corrugated cardboard sheet (parametric)
sheet_len = 200;          // X
sheet_wid = 120;          // Y
sheet_thk = 4.0;          // Z total thickness

liner_thk = 0.6;          // top/bottom liner thickness
flute_amp = (sheet_thk - 2*liner_thk)/2;  // amplitude of corrugation (peak from mid)
flute_pitch = 8.0;        // corrugation wavelength along X
samples_per_pitch = 10;   // mesh resolution along X

// Slight edge rounding
edge_round = 0.6;

// Material-like subtle randomness (set to 0 for perfectly regular)
amp_jitter = 0.05;        // fraction of flute_amp
phase_jitter = 0.02;      // fraction of 2*pi

module rounded_box(size=[10,10,10], r=1){
    r2 = min(r, min(size[0], min(size[1], size[2]))/2);
    minkowski(){
        cube([size[0]-2*r2, size[1]-2*r2, size[2]-2*r2], center=false);
        sphere(r=r2);
    }
}

function clamp(x,a,b)= x<a ? a : (x>b ? b : x);

module corrugated_core(len, wid, amp, pitch, liner){
    // Build a wavy surface and extrude across width to form the flute core.
    // Core occupies Z from liner to (sheet_thk - liner), centered around mid-plane.
    core_z0 = liner;
    core_h  = sheet_thk - 2*liner;

    n_pitches = len / pitch;
    n_steps = max(4, ceil(n_pitches * samples_per_pitch));
    dx = len / n_steps;

    // Create a polyhedron-like strip via linear_extrude of a polygon in XZ.
    // Polygon traces the top of the flute and closes at the bottom.
    // Then extrude along Y.
    pts_top = [
        for(i=[0:n_steps])
            let(
                x = i*dx,
                // deterministic pseudo-jitter based on i
                j1 = (sin(i*12.9898)*43758.5453) - floor((sin(i*12.9898)*43758.5453)),
                j2 = (sin((i+17)*78.233)*12345.6789) - floor((sin((i+17)*78.233)*12345.6789)),
                a  = amp * (1 + amp_jitter*(j1-0.5)*2),
                ph = 2*PI*(x/pitch) + phase_jitter*(j2-0.5)*2*2*PI,
                z  = core_z0 + core_h/2 + a*sin(ph)
            )
            [x, z]
    ];

    pts = concat(
        pts_top,
        [[len, core_z0], [0, core_z0]]
    );

    translate([0,0,0])
        linear_extrude(height=wid, center=false, convexity=10)
            polygon(points=pts);
}

module cardboard_sheet(){
    // Outer rounded slab
    difference(){
        // Outer body
        rounded_box([sheet_len, sheet_wid, sheet_thk], r=edge_round);

        // Carve out interior to leave liners + corrugated core visible as relief
        // (This creates a subtle "edge reveal" of the corrugation when viewed from side.)
        // Keep a small rim so the sheet remains a single solid.
        rim = 1.2;
        inner_r = max(0, edge_round-0.2);
        translate([rim, rim, 0])
            rounded_box([sheet_len-2*rim, sheet_wid-2*rim, sheet_thk], r=inner_r);
    }

    // Add liners and core back inside the cavity
    rim = 1.2;
    translate([rim, rim, 0]){
        inner_len = sheet_len-2*rim;
        inner_wid = sheet_wid-2*rim;

        // Bottom liner
        color([0.72,0.60,0.42])
            cube([inner_len, inner_wid, liner_thk], center=false);

        // Corrugated core
        color([0.78,0.66,0.48])
            corrugated_core(inner_len, inner_wid, flute_amp, flute_pitch, liner_thk);

        // Top liner
        color([0.72,0.60,0.42])
            translate([0,0,sheet_thk-liner_thk])
                cube([inner_len, inner_wid, liner_thk], center=false);
    }
}

cardboard_sheet();