## This module provides characters
## names lookup and retrieval

import unicode
import strutils

import names_data

const
  SBase = 0xAC00
  LCount = 19
  VCount = 21
  TCount = 28
  NCount = VCount * TCount  # 588
  SCount = LCount * NCount  # 1117
  jamoLTable = [
    "G", "GG", "N", "D", "DD", "R", "M", "B", "BB",
    "S", "SS", "", "J", "JJ", "C", "K", "T", "P", "H"
  ]
  jamoVTable = [
    "A", "AE", "YA", "YAE", "EO", "E", "YEO", "YE", "O",
    "WA", "WAE", "OE", "YO", "U", "WEO", "WE", "WI",
    "YU", "EU", "YI", "I"
  ]
  jamoTTable = [
    "", "G", "GG", "GS", "N", "NJ", "NH", "D", "L", "LG", "LM",
    "LB", "LS", "LT", "LP", "LH", "M", "B", "BS",
    "S", "SS", "NG", "J", "C", "K", "T", "P", "H"
  ]

proc hangulName(s: int): string {.inline, raises: [].} =
  ## Hangul name generator. Implementation based on
  ## Unicode standard 10 - Chapter 3
  let SIndex = s - SBase
  assert(not (0 > SIndex or SIndex >= SCount))  # Is hangul
  let
    LIndex = SIndex div NCount
    VIndex = (SIndex mod NCount) div TCount
    TIndex = SIndex mod TCount
  result = "HANGUL SYLLABLE "
  result.add(jamoLTable[LIndex])
  result.add(jamoVTable[VIndex])
  result.add(jamoTTable[TIndex])

type
  EPrefixNames {.pure.} = enum
    ## A type for special character ranges
    ## that must generate their name
    ## based on certain rules.
    ## Based on Unicode standard 10 - Chapter 4.8
    Hangul, CJKU, Tangut, Nushu, CJKC
const
  prefixNames: array[EPrefixNames, string] = [
    "hangul syllable ".toUpperAscii(),
    "cjk unified ideograph-".toUpperAscii(),
    "tangut ideograph-".toUpperAscii(),
    "nushu character-".toUpperAscii(),
    "cjk compatibility ideograph-".toUpperAscii()
  ]
  prefixRanges = [
    (first: 0xAC00, last: 0xD7A3, name: EPrefixNames.Hangul),
    (first: 0x3400, last: 0x4DB5, name: EPrefixNames.CJKU),
    (first: 0x4E00, last: 0x9FEA, name: EPrefixNames.CJKU),
    (first: 0x20000, last: 0x2A6D6, name: EPrefixNames.CJKU),
    (first: 0x2A700, last: 0x2B734, name: EPrefixNames.CJKU),
    (first: 0x2B740, last: 0x2B81D, name: EPrefixNames.CJKU),
    (first: 0x2B820, last: 0x2CEA1, name: EPrefixNames.CJKU),
    (first: 0x2CEB0, last: 0x2EBE0, name: EPrefixNames.CJKU),
    (first: 0x17000, last: 0x187EC, name: EPrefixNames.Tangut),
    (first: 0x1B170, last: 0x1B2FB, name: EPrefixNames.Nushu),
    (first: 0xF900, last: 0xFA6D, name: EPrefixNames.CJKC),
    (first: 0xFA70, last: 0xFAD9, name: EPrefixNames.CJKC),
    (first: 0x2F800, last: 0x2FA1D, name: EPrefixNames.CJKC)
  ]

proc formatHex(cp: int): string {.inline, raises: [].} =
  result = toHex(cp).strip(
    chars = {'0'},
    trailing = false)

proc getNameInPrefixRange(cp: int): string {.inline, raises: [].} =
  result = ""
  for pr in prefixRanges:
    if pr.first <= cp and cp <= pr.last:
      result = prefixNames[pr.name]
      result.add(formatHex(cp))
      break

proc name*(cp: int): string {.raises: [].} =
  ## Return the name for a given code point.
  ## An empty string is returned if the code
  ## point does not has a name
  assert cp <= 0x10FFFF
  if 0xAC00 <= cp and cp <= 0xD7A3:
    return hangulName(cp)

  let prName = getNameInPrefixRange(cp)
  if prName.len > 0:
    return prName

  let
    blockOffset = int(namesOffsets[cp div blockSize]) * blockSize
    idx = namesIndices[blockOffset + cp mod blockSize]
  if idx == -1:
    return ""
  let length = namesTable[idx]
  result = newString(length)
  var
    i = 0
    j = 1
    k = 0
  while true:
    let wordOffset = wordsOffsets[namesTable[idx + j]]
    k = 0
    while true:
      assert i <= length
      let letter = wordsData[wordOffset + k]
      if letter == 0:
        break
      result[i] = char(letter)
      inc i
      inc k
    if i >= length:
      break
    result[i] = ' '
    inc i  # inc space
    inc j
  assert i == length

proc name*(cp: Rune): string {.inline, raises: [].} =
  ## Return the name for a given rune.
  ## An empty string is returned if the
  ## rune does not has a name
  name(int(cp))

proc fnv32a(key: string, seed: int): int {.inline, raises: [].} =
  ## Calculates a distinct hash function for a given sequence
  ## FNV algorithm from http://isthe.com/chongo/tech/comp/fnv/
  const
    fnv32Prime = 16777619
    int32Max = int32.high

  result = 18652614  # -> 2166136261 mod int32Max
  if seed > 0:
    result = seed

  for s in key:
    result = result xor ord(s)
    result = (result * fnv32Prime) mod int32Max

proc mphLookup(key: string): int {.inline, raises: [].} =
  ## Based on minimal perfect hashing algorithm
  let d = int(namesHashes[fnv32a(key, 0) mod namesHashes.len])
  result = namesValues[fnv32a(key, d) mod namesValues.len]

# todo: proc lookup*(cpName: string, loose = true): Rune =

proc lookupStrict*(cpName: string): Rune {.raises: [KeyError].} =
  ## Return a rune given its name.
  ## It does a strict matching (i.e not loose).
  ## Raise `KeyError` if not found
  # todo: loose matching: see http://www.unicode.org/reports/tr44/#Matching_Names
  #       requires a second hashes array for the loose mathing
  # todo: support name aliases
  var cp = 0
  for ei, pn in prefixNames:
    if ei == EPrefixNames.Hangul:
      continue
    if cpName.startsWith(pn):
      let rawCp = cpName[pn.len .. cpName.len]
      try:
        cp = parseHexInt("0x$#" % rawCp)
      except ValueError:
        raise newException(KeyError, "Name not found")
      if cp == -1:  # Hex out of range
        raise newException(KeyError, "Name not found")
      if formatHex(cp) != rawCp:
        raise newException(KeyError, "Name not found")
      return Rune(cp)

  cp = mphLookup(cpName)
  if cpName != name(cp):
    raise newException(KeyError, "Name not found")
  result = Rune(cp)
