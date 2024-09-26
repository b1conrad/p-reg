ruleset section {
  rule initialize {
    select when wrangler ruleset_installed where event:attrs{"rids"} >< meta:rid
    if ent:limit.isnull() then noop()
    fired {
      ent:roster := {}
      ent:limit := event:attrs{"limit"}
.klog("limit set")
      raise section event "section_initialized"
    }
  }
}
