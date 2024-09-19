ruleset sections {
  rule addSection {
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
}
