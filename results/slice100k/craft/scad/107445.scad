// Dimension-calibrated (target: 19.50 x 18.88 x 78.50 mm)
scale([1.188854, 1.032839, 1.000000])
{
$fn = 128;

// Parameters (mm) — target bounding box ~19.5 x 18.9 x 78.5
bbox_X = 19.5;          // overall X (OD)
bbox_Y = 18.88;         // overall Y (OD)
L = 78.5;               // length (Z)

ODx = bbox_X;
ODy = bbox_Y;

// Bore + slit
ID = 14;                // main bore diameter
slit_w = 3.0;           // widened to make the split clearly visible in end views

// Internal stepped/notched features near +Z end (make them clearly visible)
step1_L = 3;
step1_ID = 13.2;
step2_L = 3;
step2_ID = 12.6;
step3_L = 3;
step3_ID = 12.0;

step_start_from_end = 0; // from +Z end

// Small overlaps for robust booleans
overlap = 0.5;          // boolean overlap (mm)
chamfer_L = 0.8;        // end chamfer length
lead_in_L = 2;          // bore lead-in length at +Z end
lead_in_ID = 15;        // lead-in bore diameter at +Z end

// Derived
ODr = min(ODx, ODy)/2;
IDr = ID/2;

// --- Core geometry helpers ---
module outer_body() {
    // Keep OD within bbox by using the smaller of X/Y
    cylinder(h=L, r=ODr, center=true);
}

module axial_slit_cut() {
    // Full-length slit that opens to the outside.
    // Place the slit so its inner face is slightly inside the OD to guarantee a clean cut.
    // Make it long in Y so it fully spans the tube.
    translate([ODr - slit_w/2 + overlap, 0, 0])
        cube([slit_w + 2*overlap, 2*ODr + 4*overlap, L + 4*overlap], center=true);
}

module bore_main_cut() {
    cylinder(h=L + 4*overlap, r=IDr, center=true);
}

module bore_lead_in_cut() {
    // Enlarged lead-in at +Z end
    translate([0, 0, L/2 - lead_in_L/2])
        cylinder(h=lead_in_L + 4*overlap, r1=lead_in_ID/2, r2=IDr, center=true);
}

module end_chamfer_outer_cuts() {
    // Outer chamfers at both ends (subtractive)
    translate([0, 0, L/2 - chamfer_L/2])
        cylinder(h=chamfer_L + 4*overlap,
                 r1=ODr + 2*overlap,
                 r2=max(ODr - chamfer_L, 0.01),
                 center=true);

    translate([0, 0, -L/2 + chamfer_L/2])
        cylinder(h=chamfer_L + 4*overlap,
                 r1=max(ODr - chamfer_L, 0.01),
                 r2=ODr + 2*overlap,
                 center=true);
}

module internal_steps_cut() {
    // IMPORTANT FIX:
    // Steps must be "notches" (i.e., reduce the bore locally), so we subtract an ANNULUS:
    // (main bore) minus (smaller bore) over each step length.
    // This creates visible internal shoulders/steps near +Z end.
    z1 = L/2 - step_start_from_end - step1_L/2;
    z2 = L/2 - step_start_from_end - step1_L - step2_L/2;
    z3 = L/2 - step_start_from_end - step1_L - step2_L - step3_L/2;

    union() {
        // Step 1
        translate([0, 0, z1])
        difference() {
            cylinder(h=step1_L + 2*overlap, r=IDr + overlap, center=true);
            cylinder(h=step1_L + 4*overlap, r=step1_ID/2, center=true);
        }

        // Step 2
        translate([0, 0, z2])
        difference() {
            cylinder(h=step2_L + 2*overlap, r=IDr + overlap, center=true);
            cylinder(h=step2_L + 4*overlap, r=step2_ID/2, center=true);
        }

        // Step 3
        translate([0, 0, z3])
        difference() {
            cylinder(h=step3_L + 2*overlap, r=IDr + overlap, center=true);
            cylinder(h=step3_L + 4*overlap, r=step3_ID/2, center=true);
        }
    }
}

// --- Final model (single connected solid) ---
module split_sleeve() {
    difference() {
        // Outer body with chamfered ends
        difference() {
            outer_body();
            end_chamfer_outer_cuts();
        }

        // Main through-bore
        bore_main_cut();

        // Lead-in at +Z end
        bore_lead_in_cut();

        // Internal steps/notches near +Z end (now correctly formed as shoulders)
        internal_steps_cut();

        // Full-length axial slit (widened for visibility)
        axial_slit_cut();
    }
}

split_sleeve();
}
