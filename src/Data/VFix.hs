{-# language DeriveFunctor, DeriveFoldable, DeriveTraversable #-}
{-# language DataKinds, KindSignatures #-}
{-# language FlexibleInstances #-}
{-# language MultiParamTypeClasses, TemplateHaskell, TypeFamilies #-}
{-# language StandaloneDeriving #-}
{-# language UndecidableInstances #-}
module Data.VFix where

import Control.Lens.Plated (Plated(..))
import Control.Lens.TH (makeWrapped)
import Data.String (IsString(..))

import Data.VFunctor
import Data.VTraversable

newtype VFix (f :: ([*] -> * -> *) -> ([*] -> * -> *)) (v :: [*]) (a :: *)
  = VIn { vout :: f (VFix f) v a }
deriving instance (Eq a, Eq (f (VFix f) v a)) => Eq (VFix f v a)
deriving instance (Show a, Show (f (VFix f) v a)) => Show (VFix f v a)
deriving instance (Functor (f (VFix f) v)) => Functor (VFix f v)
deriving instance (Foldable (f (VFix f) v)) => Foldable (VFix f v)
deriving instance (Traversable (f (VFix f) v)) => Traversable (VFix f v)

instance VTraversable f => Plated (VFix f '[] a) where
  plate f (VIn a) = VIn <$> vtraverse f a

instance IsString (e (VFix e) v a) => IsString (VFix e v a) where
  fromString = VIn . fromString

vcata :: VFunctor f => (f e v a -> e v a) -> VFix f v a -> e v a
vcata alg = go
  where
    go = alg . vfmap go . vout

makeWrapped ''VFix
