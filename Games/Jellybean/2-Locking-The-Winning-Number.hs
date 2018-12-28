-- We write the function to lock the winning number and prize, use mkFunction for Plutus Playground to provide UI, and updated the SC to take the number as input.

import qualified Language.PlutusTx            as PlutusTx
import qualified Language.PlutusTx.Prelude    as P
import           Ledger
import           Ledger.Validation
import           Wallet
import           Playground.Contract



jbValidator :: ValidatorScript
jbValidator = ValidatorScript $ Ledger.fromCompiledCode $$(PlutusTx.compile
  [||
   \() (winningNum :: Int) () -> ()
   ||])

scAddress :: Address'
scAddress = Ledger.scriptAddress jbValidator

lockNumber :: Int -> Value -> MockWallet ()
lockNumber num prize = payToScript_ scAddress prize $ DataScript $ Ledger.lifted num

$(mkFunction 'lockNumber)
