module Lexer where

import Data.List
import Data.Char

type Ide = String

data Token = 
           LParen |
           RParen |
           BinOp Operation | 
           Ide Ide |
           Num Int |
           Equals | 
           Int |
           EOF |
           Other
           deriving (Show, Eq)

data Operation = Plus | Minus | Times | Divide 
               deriving (Show, Eq)

reservedWords = ["int"] :: [String]

mapReserved :: String -> Token
mapReserved w = case w of
                     "int" -> Int

mapOperator :: Char -> Operation
mapOperator '+' = Plus
mapOperator '-' = Minus
mapOperator '*' = Times
mapOperator '/' = Divide

isReserved :: String -> Bool
isReserved = (`elem` reservedWords)

isParen :: Char -> Bool
isParen = (`elem` ['(', ')'])

isBinOp :: Char -> Bool
isBinOp = (`elem` ['+', '-', '*', '/'])

isUnderscore :: Char -> Bool
isUnderscore x = x == '_'

tokenize :: String -> [Token]
tokenize [] = []
tokenize s = tok : tokenize consumed
    where (tok, consumed) = nextToken s

nextToken :: String -> (Token, String)
nextToken [] = (EOF, []) -- Should not ever verify -- 
nextToken ('(':xs) = (LParen, xs)
nextToken (')':xs) = (RParen, xs)
nextToken (x:xs) 
    | isSpace x = nextToken xs
    | isBinOp x = (BinOp (mapOperator x), xs)
    | x == '=' = (Equals, xs)
    | isAlpha x || isUnderscore x = scanIde xs [x]
    | isDigit x = scanNum xs (digitToInt x)
    | otherwise = error $ "Lexical error on character '" ++ [x] ++ "'"

scanIde :: String -> String -> (Token, String)
scanIde [] lexem = (Ide lexem, [])
scanIde all@(x:xs) lexem 
    | isAlphaNum x || isUnderscore x = scanIde xs (lexem ++ [x]) -- Might be x : lexem and then reverse lexem
    | isReserved lexem = (mapReserved lexem, all)
    | otherwise = (Ide lexem, all)


scanNum :: String -> Int -> (Token, String)
scanNum [] lexem = (Num lexem, [])
scanNum all@(x:xs) lexem 
    | isDigit x = scanNum xs (lexem * 10 + digitToInt x)
    | otherwise = (Num lexem, all)
