::  memory-json: JSON encoding/decoding for memory agent v2
::
/-  *memory
|%
::  +entry-to-json: convert entry to JSON
::
++  entry-to-json
  |=  =entry
  ^-  json
  %-  pairs:enjs:format
  :~  ['id' s+(scot %uv id.entry)]
      ['created' s+(scot %da created.entry)]
      ['updated' s+(scot %da updated.entry)]
      ['tag' s+(scot %tas tag.entry)]
      ['key' ?~(key.entry ~ s+u.key.entry)]
      ['content' s+content.entry]
  ==
::  +entries-to-json: convert list of entries to JSON
::
++  entries-to-json
  |=  entries=(list entry)
  ^-  json
  a+(turn entries entry-to-json)
::  +tags-to-json: convert set of tags to JSON
::
++  tags-to-json
  |=  tags=(set @tas)
  ^-  json
  a+(turn ~(tap in tags) |=(t=@tas s+(scot %tas t)))
::  +json-to-cord: extract cord from json string
::
++  json-to-cord
  |=  j=json
  ^-  @t
  ?>  ?=(%s -.j)
  p.j
::  +json-to-tag: extract tag from json string
::
++  json-to-tag
  |=  j=json
  ^-  @tas
  ?>  ?=(%s -.j)
  (slav %tas p.j)
::  +json-to-key: extract optional key from json
::
++  json-to-key
  |=  j=(unit json)
  ^-  (unit @t)
  ?~  j  ~
  ?.  ?=(%s -.u.j)  ~
  ?:  =('' p.u.j)  ~
  `p.u.j
::  +parse-action: parse JSON into action
::
++  parse-action
  |=  jon=json
  ^-  action
  =/  obj=(map @t json)  ((om:dejs:format same) jon)
  =/  typ=@t  (json-to-cord (~(got by obj) 'type'))
  ?+  typ  !!
  ::
      %'put'
    =/  tag=@tas  (json-to-tag (~(got by obj) 'tag'))
    =/  key=(unit @t)  (json-to-key (~(get by obj) 'key'))
    =/  content=@t  (json-to-cord (~(got by obj) 'content'))
    [%put tag key content]
  ::
      %'upsert'
    =/  tag=@tas  (json-to-tag (~(got by obj) 'tag'))
    =/  key=@t  (json-to-cord (~(got by obj) 'key'))
    =/  content=@t  (json-to-cord (~(got by obj) 'content'))
    [%upsert tag key content]
  ::
      %'del'
    =/  id-val=@uv  (slav %uv (json-to-cord (~(got by obj) 'id')))
    [%del id-val]
  ::
      %'del-key'
    =/  tag=@tas  (json-to-tag (~(got by obj) 'tag'))
    =/  key=@t  (json-to-cord (~(got by obj) 'key'))
    [%del-key tag key]
  ::
      %'wipe'
    =/  tag=@tas  (json-to-tag (~(got by obj) 'tag'))
    [%wipe tag]
  ::
      %'import'
    =/  raw=(list json)  ((ar:dejs:format same) (~(got by obj) 'entries'))
    =/  entries=(list [tag=@tas key=(unit @t) content=@t])
      %+  turn  raw
      |=  j=json
      =/  o=(map @t json)  ((om:dejs:format same) j)
      =/  tag=@tas  (json-to-tag (~(got by o) 'tag'))
      =/  key=(unit @t)  (json-to-key (~(get by o) 'key'))
      =/  content=@t  (json-to-cord (~(got by o) 'content'))
      [tag key content]
    [%import entries]
  ==
--
