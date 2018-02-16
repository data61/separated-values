{-# LANGUAGE DeriveFunctor #-}
{-# LANGUAGE DeriveFoldable #-}
{-# LANGUAGE DeriveTraversable #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE TupleSections #-}

import Control.DeepSeq
import Control.Lens
import Criterion.Main
import Data.ByteString (ByteString)
import qualified Data.ByteString as BS
import GHC.Generics
import System.Exit (exitFailure)

import Data.Sv
import qualified Data.Sv.Decode as D
import Data.Sv.Random

data BenchData a =
  BenchData {
    f1 :: a
  , f10 :: a
  , f100 :: a
  , f500 :: a
  , f1000 :: a
  , f5000 :: a
  , f10000 :: a
  , f50000 :: a
  , f100000 :: a
  }
  deriving (Eq, Ord, Show, Functor, Foldable, Traversable, Generic)

instance NFData a => NFData (BenchData a) where

data BDIx = F1 | F10 | F100 | F500 | F1000 | F5000 | F10000 | F50000 | F100000

ix2n bdix = case bdix of
  F1 -> 1
  F10 -> 10
  F100 -> 100
  F500 -> 500
  F1000 -> 1000
  F5000 -> 5000
  F10000 -> 10000
  F50000 -> 50000
  F100000 -> 100000

ixs :: BenchData BDIx
ixs = BenchData F1 F10 F100 F500 F1000 F5000 F10000 F50000 F100000

inds :: BenchData Int
inds = fmap ix2n ixs

loadFile :: Int -> IO (ByteString)
loadFile n = BS.readFile ("benchmarks/csv/" ++ show n ++ ".csv")

bdFs :: IO (BenchData ByteString)
bdFs = traverse loadFile inds

bdFs' :: IO (BenchData (Sv ByteString))
bdFs' = traverse sanity =<< bdFs

opts :: ParseOptions
opts = defaultParseOptions & headedness .~ Unheaded & parsingLib .~ Attoparsec

parse :: ByteString -> DecodeValidation ByteString (Sv ByteString)
parse = D.parse (Just opts)

dec :: Sv ByteString -> DecodeValidation ByteString [Row]
dec = D.decode rowDec

parseDec :: ByteString -> DecodeValidation ByteString [Row]
parseDec = D.parseDecode rowDec (Just opts)

failOnError :: Show e => DecodeValidation e a -> IO a
failOnError v = case v of
  AccFailure e -> do
      putStr "Sanity check failed: "
      print e
      exitFailure
  AccSuccess s -> pure s

sanity :: ByteString -> IO (Sv ByteString)
sanity bs = do
  s <- failOnError (parse bs)
  _ <- failOnError (dec s)
  s `seq` pure s


main :: IO ()
main = do
  defaultMain
      [ env bdFs $ \ bs -> bgroup "Parse" [
          bench "1" $ whnf parse (f1 bs)
        , bench "10" $ whnf parse (f10 bs)
        , bench "100" $ whnf parse (f100 bs)
        , bench "500" $ whnf parse (f500 bs)
        , bench "1000" $ whnf parse (f1000 bs)
        , bench "5000" $ whnf parse (f5000 bs)
        , bench "10000" $ whnf parse (f10000 bs)
        , bench "50000" $ whnf parse (f50000 bs)
        , bench "100000" $ whnf parse (f100000 bs)
        ]

      , env bdFs' $ \ bs -> bgroup "Decode" [
          bench "1" $ whnf dec (f1 bs)
        , bench "10" $ whnf dec (f10 bs)
        , bench "100" $ whnf dec (f100 bs)
        , bench "500" $ whnf dec (f500 bs)
        , bench "1000" $ whnf dec (f1000 bs)
        , bench "5000" $ whnf dec (f5000 bs)
        , bench "10000" $ whnf dec (f10000 bs)
        , bench "50000" $ whnf dec (f50000 bs)
        , bench "100000" $ whnf dec (f100000 bs)
        ]

      , env bdFs $ \ bs -> bgroup "Parse and decode" [
          bench "1" $ whnf parseDec (f1 bs)
        , bench "10" $ whnf parseDec (f10 bs)
        , bench "100" $ whnf parseDec (f100 bs)
        , bench "500" $ whnf parseDec (f500 bs)
        , bench "1000" $ whnf parseDec (f1000 bs)
        , bench "5000" $ whnf parseDec (f5000 bs)
        , bench "10000" $ whnf parseDec (f10000 bs)
        , bench "50000" $ whnf parseDec (f50000 bs)
        , bench "100000" $ whnf parseDec (f100000 bs)
        ]
      ]