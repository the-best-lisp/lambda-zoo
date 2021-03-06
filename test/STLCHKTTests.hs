module STLCHKTTests where

import Test.Tasty
import Test.Tasty.HUnit

import Abt.Class
import Abt.Types
import Abt.Concrete.LocallyNameless

import Util
import STLCHKT


stlchktTests = testGroup "STLCHKT"
  [ testCase "false has the bool type" $ do
      judge $ checkTy [] false bool

  , testCase "bool identity has the type (bool -> bool)" $ do
      judge $ do
        x <- named "x"
        checkTy [] (lam bool (x \\ var x)) (arrow bool bool)

  , testCase "application is well typed" $ do
      judge $ do
        x <- named "x"
        let tm = (app (lam bool (x \\ var x)) true)
        checkTy [] tm bool

  , testCase "eval works fine" $ do
      let result = runM $ do
            x <- named "x"
            let tm = app (lam bool (x \\ false)) true
            return $ (eval tm) === false

      assertBool "" result

  , testCase "if_then_else works fine" $ do
      let result = runM $ do
            x <- named "x"
            let tm = if_ true false true
            return $ (eval tm) === false

      assertBool "" result

  , testCase "arrow type with variable" $ do
      judge $ do
        x <- named "x"
        a <- named "a"
        let tm = (lam (var a) (x \\ (var x)))
        checkTy [] tm (arrow (var a) (var a))

  , testCase "type application works fine" $ do
      result <- judge $ do
        x <- named "x"
        let tm1 = (tlam kind (x \\ bool))
        let tm2 = (tapp tm1 nat)
        checkTy [] tm2 kind
        return $ (eval tm2) === bool

      assertBool "" result
  ]