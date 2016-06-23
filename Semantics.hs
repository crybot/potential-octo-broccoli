module Main where
import Lexer
import Parser

data Bottom a = Bottom | Value a deriving (Show, Eq)                                                                                                     
type Frame a b = a -> Bottom b                                                  
type Stack a b = [Frame a b]                                                    

data Val = ValN Int | Unknown deriving (Show, Eq)
type Loc = Int                                                                  

type EnvFrame = Frame Ide Loc                                                   
type MemFrame = Frame Loc Val                                                   
type Env = [EnvFrame]                                                           
type Mem = [MemFrame]                                                           

w :: a -> Bottom b                                                              
w _ = Bottom                                                                    

add :: (Eq a, Eq b) => Frame a b  -> a -> Bottom b -> Frame a b                 
add f x y                                                                       
    | f x == Bottom = g                                                       
    | otherwise = undefined                                                     
    where g z | z == x = y                                                      
              | otherwise = f z                                                 

update :: (Eq a, Eq b) => Frame a b  -> a -> Bottom b -> Frame a b              
update f x y                                                                    
    | f x /= Bottom = g                                                         
    | otherwise = undefined                                                     
    where g z | z == x = y                                                      
              | otherwise = f z                                                 

searchStack :: (Eq a, Eq b) => [Frame a b] -> a -> Bottom b                    
searchStack [] _ = Bottom                                                      
searchStack (f:fs) x                                                           
    | f x /= Bottom = f x                                                       
    | otherwise = searchStack fs x                                             

addStack :: (Eq a, Eq b) => [Frame a b] -> a -> Bottom b -> [Frame a b]        
addStack (f:fs) x y = add f x y : fs                                         
addStack [] _ _ = undefined                                                    

updateStack :: (Eq a, Eq b) => [Frame a b] -> a -> Bottom b -> [Frame a b]     
updateStack [] _ _ = undefined                                                 
updateStack (f:fs) x y                                                         
    | f x /= Bottom = update f x y : fs                                       
    | otherwise = f : updateStack fs x y   

getLoc :: (Num a, Eq b) => [a -> Bottom b] -> a                                                           
getLoc (f:_) = findLoc f 0
    where findLoc f loc 
            | f loc == Bottom = loc
            | otherwise = findLoc f (loc+1)

semBop :: (Num a) => Operation -> (Val -> Val -> Val)                                
semBop o = f                                                                   
    where f (ValN x) (ValN y) = ValN (operator o x y)                               
          operator op = case op of
                   Plus -> (+)
                   Minus -> (-)
                   Times -> (*)
                   Divide -> div



semExp :: ExpAst -> Env -> Mem -> Val
semExp (ValNode n) env mem = ValN n

--semExp (Ide id) env mem = v
    --where Value loc = searchStack env id
          --Value v = searchStack mem loc

semExp (ExpNode op e1 e2) env mem = o v1 v2
    where v1 = semExp e1 env mem
          v2 = semExp e2 env mem
          o = semBop op

semDec :: Statement -> Env -> Mem -> (Env, Mem)
semDec (Init id exp) env mem = (env', mem')
    where 
          val = semExp exp env mem
          env' = addStack env id (Value loc)
          mem' = addStack mem loc (Value val)
          loc = getLoc mem

semDec (Dec id) env mem = (env', mem')
    where env' = addStack env id (Value loc)
          mem' = addStack mem loc (Value Unknown)
          loc = getLoc mem


main :: IO ()                                                                   
main = do
    exps <- lines <$> getContents
    let exps' =  map (parse . tokenize) exps
    mapM_ (print . (\ (Exp x) -> semExp x [w] [w])) exps'
