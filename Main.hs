{-# language TemplateHaskell #-}

module Main (main) where

import FileEmbedLzma

foo = $(embedText "foo.txt")

main :: IO ()
main = putStrLn foo
