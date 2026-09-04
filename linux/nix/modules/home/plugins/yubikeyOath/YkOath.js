// YubiKey OATH helpers for the DMS plugin.
// Pure JS, no QML imports, so it can be tested standalone (bun/node/qjs).
//
// Ground truth (ykman 5.9.1 sources):
// - `ykman oath accounts code` bulk output lines are formatted
//   "{:<nameWidth}  {:>codeWidth}" i.e. name, 2+ spaces, right-aligned code.
//   Touch-required credentials print "[Requires Touch]", HOTP "[HOTP Account]".
// - Codes arrive zero-padded and ungrouped ("501604").
// - `ykman oath accounts list -P -o` prints "name, TOTP, 30" per line.
// - `ykman list --serials` prints one bare serial per line.
// - Multiple connected keys require `ykman -d SERIAL ...` per device.
// - TOTP validity windows are computed from host time: time_step = unix // period.

function unescapeId(s) {
    if (!s)
        return "";
    try {
        return decodeURIComponent(s);
    } catch (e) {
        return s;
    }
}

// "Issuer:account" -> { issuer, account }; no issuer -> { issuer: "", account: name }
function splitCredential(rawName) {
    const name = unescapeId(String(rawName || "").trim());
    const idx = name.indexOf(":");
    if (idx > 0)
        return {
            issuer: name.slice(0, idx),
            account: name.slice(idx + 1)
        };
    return {
        issuer: "",
        account: name
    };
}

// Parse bulk `code` output -> [{name, code, status}]
// status: "ok" | "touch" | "hotp" | "none"
function parseCodeOutput(stdout) {
    const rows = [];
    const lines = String(stdout || "").split("\n");
    for (const line of lines) {
        if (!line.trim())
            continue;
        const m = line.match(/^(.*?)\s{2,}(.*)$/);
        const name = m ? m[1].trim() : line.trim();
        let code = m ? m[2].trim() : "";
        let status = "ok";
        if (!code) {
            status = "none";
        } else if (code === "[Requires Touch]") {
            status = "touch";
            code = "";
        } else if (code === "[HOTP Account]") {
            status = "hotp";
            code = "";
        }
        rows.push({
            name: name,
            code: code,
            status: status
        });
    }
    return rows;
}

// Parse `list -P -o` -> { name: { oathType, period } }
function parseListMeta(stdout) {
    const meta = {};
    for (const line of String(stdout || "").split("\n")) {
        const t = line.trim();
        if (!t)
            continue;
        const parts = t.split(",").map(p => p.trim());
        const name = parts[0];
        let oathType = "TOTP";
        let period = 30;
        for (let i = 1; i < parts.length; i++) {
            if (parts[i] === "TOTP" || parts[i] === "HOTP")
                oathType = parts[i];
            else {
                const n = parseInt(parts[i], 10);
                if (!isNaN(n) && n > 0)
                    period = n;
            }
        }
        meta[name] = {
            oathType: oathType,
            period: period
        };
    }
    return meta;
}

function parseSerials(stdout) {
    const out = [];
    for (const line of String(stdout || "").split("\n")) {
        const t = line.trim();
        if (/^\d{6,12}$/.test(t))
            out.push(t);
    }
    return out;
}

// "501604" -> "501 604"; "12345678" -> "1234 5678"; odd-length / non-digit (Steam) unchanged.
// grouping: "half" | "none"
function formatCode(code, grouping) {
    const c = String(code || "");
    if (!c || grouping === "none" || c.length % 2 !== 0 || !/^\d+$/.test(c))
        return c;
    const half = c.length / 2;
    return c.slice(0, half) + " " + c.slice(half);
}

// Seconds left in the current TOTP window (host clock, same as ykman).
function secondsRemaining(period, unixSec) {
    const p = period > 0 ? period : 30;
    const now = unixSec > 0 ? unixSec : Math.floor(Date.now() / 1000);
    return p - (now % p);
}

// True on the tick where any credential's window rolls over -> refetch.
function shouldRefetch(rows, unixSec) {
    for (const r of rows || []) {
        const p = r && r.period > 0 ? r.period : 0;
        if (p > 0 && unixSec % p === 0)
            return true;
    }
    return false;
}

function lastNonEmptyLine(text) {
    const lines = String(text || "").split("\n").map(l => l.trim()).filter(l => l.length > 0);
    return lines.length > 0 ? lines[lines.length - 1] : "";
}

// Merge per-device results -> display rows, sorted by title.
// devices: [{serial, codeOut, exitCode, metaOut}]
// A device that fails becomes a single error row (nonzero exit => output is
// error text, never credentials).
function buildRows(devices) {
    const rows = [];
    for (const dev of devices || []) {
        if (dev.exitCode !== 0) {
            rows.push({
                key: dev.serial + ":__error__",
                serial: dev.serial,
                title: "YubiKey " + dev.serial,
                subtitle: lastNonEmptyLine(dev.codeOut) || "ykman failed",
                initial: "!",
                code: "",
                status: "error",
                oathType: "TOTP",
                period: 30
            });
            continue;
        }
        const creds = parseCodeOutput(dev.codeOut);
        const meta = parseListMeta(dev.metaOut);
        for (const cred of creds) {
            const m = meta[cred.name] || {};
            const parts = splitCredential(cred.name);
            rows.push({
                key: dev.serial + ":" + cred.name,
                serial: dev.serial,
                name: cred.name,
                issuer: parts.issuer,
                account: parts.account,
                title: parts.issuer || parts.account,
                subtitle: parts.issuer ? parts.account : "",
                initial: (parts.issuer || parts.account || "?").charAt(0).toUpperCase(),
                code: cred.code,
                status: cred.status,
                oathType: m.oathType || "TOTP",
                period: m.period || 30
            });
        }
    }
    rows.sort((a, b) => (a.title + a.subtitle).localeCompare(b.title + b.subtitle));
    return rows;
}
