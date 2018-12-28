-- We create an empty SC (Validator Script) and obtain it's address.

import qualified Language.PlutusTx            as PlutusTx
import qualified Language.PlutusTx.Prelude    as P
import           Ledger
import           Ledger.Validation
import           Wallet
import           Playground.Contract



jbValidator :: ValidatorScript
jbValidator = ValidatorScript $ Ledger.fromCompiledCode $$(PlutusTx.compile
  [||
   \() () () -> ()
   ||])

scAddress :: Address'
scAddress = Ledger.scriptAddress jbValidator
