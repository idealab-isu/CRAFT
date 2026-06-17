// A sheet: Foam sponge (simple, visible, single connected solid)
// Structural fix: ensure non-empty geometry in all views by preventing
// accidental full subtraction and keeping all features within the slab.

sheet_length    = 200; //[100:400:1]
sheet_width     = 150; //[75:300:1]
sheet_thickness = 20;  //[10:40:1]
edge_radius     = 5;   //[2.5:10:0.5]
corner_chamfer  = 4;   //[2:8:0.5]
pore_radius     = 1.2; //[0.6:2.4:0.1]
pore_height     = 0.8; //[0.3:1.6:0.1]
pore_inset      = 12;  //[6:24:1]
overlap         = 1;   //[0.5:2:0.1]

// Texture controls
pore_pitch  = 10;
pore_jitter = 0.35;
pore_depth  = 0.9;

$fn = 36;

// Helpers
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);
function hash01(i, j, k) = abs(sin(i*12.9898 + j*78.233 + k*37.719)) % 1;
function jitter(i, j, k, a) = (hash01(i,j,k) - 0.5) * 2 * a;

// Rounded slab (robust)
module rounded_sheet(L, W, T, R) {
    r = clamp(R, 0, min(L, W, T)/2 - 0.01);

    if (r <= 0.001) {
        cube([L, W, T], center=true);
    } else {
        hull() {
            for (sx = [-1, 1], sy = [-1, 1], sz = [-1, 1]) {
                translate([sx*(L/2 - r), sy*(W/2 - r), sz*(T/2 - r)])
                    sphere(r=r);
            }
        }
    }
}

// Corner chamfer cuts (subtractive)
module chamfer_cuts(L, W, T, ch, ov) {
    ch2 = clamp(ch, 0, min(L, W)/2 - 0.01);
    if (ch2 > 0.001) {
        cutZ  = T + 4*ov;
        cutXY = ch2 * 3;

        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx*(L/2 - ch2/2),
                       sy*(W/2 - ch2/2),
                       0])
                rotate([0,0,45])
                    cube([cutXY, cutXY, cutZ], center=true);
        }
    }
}

// Pore field for carving (difference)
// FIX: keep pores shallow and fully inside the slab so they cannot erase it.
module pore_field(L, W, T, inset, pitch, pr, pd, ov) {
    x0 = -L/2 + inset;
    x1 =  L/2 - inset;
    y0 = -W/2 + inset;
    y1 =  W/2 - inset;

    spanX = max(0.01, x1 - x0);
    spanY = max(0.01, y1 - y0);

    nx = max(1, floor(spanX / pitch));
    ny = max(1, floor(spanY / pitch));

    // Ensure pores never cut through the sheet:
    // keep a minimum "skin" thickness on each side.
    skin = max(0.8, ov);                 // leave at least ~0.8mm
    dd_max = max(0.2, T/2 - skin);       // max depth from each face
    pd2 = clamp(pd, 0.1, dd_max);

    for (ix = [0:nx], iy = [0:ny]) {
        x = x0 + ix * (spanX / nx);
        y = y0 + iy * (spanY / ny);

        jx = jitter(ix, iy, 1, pitch*pore_jitter);
        jy = jitter(ix, iy, 2, pitch*pore_jitter);
        rr = pr * (0.75 + 0.6*hash01(ix, iy, 3));
        dd = pd2 * (0.70 + 0.7*hash01(ix, iy, 4));

        // Top carve: centered just below top surface, fully inside
        translate([clamp(x + jx, x0, x1), clamp(y + jy, y0, y1),
                   (T/2 - skin) - dd/2])
            cylinder(r=rr, h=dd, center=true);

        // Bottom carve: centered just above bottom surface, fully inside
        translate([clamp(x + jx, x0, x1), clamp(y + jy, y0, y1),
                   (-T/2 + skin) + dd/2])
            cylinder(r=rr, h=dd, center=true);
    }
}

// Small surface bumps (additive)
// FIX: ensure bumps overlap into the sheet by 'overlap' so it's one solid.
module surface_bumps(L, W, T, inset, pitch, pr, ph, ov) {
    x0 = -L/2 + inset;
    x1 =  L/2 - inset;
    y0 = -W/2 + inset;
    y1 =  W/2 - inset;

    spanX = max(0.01, x1 - x0);
    spanY = max(0.01, y1 - y0);

    nx = max(1, floor(spanX / pitch));
    ny = max(1, floor(spanY / pitch));

    for (ix = [0:nx], iy = [0:ny]) {
        if (hash01(ix, iy, 9) > 0.72) {
            x = x0 + ix * (spanX / nx);
            y = y0 + iy * (spanY / ny);

            jx = jitter(ix, iy, 10, pitch*0.25);
            jy = jitter(ix, iy, 11, pitch*0.25);
            rr = pr * (0.6 + 0.7*hash01(ix, iy, 12));
            hh = ph * (0.6 + 0.8*hash01(ix, iy, 13));

            // Center so the bump penetrates the top face by ov (connectivity)
            translate([clamp(x + jx, x0, x1), clamp(y + jy, y0, y1),
                       (T/2 - ov) + hh/2])
                cylinder(r=rr, h=hh, center=true);
        }
    }
}

// Final foam sponge sheet: ONE connected solid, clearly visible
color([0.85, 0.85, 0.8])
difference() {
    union() {
        difference() {
            rounded_sheet(sheet_length, sheet_width, sheet_thickness, edge_radius);
            chamfer_cuts(sheet_length, sheet_width, sheet_thickness, corner_chamfer, overlap);
        }
        surface_bumps(sheet_length, sheet_width, sheet_thickness,
                      pore_inset, pore_pitch, pore_radius, pore_height, overlap);
    }
    pore_field(sheet_length, sheet_width, sheet_thickness,
               pore_inset, pore_pitch, pore_radius, pore_depth, overlap);
}