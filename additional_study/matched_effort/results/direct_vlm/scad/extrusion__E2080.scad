$fn = 64;

// 20x80 aluminium extrusion profile with 4 T-slots (approximation), 100mm long
length = 100;
w = 80;
h = 20;

module extrusion_20x80(len=100, w=80, h=20) {

    // Dimension-derived parameters (no arbitrary placement)
    t = min(w,h) * 0.10;                 // outer wall thickness
    slot_open = min(w,h) * 0.30;         // slot mouth width
    slot_depth = min(w,h) * 0.28;        // depth from outer face to inner cavity
    slot_neck = slot_open * 0.45;        // narrow neck width (T-slot throat)
    slot_lip = t * 0.70;                 // lip thickness at the mouth
    slot_cavity = slot_open * 0.85;      // wider inner cavity width

    // Central pocket (lightening) sized to keep a connected ring of material
    pocket_w = w - 2*(t + slot_depth);
    pocket_h = h - 2*(t + slot_depth);
    pocket_w2 = max(pocket_w, t*2);
    pocket_h2 = max(pocket_h, t*2);

    // Small overlap to avoid coincident faces in boolean ops
    eps = 0.02;

    module tslot_top() {
        // Carve a T-slot from the top face inward
        // Mouth (narrow) near the surface
        translate([0, h/2 - slot_lip/2])
            square([slot_neck, slot_lip + eps], center=true);

        // Neck channel down to cavity
        translate([0, h/2 - slot_lip - (slot_depth - slot_lip)/2])
            square([slot_neck, (slot_depth - slot_lip) + eps], center=true);

        // Inner cavity (wider) at the bottom of the slot
        translate([0, h/2 - slot_depth + (t/2)])
            square([slot_cavity, t + eps], center=true);
    }

    module profile_2d() {
        difference() {
            // Outer boundary
            square([w, h], center=true);

            // Central pocket (keeps profile hollow-ish but connected)
            square([pocket_w2, pocket_h2], center=true);

            // 4 T-slots (top/bottom/left/right), derived placements
            tslot_top();
            mirror([0,1,0]) tslot_top();
            rotate(90) tslot_top();
            rotate(-90) tslot_top();
        }
    }

    // Extrude along Z to length; center for easier viewing/verification
    linear_extrude(height=len, center=true, convexity=10)
        profile_2d();
}

extrusion_20x80(length, w, h);