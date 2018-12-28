
-- Now we add the ability for players to guess and add the guess as an input to the SC.

import qualified Language.PlutusTx            as PlutusTx
import qualified Language.PlutusTx.Prelude    as P
import           Ledger
import           Ledger.Validation
import           Wallet
import           Playground.Contract



jbValidator :: ValidatorScript
jbValidator = ValidatorScript $ Ledger.fromCompiledCode $$(PlutusTx.compile
  [||
   \(guessedNum :: Int) (winningNum :: Int) () -> ()
   ||])

scAddress :: Address'
scAddress = Ledger.scriptAddress jbValidator

lockNumber :: Int -> Value -> MockWallet ()
lockNumber num prize = payToScript_ scAddress prize $ DataScript $ Ledger.lifted num

guessNumber :: Int -> MockWallet ()
guessNumber num = collectFromScript jbValidator $ RedeemerScript $ Ledger.lifted num

$(mkFunction 'lockNumber)
$(mkFunction 'guessNumber)
