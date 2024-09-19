ruleset sections {
  rule addSection {
    select when sections init
    pre {
      a = event:attrs{"line"}.split("\t")
.klog("a")
      id = a.head()
.klog("id")
      q = a[1]
.klog("q")
    }
  }
}
