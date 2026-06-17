// 7-segment display (single connected solid)
// Overall dimensions (X,Y,Z) = [12.7, 19, 8.2]
// Fix: Make the front face clearly show a classic 7-segment layout by
// ADDING raised segment bars on the front (recognizable silhouette),
// while keeping everything as ONE connected solid and preserving overall size.

$fn = 64;

// Overall size
display_width  = 12.7;  // X
display_height = 19.0;  // Y (front-back)
display_depth  = 8.2;   // Z (bottom-top)

// Front bezel + recessed window (kept, but not relied upon for visibility)
bezel_thickness = 0.9;
recess_depth    = 1.2;

// Segment geometry (raised on front face for clear 7-seg look)
seg_w     = 1.6;   // segment stroke width (X/Z)
seg_gap   = 0.7;   // gap to window edges
seg_raise = 1.2;   // how far segments protrude from front face (+Y)
seg_overlap = 1.2; // overlap into body for robust union (1-2mm)

// Decimal point (optional, raised)
dp_d      = 1.5;
dp_raise  = seg_raise;

// Pins (kept connected by a rear carrier bar so the model is ONE connected solid)
pin_d        = 0.8;
pin_len      = 3.0;      // extends out the back (negative Y)
pin_spacing  = 2.54;
pin_count    = 4;
pin_bar_h    = 1.0;      // thickness of carrier bar (Z)
pin_overlap  = 1.2;      // overlap into body for robust union (1-2mm requested)

// Robust overlap / numerical epsilon
eps = 0.02;

// Helpers
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

// Coordinate convention:
// X = width (left-right), Y = height (front-back), Z = depth (bottom-top)
// Body centered at origin. Front face at +Y, back face at -Y.

module body_base() {
    translate([-display_width/2, -display_height/2, -display_depth/2])
        cube([display_width, display_height, display_depth], center=false);
}

module front_recess_cut() {
    // Cut a window recess from the FRONT face (+Y) inward by recess_depth.
    x0 = -display_width/2  + bezel_thickness;
    z0 = -display_depth/2  + bezel_thickness;
    w  =  display_width    - 2*bezel_thickness;
    h  =  display_depth    - 2*bezel_thickness;

    y0 =  display_height/2 - recess_depth;

    translate([x0, y0 - eps, z0])
        cube([w, recess_depth + 2*eps, h], center=false);
}

// --- Raised segment bars (for recognizability) ---
module seg_bar(x, z, w, h) {
    // Place a bar so it overlaps INTO the body by seg_overlap and protrudes by seg_raise.
    // Front face is at y = +display_height/2.
    y_front = display_height/2;
    y0 = y_front - seg_overlap;                 // start inside body
    y_len = seg_overlap + seg_raise;            // extend outwards

    translate([x, y0 - eps, z])
        cube([w, y_len + 2*eps, h], center=false);
}

module segments_7_raised() {
    // Use the same window bounds in X/Z as the recess, so layout is consistent.
    wx0 = -display_width/2  + bezel_thickness;
    wz0 = -display_depth/2  + bezel_thickness;
    ww  =  display_width    - 2*bezel_thickness;
    wh  =  display_depth    - 2*bezel_thickness;

    // Inner usable area for segments
    ix0 = wx0 + seg_gap;
    iz0 = wz0 + seg_gap;
    iw  = ww  - 2*seg_gap;
    ih  = wh  - 2*seg_gap;

    // Horizontal segment length
    hlen = clamp(iw - 2*seg_w, 0.6, iw);

    // Vertical segment height (top and bottom halves)
    vhalf = clamp((ih - 3*seg_w) / 2, 0.6, ih);

    // Z positions for horizontal segments
    z_top    = iz0 + ih - seg_w;
    z_mid    = iz0 + (ih - seg_w)/2;
    z_bottom = iz0;

    // a (top)
    seg_bar(ix0 + seg_w, z_top,    hlen, seg_w);
    // d (bottom)
    seg_bar(ix0 + seg_w, z_bottom, hlen, seg_w);
    // g (middle)
    seg_bar(ix0 + seg_w, z_mid,    hlen, seg_w);

    // f (upper-left)
    seg_bar(ix0, iz0 + ih - seg_w - vhalf, seg_w, vhalf);
    // e (lower-left)
    seg_bar(ix0, iz0 + seg_w,              seg_w, vhalf);

    // b (upper-right)
    seg_bar(ix0 + iw - seg_w, iz0 + ih - seg_w - vhalf, seg_w, vhalf);
    // c (lower-right)
    seg_bar(ix0 + iw - seg_w, iz0 + seg_w,              seg_w, vhalf);
}

module decimal_point_raised() {
    // Raised dot near bottom-right inside the window.
    wx0 = -display_width/2  + bezel_thickness;
    wz0 = -display_depth/2  + bezel_thickness;
    ww  =  display_width    - 2*bezel_thickness;
    wh  =  display_depth    - 2*bezel_thickness;

    ix0 = wx0 + seg_gap;
    iz0 = wz0 + seg_gap;
    iw  = ww  - 2*seg_gap;

    x = ix0 + iw - dp_d*1.15;
    z = iz0 + dp_d*0.35;

    y_front = display_height/2;
    y0 = y_front - seg_overlap;                 // overlap into body
    y_len = seg_overlap + dp_raise;

    translate([x + dp_d/2, y0, z + dp_d/2])
        rotate([90, 0, 0])
            cylinder(h=y_len, d=dp_d, center=false);
}

module pins_connected() {
    // Pins extend out the BACK (negative Y), connected via a carrier bar that overlaps the body.
    total_span = (pin_count - 1) * pin_spacing;
    x_start = -total_span/2;

    // Back face is at -display_height/2
    y_back = -display_height/2;

    // Carrier bar: spans full width, extends outward by pin_len, overlaps into body by pin_overlap
    bar_y0  = y_back - pin_len;      // outer end
    bar_y1  = y_back + pin_overlap;  // overlaps into body
    bar_len = bar_y1 - bar_y0;

    // Place bar centered in Z, sitting at bottom half (simple)
    translate([-display_width/2, bar_y0, -pin_bar_h/2])
        cube([display_width, bar_len, pin_bar_h], center=false);

    // Pins: cylinders along Y, starting inside body for robust union
    for (i = [0:pin_count-1]) {
        x = x_start + i*pin_spacing;
        y_pin0 = y_back + pin_overlap; // start inside body
        translate([x, y_pin0, 0])
            rotate([90, 0, 0])
                cylinder(h=pin_len + pin_overlap, d=pin_d, center=false);
    }
}

module seven_segment_display() {
    union() {
        // Main body with a subtle front recess (kept)
        difference() {
            body_base();
            front_recess_cut();
        }

        // Raised segments on the front face (clear 7-seg appearance)
        segments_7_raised();
        decimal_point_raised();

        // Rear pins assembly (connected via overlap)
        pins_connected();
    }
}

seven_segment_display();