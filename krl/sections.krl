ruleset sections {
  rule addSection {
    select when sections init
    pre {
      a = event:attrs{"line"}.split(chr(9))
.klog("a")
      id = a.head()
.klog("id")
      q = a[1]
.klog("q")
      sanity = ("\t" == chr(9))
.klog("sanity")
    }
  }
}
