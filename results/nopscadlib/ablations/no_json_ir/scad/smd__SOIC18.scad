// SMD package overall dimensions: [11.40, 7.50, 2.00]
// One connected solid with simple SMD features (end terminals, top chamfer, pin-1 mark)

L = 11.40;
W = 7.50;
H = 2.00;

eps = 0.02;
$fn = 48;

module smd_package() {

    // Feature sizing (kept within overall envelope)
    term_len = 1.20;                 // terminal length along X (each end)
    term_step = 0.25;                // terminal thickness protrusion below body (still connected)
    chamfer = 0.35;                  // top edge chamfer amount
    pin_r = 0.45;
    pin_h = 0.12;

    // Derived
    body_z0 = -H/2;
    body_z1 =  H/2;
    term_z0 = body_z0 - term_step;   // terminals extend downward
    term_z1 = body_z0 + 0.55*H;      // terminals rise into body to ensure connection

    union() {
        // Main body with a simple top chamfer (difference keeps overall size)
        difference() {
            cube([L, W, H], center=true);

            // Chamfer all around the top perimeter by subtracting 4 wedges
            // Each wedge is a rotated cube positioned by formulas from L/W/H/chamfer.
            for (sx = [-1, 1]) {
                translate([sx*(L/2 - chamfer/2), 0, body_z1 - chamfer/2])
                    rotate([0, 45, 0])
                        cube([chamfer*2, W + 2*eps, chamfer*2], center=true);
            }
            for (sy = [-1, 1]) {
                translate([0, sy*(W/2 - chamfer/2), body_z1 - chamfer/2])
                    rotate([45, 0, 0])
                        cube([L + 2*eps, chamfer*2, chamfer*2], center=true);
            }
        }

        // End terminals (connected; extend slightly below bottom)
        // Left terminal
        translate([-(L/2 - term_len/2), 0, (term_z0 + term_z1)/2])
            cube([term_len, W*0.92, (term_z1 - term_z0)], center=true);

        // Right terminal
        translate([ (L/2 - term_len/2), 0, (term_z0 + term_z1)/2])
            cube([term_len, W*0.92, (term_z1 - term_z0)], center=true);

        // Pin-1 mark: shallow embossed dot on top near one corner (kept within top face)
        translate([
            -L/2 + (term_len + pin_r + 0.45),   // inset from left end, beyond terminal region
             W/2 - (pin_r + 0.45),              // inset from top edge
             body_z1 - pin_h/2 + eps             // slight overlap into body
        ])
            cylinder(h=pin_h, r=pin_r, center=true);
    }
}

smd_package();