$fn=64;

// Corrugated cardboard sheet (single-wall): two flat liners with a sinusoidal fluted core.
// Units: mm

// ---- Parameters ----
length = 200;          // X
width  = 120;          // Y
liner_thickness = 0.6; // each flat layer
core_thickness  = 3.0; // flute height (peak-to-peak)
pitch = 8.0;           // flute wavelength along X
samples_per_pitch = 24; // resolution along X for the flute surface

// ---- Derived ----
total_thickness = 2*liner_thickness + core_thickness;
nx = max(10, ceil(length / pitch * samples_per_pitch));
dx = length / nx;

// ---- Helpers ----
function clamp(v, a, b) = v < a ? a : (v > b ? b : v);

// Flute mid-surface (sinusoidal), centered within core thickness
function flute_z(x) = liner_thickness + core_thickness/2
                      + (core_thickness/2) * sin(360 * x / pitch);

// Build a polyhedron "strip" between x0..x1, spanning full width, with top/bottom z varying by x
module variable_thickness_strip(x0, x1, zbot0, ztop0, zbot1, ztop1, y0=0, y1=width) {
    polyhedron(
        points=[
            // x0 face
            [x0,y0,zbot0], //0
            [x0,y1,zbot0], //1
            [x0,y1,ztop0], //2
            [x0,y0,ztop0], //3
            // x1 face
            [x1,y0,zbot1], //4
            [x1,y1,zbot1], //5
            [x1,y1,ztop1], //6
            [x1,y0,ztop1]  //7
        ],
        faces=[
            // x0 face
            [0,1,2],[0,2,3],
            // x1 face
            [4,6,5],[4,7,6],
            // y0 face
            [0,3,7],[0,7,4],
            // y1 face
            [1,5,6],[1,6,2],
            // bottom face
            [0,4,5],[0,5,1],
            // top face
            [3,2,6],[3,6,7]
        ]
    );
}

// ---- Model ----
module corrugated_cardboard_sheet() {
    // Bottom liner
    color([0.72,0.60,0.42])
        translate([0,0,0])
            cube([length, width, liner_thickness], center=false);

    // Top liner
    color([0.72,0.60,0.42])
        translate([0,0,liner_thickness + core_thickness])
            cube([length, width, liner_thickness], center=false);

    // Fluted core as many strips with varying top/bottom surfaces
    // Core thickness around the flute mid-surface: +/- core_thickness/2
    color([0.78,0.66,0.46])
    union() {
        for (i = [0:nx-1]) {
            x0 = i*dx;
            x1 = (i+1)*dx;

            zmid0 = flute_z(x0);
            zmid1 = flute_z(x1);

            zbot0 = clamp(zmid0 - core_thickness/2, liner_thickness, liner_thickness + core_thickness);
            ztop0 = clamp(zmid0 + core_thickness/2, liner_thickness, liner_thickness + core_thickness);

            zbot1 = clamp(zmid1 - core_thickness/2, liner_thickness, liner_thickness + core_thickness);
            ztop1 = clamp(zmid1 + core_thickness/2, liner_thickness, liner_thickness + core_thickness);

            variable_thickness_strip(x0, x1, zbot0, ztop0, zbot1, ztop1);
        }
    }
}

corrugated_cardboard_sheet();