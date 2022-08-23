defmodule Tokenizer do
  @moduledoc """
  Mini Tokenizer for Tensorflow lite's mobileBert example.
  """

  defstruct dic1: nil,      # dictionary for whole words or begining of a word.
              dic2: nil,      # dictionary for subsequent parts of word.
              tolower: false  # lowercase flag

  @doc """
  Load a vocabulary dictionary.
  """
  def new(fname, tolower \\ false) do
    dic1 = :ets.new(:dic1, [])
    dic2 = :ets.new(:dic2, [])

    File.stream!(fname)
    |> Stream.map(&String.trim_trailing/1)
    |> Stream.with_index()
    |> Enum.each(fn {word, index} ->
      case word do
        <<"##", trailing::binary>> -> :ets.insert(dic2, {trailing, index})
        _ -> :ets.insert(dic1, {word, index})
      end
    end)

    %Tokenizer{
      dic1: dic1,
      dic2: dic2,
      tolower: tolower
    }
  end

  @doc """
  Tokenize text.
  """
  def tokenize(%Tokenizer{}=tok, text) do
    if tok.tolower do String.downcase(text) else text end
    |> split2words()
    |> Enum.reduce([], fn word,acc ->
         if :ets.member(tok.dic1, word) do
           # shortcust for words in tok.dic1.
           [word|acc]
         else case wordpiece1(tok.dic1, word, String.length(word)-1) do
         nil ->
           # any beginning part of word was not found in tok.dic1.
           ["[UNK]"|acc]
         piece ->
           word = String.trim_leading(word, piece)
           wordpiece2(tok.dic2, word, String.length(word), [piece|acc])
         end end
    end)
    |> Enum.reverse()
  end

  defp split2words(text) do
    text
    # cleansing
    |> String.replace(~r/[[:space:]]/, " ")
    |> String.replace(~r/([[:cntrl:]]|\xff\xfd)/, "")
    # separate panc with whitespace
    |> String.replace(~r/([[:punct:]])/, " \\1 ")
    # split with whitespace
    |> String.split()
  end

  defp wordpiece1(_, _, 0), do: nil
  defp wordpiece1(dic, word, n) do
    piece = String.slice(word, 0, n)
    if :ets.member(dic, piece) do
      piece
    else
      wordpiece1(dic, word, n-1)
    end
  end

  defp wordpiece2(_dic, "", _, words), do: words
  defp wordpiece2(_dic, _,  0, words), do: ["[UNK]"|words]
  defp wordpiece2(dic, word, n, words) do
    piece = String.slice(word, 0, n)
    if :ets.member(dic, piece) do
      word = String.trim_leading(word, piece)
      wordpiece2(dic, word, String.length(word), ["##"<>piece|words])
    else
      wordpiece2(dic, word, n-1, words)
    end
  end
end
