$fn = 64;

// 40x80 aluminium extrusion profile, 100mm long (simplified 4080 T-slot style)
length = 100;
W = 80;   // X
H = 40;   // Y

// Profile feature parameters (mm)
wall = 3.0;          // outer wall thickness
slot_w = 8.0;        // T-slot opening width
slot_depth = 10.0;   // depth of slot cut from each face
center_void_w = 26;  // central rectangular void width (X)
center_void_h = 14;  // central rectangular void height (Y)
web = 3.0;           // internal web thickness

eps = 0.2;           // small overlap to avoid coplanar artifacts

module extrusion_4080(len=100) {

    // Build as: (outer - voids/slots/pockets) + webs, all in ONE connected solid
    union() {
        difference() {
            // Outer body
            cube([W, H, len], center=false);

            // Central void
            translate([(W - center_void_w)/2, (H - center_void_h)/2, -eps])
                cube([center_void_w, center_void_h, len + 2*eps], center=false);

            // T-slots on all four faces (rectangular simplification)
            // Left face slot
            translate([-eps, (H - slot_w)/2, -eps])
                cube([slot_depth + 2*eps, slot_w, len + 2*eps], center=false);

            // Right face slot
            translate([W - slot_depth - eps, (H - slot_w)/2, -eps])
                cube([slot_depth + 2*eps, slot_w, len + 2*eps], center=false);

            // Bottom face slot
            translate([(W - slot_w)/2, -eps, -eps])
                cube([slot_w, slot_depth + 2*eps, len + 2*eps], center=false);

            // Top face slot
            translate([(W - slot_w)/2, H - slot_depth - eps, -eps])
                cube([slot_w, slot_depth + 2*eps, len + 2*eps], center=false);

            // Corner relief pockets (kept inside the wall so the outer shell remains connected)
            pocket = 10;
            for (sx = [0, 1], sy = [0, 1]) {
                translate([
                    sx ? (W - wall - pocket) : wall,
                    sy ? (H - wall - pocket) : wall,
                    -eps
                ])
                    cube([pocket, pocket, len + 2*eps], center=false);
            }
        }

        // Internal webs (added back; overlap slightly into outer shell to guarantee connectivity)
        // Vertical web
        translate([(W - web)/2, wall - eps, 0])
            cube([web, H - 2*wall + 2*eps, len], center=false);

        // Horizontal web
        translate([wall - eps, (H - web)/2, 0])
            cube([W - 2*wall + 2*eps, web, len], center=false);
    }
}

color([0.75, 0.75, 0.78])
extrusion_4080(length);