ruleset sections {
  meta {
    shares sections_by_id
  }
  global {
    name_for_eci = function(eci){
      ent:sections_by_id
        .values()
        .filter(function(m){m{"eci"}==eci})
        {"name"}
    }
    sections_by_id = function(){
      ent:sections_by_id
    }
  }
  rule initialize {
    select when wrangler ruleset_installed where event:attrs{"rids"} >< meta:rid
    if ent:sections_by_id.isnull() then noop()
    fired {
      ent:sections_by_id := {}
    }
  }
  rule initSection {
    select when sections init
    pre {
      a = event:attrs{"line"}.split(chr(9))
      id = a.head()
      q = a[1]
    }
    if id && q then noop()
    fired {
      raise sections event "new_section" attributes {
        "id": id,
        "limit": q
      }
    }
  }
  rule addSection {
    select when sections new_section
      id re#(.+)#
      limit re#(\d+)#
      setting(id,limit)
    pre {
      already_exists = ent:sections_by_id{id}
    }
    if not already_exists then noop()
    fired {
      raise wrangler event "new_child_request" attributes {
        "co_id": meta:rid,
        "name": id,
        "limit": limit
      }
    }
  }
  rule installRulesetsInChild {
    select when wrangler child_initialized
      where event:attrs{"co_id"} == meta:rid
    pre {
      name = event:attrs{"name"}
    }
    fired {
      ent:sections_by_id{name} := event:attrs.delete("co_id").delete("limit")
.klog(<<"#{name}">>)
    }
  }
  rule cleanup {
    select when sections cleanup_requested
    foreach ent:sections_by_id setting(m,id)
    fired {
      raise wrangler event "child_deletion_request" attributes m
    }
  }
  rule recognizeDeletion {
    select when wrangler child_deleted
             or engine_ui del
    pre {
      m = event:attrs
.klog("pico deleted")
      eci = event:attrs{"eci"}
      id = event:attrs{"name"} || name_for_eci(eci).klog("name")
    }
    if id then noop()
    fired {
      clear ent:sections_by_id{id}
    }
  }
}
