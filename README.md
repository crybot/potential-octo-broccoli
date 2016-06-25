<strong> Current Grammar </strong>
<p> <i>
    post-fix F stands for "left Factored" 
    post-fix ' stands for productions from which left recursion has been -- eliminated 
</i> </p> 

- S -> DecL | ComL | Expr
- DecL -> Dec DecLF
- DecLF -> and DecL | epsilon
- ComL -> Com ComLF
- ComLF -> ; ComL | epsilon
- Dec -> int ide | int ide = Expr
- Com -> ide = Expr
- Expr -> TermExpr'
- Expr' -> +TermExpr' | -TermExpr' | epsilon
- Term -> FactTerm'
- Term' -> *FactTerm' | /FactTerm' | epsilon
- Fact -> num | ide | (Exp)

