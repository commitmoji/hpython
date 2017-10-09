{-# language PolyKinds #-}
module Test.Language.Python.Gen.IndentedLines where

import Papa
import Hedgehog
import qualified Hedgehog.Gen as Gen
import qualified Hedgehog.Range as Range

import qualified Data.List.NonEmpty as NE

import Language.Python.AST.IndentedLines
import Test.Language.Python.Gen.Combinators

genIndentedLines :: MonadGen m => Range Int -> m (s lctxt ctxt a) -> m (IndentedLines (s lctxt ctxt a))
genIndentedLines r gen = do
  sts <- Gen.nonEmpty r gen
  let lineGen =
        Gen.nonEmpty
          (Range.singleton $ length sts)
          (Gen.nonEmpty (Range.linear 1 30) genIndentationChar)
  Gen.just
    (preview _Right . mkIndentedLines <$> liftA2 NE.zip lineGen (pure sts))
