// 20x40 aluminium T-slot extrusion profile, 100mm long (single connected solid)

$fn = 96;

module extrusion_2040(len=100) {
    linear_extrude(height=len, center=true, convexity=20)
        extrusion_2040_cross_section();
}

module extrusion_2040_cross_section() {
    // Overall size (mm)
    w = 20;
    h = 40;

    // Typical-ish 2040 features (kept simple but recognizable)
    wall = 2.0;          // outer wall thickness
    slot_w = 6.2;        // slot opening width
    slot_depth = 6.0;    // depth from outer face
    throat_w = 3.2;      // narrow throat width
    throat_depth = 2.0;  // throat depth from outer face

    bore_r = 4.2;        // central bore radius

    // Internal webs (ensure one connected solid)
    web = 2.0;

    // Derived
    inner_w = w - 2*wall;
    inner_h = h - 2*wall;

    // Keep a minimum ring around the bore so it doesn't disconnect from webs
    bore_clear = 0.6;

    // Build as: (outer body) minus (slots + inner void + bore), then add webs back
    union() {
        difference() {
            // Outer boundary
            square([w, h], center=true);

            // Inner cavity (hollow core)
            square([inner_w, inner_h], center=true);

            // Central bore
            circle(r=bore_r);

            // T-slots on all four faces (cut from outside inward)
            // Right face
            translate([ w/2 - slot_depth/2, 0])
                square([slot_depth, slot_w], center=true);
            translate([ w/2 - throat_depth/2, 0])
                square([throat_depth, throat_w], center=true);

            // Left face
            translate([-w/2 + slot_depth/2, 0])
                square([slot_depth, slot_w], center=true);
            translate([-w/2 + throat_depth/2, 0])
                square([throat_depth, throat_w], center=true);

            // Top face
            translate([0,  h/2 - slot_depth/2])
                square([slot_w, slot_depth], center=true);
            translate([0,  h/2 - throat_depth/2])
                square([throat_w, throat_depth], center=true);

            // Bottom face
            translate([0, -h/2 + slot_depth/2])
                square([slot_w, slot_depth], center=true);
            translate([0, -h/2 + throat_depth/2])
                square([throat_w, throat_depth], center=true);
        }

        // Internal webs (added back so the profile is not just a hollow tube)
        // Vertical web
        square([web, inner_h], center=true);

        // Horizontal web
        square([inner_w, web], center=true);

        // Small ring around bore to ensure robust connectivity between webs and outer body
        difference() {
            circle(r=bore_r + wall);
            circle(r=bore_r + bore_clear);
        }
    }
}

extrusion_2040(100);