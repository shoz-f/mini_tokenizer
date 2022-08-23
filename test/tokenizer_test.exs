defmodule TokenizerTest do
  use ExUnit.Case
  doctest Tokenizer

  test "load dictionary" do
    tok = Tokenizer.new("test/vocab.txt", true)
    assert :ets.member(tok.dic1, "[PAD]")
    assert :ets.member(tok.dic2, "man")
    assert tok.tolower == true
  end

  test "tokenize" do
    tok = Tokenizer.new("test/vocab.txt", true)
    txt = File.read!("test/passage.txt")
    res = Tokenizer.tokenize(tok, txt) |> Enum.join(":")
    assert res == """
      google:llc:is:an:american:multinational:technology:company:that:specializ\
      es:in:internet:-:related:services:and:products:,:which:include:online:adv\
      ertising:technologies:,:search:engine:,:cloud:computing:,:software:,:and:\
      hardware:.:it:is:considered:one:of:the:big:four:technology:companies:,:al\
      ongside:amazon:,:apple:,:and:facebook:.:google:was:founded:in:september:1\
      998:by:larry:page:and:sergey:br:##in:while:they:were:ph:.:d:.:students:at\
      :stanford:university:in:california:.:together:they:own:about:14:percent:o\
      f:its:shares:and:control:56:percent:of:the:stock:##holder:voting:power:th\
      rough:super:##vot:##ing:stock:.:they:incorporated:google:as:a:california:\
      privately:held:company:on:september:4:,:1998:,:in:california:.:google:was\
      :then:rein:##corp:##ora:##ted:in:delaware:on:october:22:,:2002:.:an:initi\
      al:public:offering:(:ip:##o:):took:place:on:august:19:,:2004:,:and:google\
      :moved:to:its:headquarters:in:mountain:view:,:california:,:nicknamed:the:\
      google:##plex:.:in:august:2015:,:google:announced:plans:to:re:##org:##ani\
      :##ze:its:various:interests:as:a:conglomerate:called:alphabet:inc:.:googl\
      e:is:alphabet:':s:leading:subsidiary:and:will:continue:to:be:the:umbrella\
      :company:for:alphabet:':s:internet:interests:.:sun:##dar:pic:##hai:was:ap\
      pointed:ceo:of:google:,:replacing:larry:page:who:became:the:ceo:of:alphab\
      et:.\
      """
  end
end
