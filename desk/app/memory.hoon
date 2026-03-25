::  memory: persistent memory agent v2
::  - search: substring match on content, tag, key
::  - upsert: update-if-exists by tag+key
::  - tag/key filtering on HTTP endpoints
::
/-  mem=memory
/+  default-agent, mj=memory-json, srv=server
|%
+$  state-0  [%0 store=(map id:mem entry:mem)]
+$  state-1  [%1 store=(map id:mem entry:mem)]
+$  versioned-state  $%(state-1 state-0)
+$  card  card:agent:gall
--
=|  state-1
=*  state  -
^-  agent:gall
|_  =bowl:gall
+*  this  .
    def   ~(. (default-agent this %|) bowl)
++  on-init
  :_  this
  :~  [%pass /eyre %arvo %e %connect [`/apps/memory dap.bowl]]
  ==
++  on-save  !>(state)
++  on-load
  |=  ole=vase
  ^-  (quip card _this)
  =/  old  !<(versioned-state ole)
  =/  cards=(list card)
    :~  [%pass /eyre %arvo %e %connect [`/apps/memory dap.bowl]]
    ==
  ?-  -.old
      %1  [cards this(state old)]
      %0  [cards this(state [%1 store.old])]
  ==
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?+  mark  (on-poke:def mark vase)
      %memory-action
    =+  !<(act=action:mem vase)
    ?-  -.act
    ::  %put: insert new entry
        %put
      =/  eid=id:mem  `@uv`eny.bowl
      =/  ent=entry:mem  [eid now.bowl now.bowl tag.act key.act content.act]
      =.  store  (~(put by store) eid ent)
      [~ this]
    ::  %upsert: update by tag+key if exists, otherwise insert
        %upsert
      =/  existing=(unit [id:mem entry:mem])
        %-  ~(rep by store)
        |=  [[eid=id:mem e=entry:mem] acc=(unit [id:mem entry:mem])]
        ?^  acc  acc
        ?.  =(tag.e tag.act)  acc
        ?~  key.e  acc
        ?.  =(u.key.e key.act)  acc
        `[eid e]
      ?~  existing
        ::  not found, insert new
        =/  eid=id:mem  `@uv`eny.bowl
        =/  ent=entry:mem  [eid now.bowl now.bowl tag.act `key.act content.act]
        =.  store  (~(put by store) eid ent)
        [~ this]
      ::  found, update in place
      =/  old=entry:mem  +.u.existing
      =/  upd=entry:mem  old(updated now.bowl, content content.act)
      =.  store  (~(put by store) -.u.existing upd)
      [~ this]
    ::  %del: delete by id
        %del
      =.  store  (~(del by store) id.act)
      [~ this]
    ::  %del-key: delete by tag+key match
        %del-key
      =/  to-del=(list id:mem)
        %+  murn  ~(tap by store)
        |=  [eid=id:mem e=entry:mem]
        ?.  =(tag.e tag.act)  ~
        ?~  key.e  ~
        ?.  =(u.key.e key.act)  ~
        `eid
      |-
      ?~  to-del  [~ this]
      =.  store  (~(del by store) i.to-del)
      $(to-del t.to-del)
    ::  %wipe: delete all entries with tag
        %wipe
      =/  to-del=(list id:mem)
        (turn (skim ~(val by store) |=(e=entry:mem =(tag.e tag.act))) |=(e=entry:mem id.e))
      |-
      ?~  to-del  [~ this]
      =.  store  (~(del by store) i.to-del)
      $(to-del t.to-del)
    ::  %import: bulk insert
        %import
      =/  ents=(list [tag=@tas key=(unit @t) content=@t])  entries.act
      |-
      ?~  ents  [~ this]
      =/  [tg=@tas ky=(unit @t) cnt=@t]  i.ents
      =/  eid=id:mem  `@uv`(mix eny.bowl (jam [tg ky]))
      =/  ent=entry:mem  [eid now.bowl now.bowl tg ky cnt]
      =.  store  (~(put by store) eid ent)
      $(ents t.ents)
    ==
  ::  HTTP requests
      %handle-http-request
    =+  !<([eyre-id=@ta req=inbound-request:eyre] vase)
    =/  rl=request-line:srv  (parse-request-line:srv url.request.req)
    ::  parse query string params
    =/  params=(map @t @t)
      %-  ~(gas by *(map @t @t))
      (turn args.rl |=([k=@t v=@t] [k v]))
    ?+  site.rl
      :_  this
      (give-simple-payload:app:srv eyre-id [[404 ~] ~])
    ::
    ::  GET /apps/memory/api/entries?tag=X&key=Y&q=Z&limit=N
    ::
        [%apps %memory %api %entries ~]
      =/  all-es=(list entry:mem)  ~(val by store)
      ::  filter by tag if provided
      =/  ftag=(unit @t)  (~(get by params) 'tag')
      =?  all-es  ?=(^ ftag)
        (skim all-es |=(e=entry:mem =(tag.e (slav %tas u.ftag))))
      ::  filter by key if provided
      =/  fkey=(unit @t)  (~(get by params) 'key')
      =?  all-es  ?=(^ fkey)
        %+  skim  all-es
        |=  e=entry:mem
        ?~  key.e  |
        =(u.key.e u.fkey)
      ::  filter by search query if provided (substring match on content)
      =/  fq=(unit @t)  (~(get by params) 'q')
      =?  all-es  ?=(^ fq)
        =/  needle=tape  (cass (trip u.fq))
        %+  skim  all-es
        |=  e=entry:mem
        =/  haystack=tape  (cass (trip content.e))
        !=(~ (find needle haystack))
      ::  sort by updated desc
      =/  sorted=(list entry:mem)
        (sort all-es |=([a=entry:mem b=entry:mem] (gth updated.a updated.b)))
      ::  apply limit if provided
      =/  flim=(unit @t)  (~(get by params) 'limit')
      =?  sorted  ?=(^ flim)
        =/  n=@ud  (slav %ud u.flim)
        (scag n sorted)
      =/  bod=octs  (json-to-octs:srv (entries-to-json:mj sorted))
      :_  this
      %+  give-simple-payload:app:srv  eyre-id
      :_  `bod
      [200 [['content-type' 'application/json'] ['access-control-allow-origin' '*'] ~]]
    ::
    ::  GET /apps/memory/api/search?q=X&tag=Y&limit=N
    ::  dedicated search endpoint — searches content, tag, and key
    ::
        [%apps %memory %api %search ~]
      =/  fq=(unit @t)  (~(get by params) 'q')
      ?~  fq
        :_  this
        %+  give-simple-payload:app:srv  eyre-id
        :_  ~
        [400 ~]
      =/  needle=tape  (cass (trip u.fq))
      =/  all-es=(list entry:mem)  ~(val by store)
      ::  filter by tag if provided
      =/  ftag=(unit @t)  (~(get by params) 'tag')
      =?  all-es  ?=(^ ftag)
        (skim all-es |=(e=entry:mem =(tag.e (slav %tas u.ftag))))
      ::  search across content, tag name, and key
      =/  matches=(list entry:mem)
        %+  skim  all-es
        |=  e=entry:mem
        ?|  !=(~ (find needle (cass (trip content.e))))
            !=(~ (find needle (cass (trip (scot %tas tag.e)))))
            ?&  ?=(^ key.e)
                !=(~ (find needle (cass (trip u.key.e))))
            ==
        ==
      ::  sort by updated desc
      =/  sorted=(list entry:mem)
        (sort matches |=([a=entry:mem b=entry:mem] (gth updated.a updated.b)))
      ::  apply limit
      =/  flim=(unit @t)  (~(get by params) 'limit')
      =?  sorted  ?=(^ flim)
        =/  n=@ud  (slav %ud u.flim)
        (scag n sorted)
      =/  bod=octs  (json-to-octs:srv (entries-to-json:mj sorted))
      :_  this
      %+  give-simple-payload:app:srv  eyre-id
      :_  `bod
      [200 [['content-type' 'application/json'] ['access-control-allow-origin' '*'] ~]]
    ::
    ::  GET /apps/memory/api/tags
    ::
        [%apps %memory %api %tags ~]
      =/  tags=(set @tas)
        (silt (turn ~(val by store) |=(e=entry:mem tag.e)))
      =/  bod=octs  (json-to-octs:srv (tags-to-json:mj tags))
      :_  this
      %+  give-simple-payload:app:srv  eyre-id
      :_  `bod
      [200 [['content-type' 'application/json'] ['access-control-allow-origin' '*'] ~]]
    ::
    ::  GET /apps/memory/api/stats
    ::
        [%apps %memory %api %stats ~]
      =/  count=@ud  ~(wyt by store)
      =/  tags=(set @tas)
        (silt (turn ~(val by store) |=(e=entry:mem tag.e)))
      =/  tag-count=@ud  ~(wyt in tags)
      =/  bod=octs
        %-  json-to-octs:srv
        %-  pairs:enjs:format
        :~  ['entries' (numb:enjs:format count)]
            ['tags' (numb:enjs:format tag-count)]
        ==
      :_  this
      %+  give-simple-payload:app:srv  eyre-id
      :_  `bod
      [200 [['content-type' 'application/json'] ['access-control-allow-origin' '*'] ~]]
    ==
  ==
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?+  path  (on-watch:def path)
      [%http-response *]  [~ this]
  ==
++  on-agent  |=([=wire =sign:agent:gall] (on-agent:def wire sign))
++  on-peek
  |=  =path
  ^-  (unit (unit cage))
  ?+  path  [~ ~]
      [%x %entries %all ~]
    =/  es=(list entry:mem)
      (sort ~(val by store) |=([a=entry:mem b=entry:mem] (gth updated.a updated.b)))
    ``json+!>((entries-to-json:mj es))
      [%x %tags ~]
    =/  tags=(set @tas)
      (silt (turn ~(val by store) |=(e=entry:mem tag.e)))
    ``json+!>((tags-to-json:mj tags))
  ==
++  on-arvo
  |=  [=wire =sign-arvo]
  ^-  (quip card _this)
  ?+  wire  (on-arvo:def wire sign-arvo)
      [%eyre ~]
    ?>  ?=([%eyre %bound *] sign-arvo)
    [~ this]
  ==
++  on-leave  on-leave:def
++  on-fail   on-fail:def
--
