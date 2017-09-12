{ mkDerivation, base, bifunctors, charset, hedgehog, lens, parsec
, parsers, QuickCheck, semigroupoids, semigroups, separated, stdenv
, tasty, tasty-hedgehog, tasty-hunit, tasty-quickcheck, text, text1
}:
mkDerivation {
  pname = "sv";
  version = "0.1.0.0";
  src = ./.;
  libraryHaskellDepends = [
    base bifunctors charset lens parsers semigroupoids semigroups
    separated text text1
  ];
  testHaskellDepends = [
    base hedgehog lens parsec parsers QuickCheck semigroups separated
    tasty tasty-hedgehog tasty-hunit tasty-quickcheck text text1
  ];
  homepage = "https://github.com/qfpl/sv";
  description = "Values which are separated, often by commas";
  license = stdenv.lib.licenses.bsd3;
}