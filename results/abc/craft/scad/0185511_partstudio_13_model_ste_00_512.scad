// Long rectangular prismatic block with stepped (L-shaped) planform
// and TWO centered U-shaped notches cut into opposite end faces.
// Units: mm

// Overall size (elongated along X)
L = 0.13;
W = 0.07;
H = 0.04;

// Step parameters to create an L-shaped planform in TOP view
step_L = 0.045;   // extent along X removed
step_W = 0.03;    // extent along Y removed

// U-notch parameters (cut into end faces along X)
notch_depth = 0.020;      // depth into the part along X
notch_height = 0.026;     // opening height along Z
notch_side_wall = 0.012;  // remaining wall on each side along Y (U-legs)

// Robust boolean epsilon / overlap
eps = 0.001;

// Main L-shaped planform block (extruded in Z)
// IMPORTANT: The corner removal is positioned so it actually removes the +X,+Y corner
// of the centered cube, producing an L-shaped footprint in TOP view.
module main_block_L_planform() {
    difference() {
        cube([L, W, H], center=true);

        // Remove +X,+Y corner prism:
        // Cutter spans x: [L/2-step_L, L/2], y: [W/2-step_W, W/2]
        // With center=true, place cutter center at:
        // x = L/2 - step_L/2, y = W/2 - step_W/2
        translate([ L/2 - step_L/2, W/2 - step_W/2, 0 ])
            cube([step_L + 2*eps, step_W + 2*eps, H + 2*eps], center=true);
    }
}

// Centered U-shaped notch cut from an end face (x = +/- L/2).
// Implemented as a rectangular recess that opens from the end face,
// leaving side walls (U-legs) along Y. Centered in Y and Z.
module end_u_notch(x_sign=1) {
    notch_w = max(eps, W - 2*notch_side_wall);
    notch_h = min(notch_height, H - 2*eps);

    // End face is at x = x_sign*(L/2).
    // Cutter extends slightly past the end face for a clean boolean:
    // Center at x = x_sign*(L/2 - (notch_depth/2) + eps)
    translate([ x_sign*(L/2 - notch_depth/2 + eps), 0, 0 ])
        cube([notch_depth + 2*eps, notch_w, notch_h], center=true);
}

difference() {
    // Single connected solid body
    main_block_L_planform();

    // Two matching centered U-notches on opposite end faces
    end_u_notch(-1);
    end_u_notch( 1);
}