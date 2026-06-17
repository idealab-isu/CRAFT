$fn = 128;

axial = [3.4, 1.75, 0.3]; // [total_length, body_diameter, lead_diameter]

module axial_part(a = axial) {
    L_total = a[0];
    D_body  = a[1];
    d_lead  = a[2];

    // Choose a body length that fits within total length and leaves leads on both sides
    body_len = min(D_body, L_total);                 // sensible default: body about its diameter
    body_len = max(body_len, L_total * 0.5);         // ensure visible body
    body_len = min(body_len, L_total - 0.02);        // keep some lead length if possible

    lead_len_each = max((L_total - body_len) / 2, 0);

    // Overlap to guarantee one connected solid (and avoid coplanar faces)
    overlap = min(0.02, body_len/4);
    overlap = (lead_len_each > 0) ? min(overlap, lead_len_each/2) : overlap;

    union() {
        // Central body (axis along Z)
        cylinder(h = body_len, d = D_body, center = true);

        // Leads: if there is no remaining length, make a single continuous shaft through the body
        if (lead_len_each > 0) {
            translate([0, 0,  body_len/2 + lead_len_each/2 - overlap])
                cylinder(h = lead_len_each + 2*overlap, d = d_lead, center = true);

            translate([0, 0, -body_len/2 - lead_len_each/2 + overlap])
                cylinder(h = lead_len_each + 2*overlap, d = d_lead, center = true);
        } else {
            cylinder(h = body_len + 2*overlap, d = d_lead, center = true);
        }
    }
}

axial_part();