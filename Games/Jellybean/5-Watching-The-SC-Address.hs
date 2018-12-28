
-- Here we provide the ability for the wallets in Plutus Playground to call watchSCAddress. This allows them to keep track of the SC and thus now if the player calls watchSCAddress first (before the lock) and then guesses the number correctly, they will be paid out.

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
   \(guessedNum :: Int) (winningNum :: Int) (p :: PendingTx') ->
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

watchSCAddress :: MockWallet ()
watchSCAddress = startWatching scAddress

$(mkFunction 'lockNumber)
$(mkFunction 'guessNumber)
$(mkFunction 'watchSCAddress)
