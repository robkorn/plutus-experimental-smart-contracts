
-- We check that the guessedNum and the winningNum are equal and throw an error if they are not. Note: This still won't pay out the player, we'll solve that in the next one.

import qualified Language.PlutusTx            as PlutusTx
import qualified Language.PlutusTx.Prelude    as P
import qualified Language.PlutusTx.Builtins   as Builtins
import           Ledger
import           Ledger.Validation
import           Wallet
import           Playground.Contract



jbValidator :: ValidatorScript
jbValidator = ValidatorScript $ Ledger.fromCompiledCode $$(PlutusTx.compile
  [||
   \(guessedNum :: Int) (winningNum :: Int) () ->
    if (Builtins.equalsInteger guessedNum winningNum)
    then ()
    else $$(P.error) ($$(P.traceH) "That is not correct!" ())
   ||])

scAddress :: Address'
scAddress = Ledger.scriptAddress jbValidator

lockNumber :: Int -> Value -> MockWallet ()
lockNumber num prize = payToScript_ scAddress prize $ DataScript $ Ledger.lifted num

guessNumber :: Int -> MockWallet ()
guessNumber num = collectFromScript jbValidator $ RedeemerScript $ Ledger.lifted num

$(mkFunction 'lockNumber)
$(mkFunction 'guessNumber)
