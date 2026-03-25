::  memory: persistent memory agent for OpenClaw
::
/-  mem=memory
/+  default-agent, mj=memory-json, srv=server
|%
+$  state-0  [%0 store=(map id:mem entry:mem)]
+$  versioned-state  $%(state-0)
+$  card  card:agent:gall
--
=|  state-0
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
  ?-  -.old
      %0
    :_  this(state old)
    :~  [%pass /eyre %arvo %e %connect [`/apps/memory dap.bowl]]
    ==
  ==
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?+  mark  (on-poke:def mark vase)
      %memory-action
    =+  !<(act=action:mem vase)
    ?-  -.act
        %put
      =/  eid=id:mem  `@uv`eny.bowl
      =/  ent=entry:mem  [eid now.bowl now.bowl tag.act key.act content.act]
      =.  store  (~(put by store) eid ent)
      [~ this]
        %del
      =.  store  (~(del by store) id.act)
      [~ this]
        %del-key  [~ this]
        %wipe
      =/  to-del=(list id:mem)
        (turn (skim ~(val by store) |=(e=entry:mem =(tag.e tag.act))) |=(e=entry:mem id.e))
      =.  store
        |-
        ?~  to-del  store
        $(to-del t.to-del, store (~(del by store) i.to-del))
      [~ this]
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
      %handle-http-request
    =+  !<([eyre-id=@ta req=inbound-request:eyre] vase)
    =/  rl=request-line:srv  (parse-request-line:srv url.request.req)
    ?+  site.rl
      :_  this
      (give-simple-payload:app:srv eyre-id [[404 ~] ~])
        [%apps %memory %api %entries ~]
      =/  es=(list entry:mem)
        (sort ~(val by store) |=([a=entry:mem b=entry:mem] (gth updated.a updated.b)))
      =/  bod=octs  (json-to-octs:srv (entries-to-json:mj es))
      :_  this
      %+  give-simple-payload:app:srv  eyre-id
      :_  `bod
      [200 [['content-type' 'application/json'] ~]]
        [%apps %memory %api %tags ~]
      =/  tags=(set @tas)
        (silt (turn ~(val by store) |=(e=entry:mem tag.e)))
      =/  bod=octs  (json-to-octs:srv (tags-to-json:mj tags))
      :_  this
      %+  give-simple-payload:app:srv  eyre-id
      :_  `bod
      [200 [['content-type' 'application/json'] ~]]
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
