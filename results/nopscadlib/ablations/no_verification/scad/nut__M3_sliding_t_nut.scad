// T-slot nut for M3 screw
// Requirements: 3.0mm screw (clearance hole), 6.0mm across flats, 3.0mm thick
// Single connected solid (one part), no extra washer/hex stack.

$fn = 96;

// --- Core requirements ---
thickness = 3.0;                 // overall thickness (Z)
across_flats = 6.0;              // hex across flats (internal hex socket)
hole_clearance = 3.2;            // clearance for M3 (no threads modeled)

// --- T-slot nut profile (T-shape in plan view) ---
nut_overall_length = 12.0;       // along slot (X)

// Bottom "head" that captures under slot lips
head_width = 8.0;                // across slot (Y) at bottom
// Top "neck" that fits through slot opening
neck_width = 6.0;                // across slot (Y) at top

// Lengths (X) for head/neck (neck centered on head)
head_length = nut_overall_length;
neck_length = nut_overall_length - 2.0;  // slightly shorter to form shoulders

// Height split (Z): head + neck = thickness
neck_height = 1.2;
head_height = thickness - neck_height;

// Edge chamfer (small, for insertion)
edge_chamfer = 0.35;

// Overlap for robust booleans
overlap = 0.2;

// --- Helpers ---
function hex_circumradius_from_af(af) = af / (2 * cos(30)); // R such that across flats = af

module chamfered_block(size=[10,10,3], c=0.35) {
    if (c <= 0) {
        cube(size, center=true);
    } else {
        intersection() {
            cube(size, center=true);
            hull() {
                cube([max(0.01,size[0]-2*c), max(0.01,size[1]-2*c), size[2]+2*overlap], center=true);
                cube([size[0], size[1], max(0.01, size[2]-2*c)], center=true);
            }
        }
    }
}

module t_slot_nut() {
    difference() {
        union() {
            // Bottom head (wider) - centered at z = -thickness/2 + head_height/2
            translate([0, 0, -thickness/2 + head_height/2])
                chamfered_block([head_length, head_width, head_height], edge_chamfer);

            // Top neck (narrower) - connected, centered at z = +thickness/2 - neck_height/2
            translate([0, 0,  thickness/2 - neck_height/2])
                chamfered_block([neck_length, neck_width, neck_height], edge_chamfer);
        }

        // Through clearance hole for M3
        cylinder(r=hole_clearance/2, h=thickness + 2*overlap, center=true);

        // Internal hex socket (6mm across flats) for driving/holding (recessed from top)
        // Keep a bottom wall so the part remains one solid and thickness stays 3.0mm.
        hex_depth = min(1.6, thickness - 0.6);   // leaves >=0.6mm bottom wall
        bottom_wall = thickness - hex_depth;
        translate([0, 0, thickness/2 - hex_depth/2])
            cylinder(r=hex_circumradius_from_af(across_flats),
                     h=hex_depth + overlap,
                     center=true,
                     $fn=6);

        // Small lead-in chamfer for the clearance hole (both sides)
        hole_ch = 0.35;
        translate([0,0, thickness/2 - hole_ch/2])
            cylinder(r1=hole_clearance/2 + hole_ch,
                     r2=hole_clearance/2,
                     h=hole_ch + overlap,
                     center=true);
        translate([0,0,-thickness/2 + hole_ch/2])
            cylinder(r1=hole_clearance/2,
                     r2=hole_clearance/2 + hole_ch,
                     h=hole_ch + overlap,
                     center=true);
    }
}

t_slot_nut();