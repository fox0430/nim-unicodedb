## This module provides scripts values:
## sptCommon, sptLatin, etc

import unicode

import scripts_data

export
  UnicodeScript,
  sptCommon,
  sptLatin,
  sptBopomofo,
  sptInherited,
  sptGreek,
  sptCoptic,
  sptCyrillic,
  sptArmenian,
  sptHebrew,
  sptArabic,
  sptSyriac,
  sptThaana,
  sptNko,
  sptSamaritan,
  sptMandaic,
  sptDevanagari,
  sptBengali,
  sptGurmukhi,
  sptGujarati,
  sptOriya,
  sptTamil,
  sptTelugu,
  sptKannada,
  sptMalayalam,
  sptSinhala,
  sptThai,
  sptLao,
  sptTibetan,
  sptMyanmar,
  sptGeorgian,
  sptHangul,
  sptEthiopic,
  sptCherokee,
  sptCanadianAboriginal,
  sptOgham,
  sptRunic,
  sptTagalog,
  sptHanunoo,
  sptBuhid,
  sptTagbanwa,
  sptKhmer,
  sptMongolian,
  sptLimbu,
  sptTaiLe,
  sptNewTaiLue,
  sptBuginese,
  sptTaiTham,
  sptBalinese,
  sptSundanese,
  sptBatak,
  sptLepcha,
  sptOlChiki,
  sptBraille,
  sptGlagolitic,
  sptTifinagh,
  sptHan,
  sptHiragana,
  sptKatakana,
  sptYi,
  sptLisu,
  sptVai,
  sptBamum,
  sptSylotiNagri,
  sptPhagsPa,
  sptSaurashtra,
  sptKayahLi,
  sptRejang,
  sptJavanese,
  sptCham,
  sptTaiViet,
  sptMeeteiMayek,
  sptLinearB,
  sptLycian,
  sptCarian,
  sptOldItalic,
  sptGothic,
  sptOldPermic,
  sptUgaritic,
  sptOldPersian,
  sptDeseret,
  sptShavian,
  sptOsmanya,
  sptOsage,
  sptElbasan,
  sptCaucasianAlbanian,
  sptLinearA,
  sptCypriot,
  sptImperialAramaic,
  sptPalmyrene,
  sptNabataean,
  sptHatran,
  sptPhoenician,
  sptLydian,
  sptMeroiticHieroglyphs,
  sptMeroiticCursive,
  sptKharoshthi,
  sptOldSouthArabian,
  sptOldNorthArabian,
  sptManichaean,
  sptAvestan,
  sptInscriptionalParthian,
  sptInscriptionalPahlavi,
  sptPsalterPahlavi,
  sptOldTurkic,
  sptOldHungarian,
  sptHanifiRohingya,
  sptOldSogdian,
  sptSogdian,
  sptBrahmi,
  sptKaithi,
  sptSoraSompeng,
  sptChakma,
  sptMahajani,
  sptSharada,
  sptKhojki,
  sptMultani,
  sptKhudawadi,
  sptGrantha,
  sptNewa,
  sptTirhuta,
  sptSiddham,
  sptModi,
  sptTakri,
  sptAhom,
  sptDogra,
  sptWarangCiti,
  sptZanabazarSquare,
  sptSoyombo,
  sptPauCinHau,
  sptBhaiksuki,
  sptMarchen,
  sptMasaramGondi,
  sptGunjalaGondi,
  sptMakasar,
  sptCuneiform,
  sptEgyptianHieroglyphs,
  sptAnatolianHieroglyphs,
  sptMro,
  sptBassaVah,
  sptPahawhHmong,
  sptMedefaidrin,
  sptMiao,
  sptTangut,
  sptNushu,
  sptDuployan,
  sptSignWriting,
  sptMendeKikakui,
  sptAdlam,
  sptElymaic,
  sptNandinagari,
  sptNyiakengPuachueHmong,
  sptWancho

proc unicodeScript*(cp: Rune): UnicodeScript {.inline.} =
  ## Return script for a given code point
  assert cp.int <= 0x10FFFF
  let blockOffset = (typesIndices[cp.int div blockSize]).int * blockSize
  result = typesData[blockOffset + cp.int mod blockSize].UnicodeScript

proc `==`*(a, b: UnicodeScript): bool {.inline.} =
  a.int == b.int