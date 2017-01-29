module Parser.ModuleTests exposing (..)

import AST.Types as Types exposing (emptyRange)
import Expect
import Parser.CombineTestUtil exposing (..)
import Parser.Modules as Parser
import Test exposing (..)


all : Test
all =
    describe "ModuleTests"
        [ test "formatted moduleDefinition" <|
            \() ->
                parseFullStringWithNullState "module Foo exposing (Bar)" Parser.moduleDefinition
                    |> Expect.equal (Just (Types.NormalModule { moduleName = [ "Foo" ], exposingList = Types.Explicit [ Types.DefinitionExpose "Bar" ] }))
        , test "port moduleDefinition" <|
            \() ->
                parseFullStringWithNullState "port module Foo exposing (Bar)" Parser.moduleDefinition
                    |> Expect.equal (Just (Types.PortModule { moduleName = [ "Foo" ], exposingList = Types.Explicit [ Types.DefinitionExpose "Bar" ] }))
        , test "moduleless" <|
            \() ->
                parseFullStringWithNullState "" Parser.moduleDefinition
                    |> Expect.equal (Just Types.NoModule)
        , test "effect moduleDefinition" <|
            \() ->
                parseFullStringWithNullState "effect module Foo where {command = MyCmd, subscription = MySub } exposing (Bar)" Parser.moduleDefinition
                    |> Expect.equal
                        (Just
                            (Types.EffectModule
                                { moduleName = [ "Foo" ]
                                , exposingList = Types.Explicit [ Types.DefinitionExpose "Bar" ]
                                , command = Just "MyCmd"
                                , subscription = Just "MySub"
                                }
                            )
                        )
        , test "unformatted" <|
            \() ->
                parseFullStringWithNullState "module \n Foo \n exposing  (..)" Parser.moduleDefinition
                    |> Expect.equal (Just (Types.NormalModule { moduleName = [ "Foo" ], exposingList = Types.All { start = { row = 3, column = 12 }, end = { row = 3, column = 14 } } }))
        , test "unformatted wrong" <|
            \() ->
                parseFullStringWithNullState "module \nFoo \n exposing  (..)" Parser.moduleDefinition
                    |> Expect.equal Nothing
        , test "exposing all" <|
            \() ->
                parseFullStringWithNullState "module Foo exposing (..)" Parser.moduleDefinition
                    |> Expect.equal (Just (Types.NormalModule { moduleName = [ "Foo" ], exposingList = Types.All { start = { row = 1, column = 21 }, end = { row = 1, column = 23 } } }))
        , test "module name with _" <|
            \() ->
                parseFullStringWithNullState "module I_en_gb exposing (..)" Parser.moduleDefinition
                    |> Expect.equal (Just (Types.NormalModule { moduleName = [ "I_en_gb" ], exposingList = Types.All { start = { row = 1, column = 25 }, end = { row = 1, column = 27 } } }))
        ]