{-# language TemplateHaskell #-}

module Main (main) where

import FileEmbedLzma
import qualified Data.ByteString.Lazy as ByteString
import qualified Codec.Compression.GZip as GZip

main :: IO ()
main = do
  print $(embedText "foo.txt")
  ByteString.interact GZip.compress
