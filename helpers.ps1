function insertBefore($str, $anchor, $insert) {
    $idx = $str.IndexOf($anchor)
    if ($idx -lt 0) { Write-Warning "Anchor not found: $anchor"; return $str }
    return $str.Substring(0, $idx) + $insert + $str.Substring($idx)
}
