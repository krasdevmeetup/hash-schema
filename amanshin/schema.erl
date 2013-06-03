-module(schema).
-export([transform/2, test/0]).

transform(Input, Schema) ->
  transform(Input, Schema, []).

transform(Input, [ { Key, [ Keys ] } | Tail ], Acc0) ->
  Value = proplists:get_value(Key, Input, undefined),
  Acc1 = [{ Key, [ transform(Elem, Keys, []) || Elem <- Value ] } | Acc0],
  transform(Input, Tail, Acc1);

transform(Input, [ { Key, Keys } | Tail ], Acc0) ->
  Value = proplists:get_value(Key, Input, undefined),
  Acc1 = [{ Key, transform(Value, Keys, []) } | Acc0],
  transform(Input, Tail, Acc1);

transform(Input, [ Key | Tail ], Acc0) ->
  Value = proplists:get_value(Key, Input, undefined),
  Acc1 = [{ Key, Value } | Acc0],
  transform(Input, Tail, Acc1);

transform(_Input, [], Acc) ->
  lists:reverse(Acc).

%%%

test() ->
  Expected = output(),
  Expected = transform(input(), schema()),
  ok.

input() ->
  [
    { <<"aaa">>, <<"22">> },
    { <<"aaaa">>, <<"New 22">> },
    { <<"bbb">>, <<"434">> },
    { <<"ccc">>, [
      { <<"ddd">>, <<"abc">> },
      { <<"ddddd">>, <<"Not needed">> },
      { <<"ggg">>, <<"Needed">> },
      { <<"hard_to_believe">>, [] }
    ] },
    { <<"zzz">>, [
      [
        { <<"hhh">>, <<"126">> },
        { <<"hhhh">>, <<"Don't need">> },
        { <<"kkk">>, <<"Existing key">> }
      ],
      [
        { <<"hhh">>, <<"DoobyDo">> },
        { <<"kkk">>, <<"Needed">> },
        { <<"mmm">>, <<"Existing key">> }
      ]
    ] }
  ].

schema() ->
  [
    <<"aaa">>,
    <<"bbb">>,
    <<"ooo">>,
    { <<"ccc">>, [ <<"ddd">>, <<"ggg">> ] },
    { <<"zzz">>, [[ <<"hhh">>, <<"kkk">>, <<"mmm">> ]] }
  ].

output() ->
  [
    { <<"aaa">>, <<"22">> },
    { <<"bbb">>, <<"434">> },
    { <<"ooo">>, undefined },
    { <<"ccc">>, [
      { <<"ddd">>, <<"abc">> },
      { <<"ggg">>, <<"Needed">> }
    ] },
    { <<"zzz">>, [
      [
        { <<"hhh">>, <<"126">> },
        { <<"kkk">>, <<"Existing key">> },
        { <<"mmm">>, undefined }
      ],
      [
        { <<"hhh">>, <<"DoobyDo">> },
        { <<"kkk">>, <<"Needed">> },
        { <<"mmm">>, <<"Existing key">> }
      ]
    ] }
  ].
