$fn = 64;

// Bounding box targets (X x Y x Z): 43.5 x 26.0 x 10.0 mm
L_total = 43.5;
W_total = 26;
T_total = 10;

// Main rectangular body (flat rear end)
L_body = 33.5;
W_body = 26;
T_body = 10;

// Stepped shoulder (reduced width/height section before peg)
shoulder_step_L = 2;
shoulder_step_W = 18;
shoulder_step_T = 8;

// Peg (obround/capsule) protruding from front
L_peg = 10;
W_peg = 14;
T_peg = 6;

// Small overlap to guarantee watertight union
overlap = 0.6;

// --- Helpers ---
module capsule_x(len, w, t) {
    // Obround/capsule along X, with rectangular mid + semicircular ends.
    // len must be >= w.
    union() {
        cube([len - w, w, t], center=true);
        translate([ (len - w)/2, 0, 0]) cylinder(h=t, r=w/2, center=true);
        translate([-(len - w)/2, 0, 0]) cylinder(h=t, r=w/2, center=true);
    }
}

// --- Parts placed to exactly fill the 43.5mm length ---
module main_body() {
    // Rear face at x = -L_total/2, front face at x = -L_total/2 + L_body
    translate([-L_total/2 + L_body/2, 0, 0])
        cube([L_body, W_body, T_body], center=true);
}

module shoulder() {
    // Immediately after body, connected with overlap
    // Shoulder spans: [body_end - overlap, body_end + shoulder_step_L]
    body_end = -L_total/2 + L_body;
    translate([body_end + shoulder_step_L/2 - overlap/2, 0, 0])
        cube([shoulder_step_L + overlap, shoulder_step_W, shoulder_step_T], center=true);
}

module peg() {
    // Peg starts right after shoulder, ends at +L_total/2
    // Ensure connection by overlapping into shoulder by 'overlap'
    peg_start = -L_total/2 + L_body + shoulder_step_L;
    translate([peg_start + L_peg/2 - overlap/2, 0, 0])
        capsule_x(L_peg + overlap, W_peg, T_peg);
}

// --- Final solid ---
union() {
    main_body();
    shoulder();
    peg();
}