// SMD package with visible terminals, chamfered body, and polarity mark
// Exact overall dimensions: 11.40 x 7.50 x 2.00 (L x W x H)
// One connected solid (union of body + terminals; polarity mark is a shallow recess)

$fn = 48;

L = 11.40;
W = 7.50;
H = 2.00;

// Terminal geometry (kept within overall L)
term_len = 1.20;                 // along X
term_thk = 0.35;                 // along Z (bottom thickness)
term_w   = W * 0.78;             // along Y

// Body sits between terminals
body_L = L - 2*term_len;

// Edge treatments
chamfer = 0.35;                  // top edge chamfer amount
corner_r = 0.45;                 // body corner radius (plan view)

// Polarity mark (recess on top near one corner)
mark_r = 0.55;
mark_depth = 0.18;

// Helpers
module rounded_rect_2d(x, y, r){
    r2 = min(r, min(x,y)/2);
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(x/2 - r2), sy*(y/2 - r2)]) circle(r=r2);
    }
}

module body_with_chamfer(){
    // Create a chamfered top by hulling a slightly smaller top profile to the base profile
    base_h = H - chamfer;
    top_h  = chamfer;

    union() {
        // Main vertical walls
        linear_extrude(height=base_h, center=false)
            rounded_rect_2d(body_L, W, corner_r);

        // Chamfered top section
        translate([0,0,base_h])
            hull() {
                linear_extrude(height=0.01, center=false)
                    rounded_rect_2d(body_L, W, corner_r);

                linear_extrude(height=top_h, center=false)
                    rounded_rect_2d(body_L - 2*chamfer, W - 2*chamfer, max(0, corner_r - chamfer));
            }
    }
}

module terminal(){
    // Slightly rounded terminal block
    linear_extrude(height=term_thk, center=false)
        rounded_rect_2d(term_len, term_w, min(0.25, term_len/2));
}

difference() {
    union() {
        // Body centered in X, Y; bottom at Z=0, top at Z=H
        translate([0,0,0]) body_with_chamfer();

        // Terminals on bottom, connected to body ends with tiny overlap
        overlap = 0.05;

        // Left terminal
        translate([-(body_L/2 + term_len/2 - overlap), 0, 0])
            terminal();

        // Right terminal
        translate([ (body_L/2 + term_len/2 - overlap), 0, 0])
            terminal();
    }

    // Polarity mark: shallow recess on top near +X,+Y corner
    translate([ body_L/2 - (mark_r + 0.35),
                W/2     - (mark_r + 0.35),
                H - mark_depth ])
        cylinder(h=mark_depth + 0.02, r=mark_r, center=false);
}